# Superpowers integration (optional)

This project’s **agent-team pipeline is primary**.  
[Superpowers](https://github.com/obra/superpowers) (or equivalent skill packs: brainstorming, writing-plans, TDD, subagent-driven-dev, …) is an **optional process layer for Claude** — not a second phase machine and not a coder.

Grok never loads Superpowers. Only `HANDOFF.md` + linked files define coder scope.

## Standing rules (non-negotiable)

Copy of the orchestrator contract — follow even if a Superpowers skill says otherwise:

1. **Agent-team primary.** Authority order matches ECC policy:
   - **Disk** (`STATE.md`, `HANDOFF.md`, approved `docs/specs/*` · `docs/plans/*`, `docs/reviews/**`)
   - **Contracts** (`CLAUDE.md`, `AGENTS.md`, `GROK.md`, `WORKFLOW.md`)
   - **Superpowers skills** (suggestions only)
   - **Chat** / instincts / raw MCP hits
2. **Superpowers for pre-CODE and discipline — not “Claude ships feature”.**  
   Allowed: brainstorm, structure plans, TDD/verify shape, debug framing, review quality.  
   Forbidden as default: Claude (or Superpowers coding subagents) implementing large product scope.
3. **Mental model remaps:**
   | Skill / phrase | Must become |
   |----------------|-------------|
   | `writing-plans` | One file under `docs/plans/` from project template (not chat-only) |
   | “implement” / execute the plan | `docs/agent-team/HANDOFF.md` + `./scripts/invoke-grok.sh` |
   | Code-review fix loop | Max **10** iterations → then human blocker in `STATE.md` ([WORKFLOW.md](./WORKFLOW.md)) |
4. **Do not run as dual defaults:** Superpowers `executing-plans` in Claude-implements mode **and** ECC multi-orch / full harness. At most one heavy “execute” habit — and it must **remap to Grok**.
5. **Adoption ladder (strict order):**
   - **A — Baseline:** agent-team only (no Superpowers required)
   - **B — Superpowers light:** after A is stable through DONE — brainstorm, writing-plans, TDD, systematic-debugging, requesting-code-review (+ CODE remap)
   - **C — ECC light:** only when domain/security depth is still missing — see [ECC-INTEGRATION.md](./ECC-INTEGRATION.md); do not start at C

## Authority order (highest first)

When anything conflicts, obey this order:

1. `docs/agent-team/STATE.md` + `docs/agent-team/HANDOFF.md`
2. Approved `docs/specs/*` and `docs/plans/*`
3. `docs/reviews/**` (open findings drive fix loops)
4. `CLAUDE.md` + `AGENTS.md` + `GROK.md` + `docs/agent-team/WORKFLOW.md`
5. Superpowers skills / ECC skills / other harness packs (suggestions only)
6. Chat memory, learned “instincts”, MCP search hits

**Never** promote skill output into requirements without writing it into a spec/plan/review artifact.

## The CODE-path remap (non-negotiable)

Superpowers often assumes **Claude implements**. In this project:

| Superpowers says… | You do instead… |
|--------------------|-----------------|
| “Implement the plan” / `executing-plans` | Write `HANDOFF.md`, set `STATE` phase `CODE`, run `./scripts/invoke-grok.sh` |
| Subagent codes the feature | Same — Grok is the coder; Claude subagents author/review only |
| Fix bugs in-tree during debug | Prefer fix-only HANDOFF → Grok; tiny orchestrator fixes only if truly trivial |
| Success = code merged by Claude | Success = verify commands pass under HANDOFF + gates in `STATE.md` |

If a Superpowers skill would change product code at scale, **stop** and use the Grok path.

## Skill enable / disable checklist

Use this when Superpowers (or the same skills under `~/.claude/skills`) is installed.

### Enable (recommended with agent-team)

| Skill | Use for | Must land on disk as |
|-------|---------|----------------------|
| `brainstorming` | Ambiguous product intent before DRAFT_SPEC | Notes → then `docs/specs/...` from template |
| `writing-plans` | Structure implementation steps | **One** `docs/plans/...` (project template), not chat-only |
| `test-driven-development` | Shape plan steps + verify commands | Plan `verify:` lines + HANDOFF verify block |
| `systematic-debugging` | Diagnose failures during CODE_REVIEW loop | Findings in `docs/reviews/code/...` or fix HANDOFF |
| `requesting-code-review` | Drive CODE_REVIEW quality | `docs/reviews/code/YYYY-MM-DD-<slug>-iter-N.md` |
| `verification-before-completion` | Before claiming DONE | Real verify commands + `STATE` gates |
| `finishing-a-development-branch` | After `STATE.phase=DONE` (PR/merge hygiene) | Does not replace `DONE` gate |
| `using-git-worktrees` | Optional isolation for risky work | Still one active feature in `STATE.md` |
| `dispatching-parallel-agents` | Parallel *read-only* explore / multi-file research | Not parallel feature CODE; one feature in STATE |

### Enable with remap only

| Skill | Remap rule |
|-------|------------|
| `subagent-driven-development` | Subagents may draft specs/plans/reviews; **implementation turns** = HANDOFF + `invoke-grok.sh`, not subagent patches |
| `executing-plans` | Treat “execute” as **orchestrate CODE phase** (HANDOFF + Grok + review loop), never Claude-implements-the-plan by default |
| `using-superpowers` | OK as entry discipline; after skill pick, still advance only via `STATE.md` phases |

### Disable or avoid as default (with agent-team)

| Skill / habit | Why |
|---------------|-----|
| Claude “just implements” after any skill | Replaces Grok; breaks SSOT coder role |
| Parallel multi-feature execution | v1 STATE is **one** active feature |
| Skill output as sole plan/spec | Must copy into `docs/specs` / `docs/plans` / `docs/reviews/**` |
| Skipping DRAFT_SPEC because brainstorming “felt done” | Brainstorm ≠ approved spec gate |
| Using Superpowers to edit `WORKFLOW.md` / templates | Out of scope unless human/HANDOFF says so |

### Optional / situational

| Skill | When |
|-------|------|
| `receiving-code-review` | Human or external review comments → translate into fix HANDOFF |
| `writing-skills` / `skill-creator` | Maintaining skills — not part of product feature loop |
| `prompt-master` | Only when user asks to craft prompts |

## Phase map

| Phase | Superpowers may help | Still required here |
|-------|----------------------|---------------------|
| `DRAFT_SPEC` | `brainstorming` → clarify intent | Write `docs/specs/...` from template; update `STATE` |
| `SPEC_REVIEW` | Review discipline | **Mandatory loop** until APPROVED + zero blocking findings → `spec_review: approved` |
| `WAIT_HUMAN_SPEC` | — | Only after Claude clean — **stop for human** |
| `PLAN` | `writing-plans`, TDD structure | Write `docs/plans/...` with `verify:` steps |
| `PLAN_REVIEW` | Review discipline | **Mandatory loop** until APPROVED + zero blocking findings → `plan_review: approved` |
| `WAIT_HUMAN_PLAN` | — | Only after Claude clean — **stop for human** |
| `CODE` | Checklist quality for HANDOFF only | Human gates OK → `./scripts/invoke-grok.sh` |
| `CODE_REVIEW` | `requesting-code-review`, debugging framing | Findings file |
| `WAIT_HUMAN_CODE_FIX` | — | **Stop for human** — no Grok fix until `human_code_fix: approved` |
| `DONE` | `verification-before-completion`, `finishing-a-development-branch` | `STATE.phase=DONE` + gates approved |

## Operating rules

1. **One phase machine:** only `STATE.md` advances the feature.
2. **One coder path for product features:** `scripts/invoke-grok.sh` when phase is `CODE`.
3. **Skill output is not done** until copied into project templates under `docs/specs`, `docs/plans`, or `docs/reviews/**`.
4. **Grok ignores Superpowers.** Coder reads `GROK.md` → `HANDOFF.md` → linked files only.
5. **Do not stack** Superpowers full execute path + ECC multi-orch + agent-team as three competing defaults. Prefer: agent-team primary → Superpowers light (process) → ECC light (domain/security) only if needed.

## Adoption ladder

| Tier | What you enable | When |
|------|-----------------|------|
| **A — Baseline** | Agent-team only. No Superpowers required. | Start here. |
| **B — Superpowers light** | brainstorming, writing-plans, TDD, systematic-debugging, requesting-code-review, verification-before-completion (+ CODE remap). | After **one** feature reaches DONE cleanly on A. |
| **B+ — optional** | worktrees / parallel *explore* only; still one STATE feature; execute = Grok. | Optional on B. |
| **C — ECC light** | Domain/security pack — [ECC-INTEGRATION.md](./ECC-INTEGRATION.md) | Only if B still lacks depth; **not** instead of A/B. |

Do **not** enable Superpowers full execute + ECC multi-orch together as defaults (standing rule 4).

## Conflict resolution cheat sheet

| Situation | Decision |
|-----------|----------|
| Superpowers wants Claude to implement now | Refuse for product features; write HANDOFF → Grok |
| `writing-plans` vs Opus plan file | Merge into **one** `docs/plans/*`; one SSOT |
| Brainstorm invents extra scope | Out of scope unless added to approved spec |
| Skill checklist ≠ HANDOFF | HANDOFF wins |
| Debug skill finds a bug | CODE_REVIEW artifact or fix-only HANDOFF → Grok |
| Superpowers vs ECC vs WORKFLOW | WORKFLOW + STATE/HANDOFF win; packs are suggestions |

## Orchestrator pocket checklist

Before each non-trivial turn with Superpowers installed:

- [ ] Standing rules 1–5 still apply (primary pipeline, pre-CODE only, remaps, no dual orch, correct tier)
- [ ] Current `STATE.phase` known and respected
- [ ] Skill output will be written to the correct `docs/**` path (or HANDOFF)
- [ ] If work is implementation: path is Grok via `invoke-grok.sh`, not Claude bulk edit
- [ ] Fix loop count ≤ 10 or human blocker set
- [ ] If iteration > 1: HANDOFF lists only open findings
- [ ] Not starting a second feature while `STATE` is non-IDLE/DONE
- [ ] Not running Superpowers execute-as-Claude + ECC multi-orch as defaults

## References

- Pipeline: [WORKFLOW.md](./WORKFLOW.md)
- Shared map: [AGENTS.md](../../AGENTS.md)
- Orchestrator: [CLAUDE.md](../../CLAUDE.md)
- Coder: [GROK.md](../../GROK.md)
- ECC (optional, separate pack): [ECC-INTEGRATION.md](./ECC-INTEGRATION.md)
