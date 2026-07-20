# Design: Claude + Grok Agent Team Template

**Date:** 2026-07-20  
**Status:** Approved for implementation planning  
**Approach:** A (file SSOT + handoff) + light gates from B  

## 1. Problem

New projects need a reusable skeleton so **Claude** (orchestrator: Opus for specs/plans, Sonnet for reviews) and **Grok CLI** (coder) can collaborate without losing context across tools, sessions, and review loops.

Chat memory and ad-hoc paste are unreliable. Agents need a **disk-based source of truth** and a **thin handoff** every time Grok is invoked.

## 2. Goals

1. Copy-paste skeleton into any new project root (no app code scaffold).
2. Claude orchestrates: Opus → Sonnet (spec/plan) → Grok (code) → Sonnet (code review) → Grok fix loop.
3. No context loss: every agent reads shared files; Grok always starts from `HANDOFF.md`.
4. Context7 (or similar indexing MCP) is for codebase lookup only—not requirements.
5. Light phase gates via `STATE.md` (not a heavy state machine).

## 3. Non-goals (v1)

- Auto-selecting Claude model API keys or forcing exact model IDs in every environment.
- Full CI integration of the agent pipeline.
- Parallel multi-feature `STATE.md` (one active feature at a time).
- Scaffolding application boilerplate (frontend/backend/frameworks).
- Replacing Context7 with a custom memory product.

## 4. Architecture

### 4.1 Roles

| Role | Tool / model intent | Responsibility |
|------|---------------------|----------------|
| Orchestrator | Claude main session | Advance phases, write `STATE.md` / `HANDOFF.md`, call Grok CLI, enforce gates |
| Spec / Plan author | Claude subagent (Opus) | Write `docs/specs/*`, `docs/plans/*` |
| Reviewer | Claude subagent (Sonnet) | Spec, plan, and code reviews under `docs/reviews/**` |
| Coder | Grok CLI / Grok Build | Implement and fix only what `HANDOFF.md` allows |

### 4.2 Skeleton layout

```text
project-root/
  CLAUDE.md
  AGENTS.md
  GROK.md
  docs/
    agent-team/
      WORKFLOW.md
      STATE.md
      HANDOFF.md
      templates/
        SPEC.template.md
        PLAN.template.md
        SPEC_REVIEW.template.md
        CODE_REVIEW.template.md
        HANDOFF.template.md
    specs/
    plans/
    reviews/
      spec/
      code/
  scripts/
    invoke-grok.sh
  .mcp.json.example
```

### 4.3 SSOT map (anti-context-loss)

| Source | Writers | Readers | Must not replace |
|--------|---------|---------|------------------|
| `docs/specs/*` | Opus | All | Chat memory |
| `docs/plans/*` | Opus | All | Chat memory |
| `docs/reviews/spec/*` | Sonnet | Orchestrator, Opus (on changes) | Spec itself |
| `docs/reviews/code/*` | Sonnet | Grok (fixes), Orchestrator | Spec/plan |
| `docs/agent-team/HANDOFF.md` | Orchestrator | Grok (every code turn) | Full long-form chat |
| `docs/agent-team/STATE.md` | Orchestrator | Orchestrator (gates) | Technical detail |
| Context7 / index MCP | — | Any (lookup) | Handoff, reviews, requirements |

**Rule:** Requirements live in spec + handoff. Context7 only helps understand existing code.

## 5. Workflow and gates

### 5.1 Phase pipeline

```text
DRAFT_SPEC → SPEC_REVIEW → PLAN → PLAN_REVIEW → CODE → CODE_REVIEW → DONE
                              ↑                    │
                              └──── CHANGES ───────┘
                                     (spec/plan loops)

CODE ←── CODE_REVIEW (open critical/high/medium findings)
```

| Phase | Actor | Artifact |
|-------|-------|----------|
| `DRAFT_SPEC` | Opus | `docs/specs/YYYY-MM-DD-<slug>-spec.md` |
| `SPEC_REVIEW` | Sonnet | `docs/reviews/spec/YYYY-MM-DD-<slug>.md` |
| `PLAN` | Opus | `docs/plans/YYYY-MM-DD-<slug>-plan.md` (only if spec approved) |
| `PLAN_REVIEW` | Sonnet | `docs/reviews/spec/YYYY-MM-DD-<slug>-plan.md` |
| `CODE` | Orchestrator writes HANDOFF → `scripts/invoke-grok.sh` → Grok | Code + verify results |
| `CODE_REVIEW` | Sonnet | `docs/reviews/code/YYYY-MM-DD-<slug>-iter-N.md` |
| `DONE` | Orchestrator | `STATE.md` phase=`DONE` |

Each phase: **act → write artifact → update STATE → gate check** before advancing.

### 5.2 Gate rules

- Spec/plan review verdict: `APPROVED` | `CHANGES_REQUESTED`.
- `CHANGES_REQUESTED` → return to author phase; do not advance.
- Code review: any **open** finding with severity `critical`, `high`, or `medium` blocks `DONE`.
- Severity `low` / `nit`: default **non-blocking**; mark `deferred` in review file.
- Suggested max code-review iterations: **5**, then escalate to human (record blocker in `STATE.md`).

### 5.3 `STATE.md` minimum fields

```yaml
feature: <slug>
phase: CODE_REVIEW
iteration: 2
spec: docs/specs/...
plan: docs/plans/...
latest_code_review: docs/reviews/code/...
handoff: docs/agent-team/HANDOFF.md
gates:
  spec_review: approved   # pending | approved | changes_requested
  plan_review: approved
  code_review: open       # open | approved
blockers: []
```

Only **one** active feature in `STATE.md` for v1.

### 5.4 `HANDOFF.md` required sections

Every Grok invocation must have a current handoff with:

1. Goal (1–3 sentences) and success criteria  
2. In-repo links: spec, plan, latest relevant review  
3. In-scope / out-of-scope  
4. Allowed files / surgical constraints (when known)  
5. If `iteration > 1`: **only** open findings (id, file, expected fix)—not a full restate of the feature  
6. Verify commands (test/build)

Grok must not expand scope beyond handoff.

### 5.5 `invoke-grok.sh`

- Run from project root.
- Prompt Grok to read: `GROK.md` → `HANDOFF.md` → linked paths.
- Prefer file links over inlining full specs (avoid CLI truncation).
- Script is a thin wrapper; exact Grok CLI flags may be documented as configurable env vars (e.g. `GROK_CMD`).

## 6. Contract files

### 6.1 `AGENTS.md` (shared)

- Role matrix (table above).
- File map and SSOT rules.
- Short pointer to phase enum + link to `docs/agent-team/WORKFLOW.md`.
- Context7 usage rule.
- Short pointer to Karpathy principles (or link `CLAUDE.md`).

### 6.2 `CLAUDE.md` (orchestrator)

- Full Karpathy guidelines (Think / Simplicity / Surgical / Goal-driven), aligned with this repo’s `CLAUDE.md`.
- Orchestrator duties: correct subagent roles, artifacts + STATE before phase advance.
- Do not implement large features as Claude when Grok is the coder (tiny orchestrator fixes allowed).
- Call path: update HANDOFF → `scripts/invoke-grok.sh`.
- Review loop + max iteration escalate.

### 6.3 `GROK.md` (thin coder contract, ~30–50 lines)

1. Read order: `GROK.md` → `HANDOFF.md` → linked review if any → spec/plan only if handoff requires.  
2. Scope = handoff only.  
3. Surgical changes; match existing style.  
4. Run verify commands; record short result.  
5. Do not edit workflow/templates unless handoff says so.  
6. Context7 only for in-scope understanding.

**Do not** duplicate long Karpathy text or full workflow in `GROK.md`.

### 6.4 Templates — required fields

| Template | Required fields |
|----------|-----------------|
| SPEC | problem, goals, non-goals, requirements, success criteria, open questions |
| PLAN | steps each with `verify:`, risks, file touch list |
| SPEC_REVIEW / PLAN_REVIEW | verdict, findings `[id, severity, location, fix]`, questions |
| CODE_REVIEW | verdict, findings `[id, severity, file:line, repro, expected]`, test gaps |
| HANDOFF | goal, success criteria, links, scope, out-of-scope, open findings, verify cmds |

## 7. Context7 / MCP

- Ship `.mcp.json.example` showing how to enable a Context7-style docs/code index MCP.
- User merges into their real MCP config (Claude Code / Grok as applicable).
- Document in `WORKFLOW.md`: index MCP ≠ authority for requirements.

## 8. Relationship to this repository

This repo already provides Karpathy-inspired `CLAUDE.md` and `skills/karpathy-guidelines/`. The template should:

- Reuse those principles in the template’s `CLAUDE.md`.
- Live as a **copyable tree at** `templates/agent-team/` in this repo. Users copy the *contents* of that directory into a new project root (so `templates/agent-team/CLAUDE.md` becomes `project-root/CLAUDE.md`).

Packaging path is fixed as `templates/agent-team/`; §4.2 describes the tree **after** copy into a project.

## 9. Success criteria

Template v1 is successful when:

1. A user can copy the skeleton into a new repo and see the file tree from §4.2.  
2. A human (or Claude) can advance a fictional feature through all phases using only files on disk.  
3. Grok can complete a coding turn by reading only `GROK.md` + `HANDOFF.md` + linked paths.  
4. Code review loop re-handoffs with open findings only, without re-pasting full chat history.  
5. `STATE.md` prevents advancing past failed gates (documented rules, not necessarily enforced by code).  
6. No requirement is stored only in chat or only in Context7.

## 10. Risks and mitigations

| Risk | Mitigation |
|------|------------|
| Orchestrator skips writing HANDOFF | `WORKFLOW.md` + `CLAUDE.md` make HANDOFF mandatory before `invoke-grok.sh` |
| Spec/plan drift vs code | CODE_REVIEW checks against approved plan; findings reference plan step ids when useful |
| Grok CLI flags differ by install | `GROK_CMD` / documented placeholders in script |
| Review infinite loop | max iteration 5 → human blocker |
| Duplicate docs rot | Thin `GROK.md`; detail only in `WORKFLOW.md` |

## 11. Implementation notes (for later plan)

Implementation should create the skeleton files with filled templates (placeholder examples), empty or starter `STATE.md` / `HANDOFF.md`, executable `invoke-grok.sh`, and a short root README section or `docs/agent-team/README.md` on how to copy into a new project.

No application feature code is required for the template itself.
