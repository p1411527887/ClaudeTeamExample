# Agent Team Workflow

## Sizing (pick once per task)

Set `size` in `docs/agent-team/STATE.md` at the start of work (human says `micro` / `small` / `full`, or Claude proposes and human confirms).

| Size | When | Path |
|------|------|------|
| **micro** | Typo / 1–few lines; trivial | Thin **HANDOFF** → **Grok** (`invoke-grok`) → optional Claude code review. Spec/plan gates = `n/a`. **Claude does not implement.** |
| **small** | Small feature/bug, few files, scope clear | Spec (short) → Claude review-until-clean → **WAIT_HUMAN_SPEC** → HANDOFF + **Grok** → CODE_REVIEW → (bugs → WAIT_HUMAN_CODE_FIX → Grok). Plan optional (`plan_review`/`human_plan` = `n/a`). |
| **full** | Multi-module, schema/API/auth, high risk | Full pipeline below (spec ⟲ plan ⟲ human → **Grok** → code ⟲). |

**Role split (all sizes)**

| Who | Does | Does **not** |
|-----|------|----------------|
| **Claude** | Spec, plan, reviews, STATE/HANDOFF, call `invoke-grok` | Implement product feature code (no bulk coding) |
| **Grok** | All product CODE + fixes via HANDOFF | Invent requirements outside HANDOFF |

**Defaults**

- Human names size → use it.
- Unclear → Claude proposes; default **`small`**.
- Scope grows → upgrade size; never hide a real feature under micro without HANDOFF clarity.

**Escalation:** micro → small/full if change touches behavior, public API, data, or multi-file design.

---

## Model routing (Opus vs Sonnet)

Use **model class**, not a single API SKU string. Map in your Claude client as:

| Class | Intent |
|-------|--------|
| **Opus-class** | Strongest available Claude for authoring (e.g. Opus) |
| **Sonnet-class** | Fast/cheap Claude for review + light authoring (e.g. Sonnet) |

### Who uses which model

| Artifact / role | **micro** | **small** | **full** |
|-----------------|-----------|-----------|----------|
| Spec author (`DRAFT_SPEC`) | n/a | **Sonnet** default; **Opus** if escalate | **Opus** required |
| Plan author (`PLAN`) | n/a | Same as that feature’s spec author (or **Sonnet** if reusing an Opus-approved spec that is already very detailed) | **Opus** required |
| Spec / plan / code reviewer | **Sonnet** (code review optional) | **Sonnet** | **Sonnet** |
| Orchestrator (STATE / HANDOFF / gates) | Any | Any | Any |

**Hard rules**

1. **Reviews are Sonnet** unless the human explicitly asks for Opus on a review, or author↔review is still structurally broken after **3** loops (then one Opus review pass is allowed).
2. **`full` never uses Sonnet as sole spec/plan author** — leverage is highest here; do not “save” model cost on requirements.
3. **Record class on the artifact** — `Author: Opus (spec)` or `Author: Sonnet (spec)` (same for plan). Reviewer line stays `Sonnet` by default.
4. Human override always wins: e.g. `use Opus for spec` / `Sonnet is fine`.

### Escalate **small** author to Opus when any of these is true

- Product or API meaning still ambiguous after a short clarify
- Touches **auth**, **payments**, **concurrency**, **schema/migration**, or **public API**
- Multi-module / multi-service or unclear file blast radius
- Spec/plan review returned `CHANGES_REQUESTED` for **structural** issues (missing requirements, wrong approach) **≥ 2** times
- Human says high-stakes or “use Opus”

If escalate mid-feature: rewrite or heavily revise the artifact with Opus, then **restart** the Claude review loop (do not skip `SPEC_REVIEW` / `PLAN_REVIEW`).

### Budget tip (optional)

Prefer cutting cost on **review loops** and **micro**, not on **`full` authoring**.  
If budget is tight on **small**: keep **Opus for the first solid spec** when escalate triggers fire; keep **Sonnet for all reviews**.

---

## Pipeline — **full** size (Claude review until clean + human gates)

**Mandatory for `size: full`:** Spec and plan must pass a **Claude AI review loop until no blocking bugs** before the human is asked to approve, and before any later phase.

```text
DRAFT_SPEC → SPEC_REVIEW ⟲ (fix spec until Claude verdict APPROVED, zero open blocking findings)
         → WAIT_HUMAN_SPEC (human final OK)
         → PLAN → PLAN_REVIEW ⟲ (fix plan until Claude verdict APPROVED, zero open blocking findings)
         → WAIT_HUMAN_PLAN (human final OK)
         → CODE → CODE_REVIEW
         → [blocking code bugs] WAIT_HUMAN_CODE_FIX → CODE (Grok fix) → CODE_REVIEW → …
         → DONE
```

### Pipeline — **small** size

```text
DRAFT_SPEC (short) → SPEC_REVIEW ⟲ clean → WAIT_HUMAN_SPEC
  → [optional PLAN + PLAN_REVIEW if needed; else plan_review/human_plan = n/a]
  → CODE (Grok) → CODE_REVIEW → [WAIT_HUMAN_CODE_FIX → Grok] ⟲ → DONE
```

### Pipeline — **micro** size

```text
STATE size=micro, phase=CODE, iteration=1
  gates: human_spec|human_plan|spec_review|plan_review = n/a
  → thin HANDOFF (goal + files + verify)
  → ./scripts/invoke-grok.sh   # Grok codes
  → optional Claude CODE_REVIEW (quick)
  → DONE
```

Claude may only write HANDOFF / run invoke / light review — **never** patch product code on micro either.

### Blocking findings (spec, plan, and code)

Open findings with severity **`critical` | `high` | `medium`** block advancement.  
`low` / `nit` → mark `deferred` by default; do not block.

### Steps (**full**; **small** skips steps marked full-only)

0. **SIZE** — Set `STATE.size` to `micro` | `small` | `full`.  
   - **micro:** set pre-code gates to `n/a`, write thin HANDOFF, jump to **CODE** (step 7).  
   - **small/full:** continue from DRAFT_SPEC.

1. **DRAFT_SPEC** — Author (model per **Model routing**) writes `docs/specs/YYYY-MM-DD-<slug>-spec.md` from `docs/agent-team/templates/SPEC.template.md` (keep short on **small**).  
   Set `gates.spec_review: pending`. Note `Author: Opus|Sonnet (spec)` on the file.

2. **SPEC_REVIEW (mandatory Claude)** — Sonnet-class writes `docs/reviews/spec/YYYY-MM-DD-<slug>.md` from the review template.  
   - Verdict **`CHANGES_REQUESTED`** or any **open** critical/high/medium → back to **DRAFT_SPEC** (author fixes), re-review. **Loop until clean.**  
   - Verdict **`APPROVED`** and **no open blocking findings** → set `gates.spec_review: approved`.  
   - **Do not** enter `WAIT_HUMAN_SPEC` while `spec_review` is not approved.  
   - Cap: after **10** author↔review loops without clean APPROVED, set a human blocker in `STATE.md` and stop.

3. **WAIT_HUMAN_SPEC** — Only after Claude spec review is clean. Set `gates.human_spec: pending`. **STOP.**  
   Present **approved** spec path + last review path.  
   - Human approve → `human_spec: approved`.  
   - Human changes → back to DRAFT_SPEC (then full Claude review loop again).  
   - **No PLAN** until `human_spec: approved`.

4. **PLAN** (**full** required; **small** optional) — Author (model per **Model routing**) writes `docs/plans/YYYY-MM-DD-<slug>-plan.md` **only if** `human_spec` and `spec_review` are approved.  
   - **small** without separate plan: set `plan: null` (or “embedded in spec”), `plan_review: n/a`, `human_plan: n/a`.  
   - **full** or **small** with plan: Set `gates.plan_review: pending`. Note `Author: Opus|Sonnet (plan)` on the file.

5. **PLAN_REVIEW** (**full** mandatory; **small** only if a plan file exists) — Sonnet-class writes `docs/reviews/spec/YYYY-MM-DD-<slug>-plan.md`.  
   - Same loop rules as SPEC_REVIEW until **APPROVED** + zero open blocking findings → `gates.plan_review: approved`.  
   - **Do not** enter `WAIT_HUMAN_PLAN` while `plan_review` is not approved (when a plan is in play).  
   - Cap: **10** plan author↔review loops, then human blocker.

6. **WAIT_HUMAN_PLAN** (**full** required; **small** only if plan exists) — After Claude plan review is clean. Set `gates.human_plan: pending`. **STOP.**  
   - Human approve → `human_plan: approved`.  
   - **full:** **No HANDOFF / Grok** until then.  
   - **small** with `human_plan: n/a`: skip this wait; go to CODE after `human_spec` approved.

7. **CODE** — Fill `HANDOFF.md`, `phase: CODE`, `./scripts/invoke-grok.sh` (iter 1) when gates allow. **Grok always implements** (including micro). Claude does not.

8. **CODE_REVIEW** — Sonnet writes `docs/reviews/code/YYYY-MM-DD-<slug>-iter-N.md` (micro: optional but recommended if non-trivial).  
   - No open blocking findings → `code_review: approved` → **DONE**.  
   - Open blocking findings → `code_review: open`, `human_code_fix: pending`, **WAIT_HUMAN_CODE_FIX**. **STOP** (do not auto-Grok).

9. **WAIT_HUMAN_CODE_FIX** — Human approves fix list → `human_code_fix: approved` → fix-only HANDOFF → Grok → CODE_REVIEW again.

10. **DONE** — `phase: DONE` when code review is clean and gates allow.

Each phase: **act → write artifact → update STATE → gate check**.  
If `WAIT_HUMAN_*`: **stop and ask human** (do not continue the same turn).

### Stop rules (non-negotiable)

| After… | Required next | Must not |
|--------|----------------|----------|
| Spec draft | **Claude SPEC_REVIEW loop until clean** | Skip review; go straight to human or PLAN |
| Spec Claude-clean | **WAIT_HUMAN_SPEC** | Start PLAN without human |
| Plan draft | **Claude PLAN_REVIEW loop until clean** | Skip review; go straight to human or CODE |
| Plan Claude-clean | **WAIT_HUMAN_PLAN** | Invoke Grok without human |
| Code review blocking bugs | **WAIT_HUMAN_CODE_FIX** | Auto HANDOFF + Grok without human |

**Never** treat human approval as a substitute for Claude spec/plan review.  
**Never** treat Claude review as a substitute for human gates on spec/plan/code-fix.

## Iteration limits

| Loop | Max without clean APPROVED | Then |
|------|----------------------------|------|
| Spec author ↔ SPEC_REVIEW | **10** | `blockers` + stop for human |
| Plan author ↔ PLAN_REVIEW | **10** | `blockers` + stop for human |
| Code fix ↔ CODE_REVIEW | **10** | `blockers` + stop (no silent Grok) |

## HANDOFF rules (anti-context-loss)

Before every Grok invocation, `HANDOFF.md` must include:

1. Goal + success criteria  
2. Links to spec, plan, latest review  
3. In-scope / out-of-scope  
4. Allowed files / surgical constraints when known  
5. If iteration > 1: **only** open findings (id, file, expected fix)  
6. Verify commands  

Do not paste full chat history into the CLI. Prefer file paths.

## Before every `scripts/invoke-grok.sh` (checklist)

Orchestrator must confirm:

- [ ] `STATE.size` is `micro` | `small` | `full` (not null)
- [ ] **micro:** pre-code gates `n/a`; thin HANDOFF enough  
- [ ] **small/full:** `spec_review` + `human_spec` approved; plan gates approved or `n/a` as allowed  
- [ ] If iteration ≥ 2: `human_code_fix: approved`
- [ ] `STATE.md` `phase` is `CODE` (not `WAIT_HUMAN_*` / `IDLE`)
- [ ] Feature slug + iteration match HANDOFF
- [ ] If iteration > 1: Latest review + open findings table only
- [ ] `## Grok result` is `pending` only
- [ ] Real verify commands

`invoke-grok.sh` **enforces** (hard fail):

- `size` is `micro` | `small` | `full`  
- Phase CODE; slug/iter sync  
- **micro:** human_spec/plan + spec/plan_review may be `n/a`  
- **small:** human_spec + spec_review approved; plan gates approved or `n/a`  
- **full:** all four pre-code gates approved  
- Iteration ≥ 2 → human_code_fix approved  
- Strict pending Grok result body; exact idle sentinel rules  

## Context7 / index MCP

Use for understanding existing code. **Not** a source of product requirements.

## Optional: Superpowers / ECC

Pipeline stays primary. Packs must not skip **Claude spec/plan review-until-clean**, **WAIT_HUMAN_***, or Grok CODE path.

- [SUPERPOWERS-INTEGRATION.md](./SUPERPOWERS-INTEGRATION.md)
- [ECC-INTEGRATION.md](./ECC-INTEGRATION.md)

## Architecture

| Piece | Role |
|-------|------|
| `AGENTS.md` | Shared map |
| `CLAUDE.md` | Orchestrator: review loops + human stops |
| `GROK.md` | Coder contract |
| `docs/specs`, `docs/plans`, `docs/reviews` | Artifacts |
| `STATE.md` / `HANDOFF.md` | Phase + gates + Grok task |
| `scripts/invoke-grok.sh` | Grok only when all gates pass |

## Copy into a new project

See [README.md](./README.md) for install.
