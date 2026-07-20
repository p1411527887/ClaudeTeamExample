# Agent Team Workflow

## Pipeline

1. **DRAFT_SPEC** — Opus writes `docs/specs/YYYY-MM-DD-<slug>-spec.md` from `docs/agent-team/templates/SPEC.template.md`.
2. **SPEC_REVIEW** — Sonnet writes `docs/reviews/spec/YYYY-MM-DD-<slug>.md`.
   - Gate: `APPROVED` or `CHANGES_REQUESTED` (return to step 1).
3. **PLAN** — Opus writes `docs/plans/YYYY-MM-DD-<slug>-plan.md` (only if spec approved).
4. **PLAN_REVIEW** — Sonnet writes `docs/reviews/spec/YYYY-MM-DD-<slug>-plan.md`.
   - Gate: same as spec review.
   - **Note:** Plan reviews live under `docs/reviews/spec/` with a `-plan` suffix (no separate `docs/reviews/plan/` dir in v1).
5. **CODE** — Orchestrator fills `HANDOFF.md`, updates `STATE.md`, runs `scripts/invoke-grok.sh`.
6. **CODE_REVIEW** — Sonnet writes `docs/reviews/code/YYYY-MM-DD-<slug>-iter-N.md`.
   - Open `critical` / `high` / `medium` → back to CODE with fix-only HANDOFF.
   - `low` / `nit` → mark `deferred`; do not block DONE by default.
   - If code reveals plan/spec problems, return to PLAN or DRAFT_SPEC (human or orchestrator decision), not only CODE.
7. **DONE** — Set `STATE.md` phase to `DONE` when code_review gate is approved.

Each phase: **act → write artifact → update STATE → check gate**.

## Iteration limit

After **5** code-review fix loops without clearing blocking findings, set a human blocker in `STATE.md` and stop the auto loop.

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

- [ ] `STATE.md` `phase` is `CODE` (not `IDLE`)
- [ ] `STATE.md` `feature` slug matches HANDOFF feature slug
- [ ] `STATE.md` `iteration` equals HANDOFF **Iteration**
- [ ] If iteration > 1: HANDOFF **Latest review** points at `STATE.latest_code_review`
- [ ] HANDOFF Goal is real work (no idle sentinel / empty scope)
- [ ] `## Grok result` is cleared or set to `pending` (do not leave a previous **pass**)
- [ ] If iteration > 1: open findings table lists only unresolved blocking items
- [ ] Verify commands are real project commands (not bare `true` unless intentional smoke)

`invoke-grok.sh` **enforces** (hard fail):

- HANDOFF + STATE both `phase`/`STATE phase` = `CODE`
- Feature slug + iteration match and are non-null / ≥ 1
- No idle sentinel; `## Grok result` contains `pending`

Remaining checklist items (verify commands quality, findings table content) are orchestrator discipline.

## Context7 / index MCP

Use for understanding existing code. **Not** a source of product requirements. Requirements live in spec + handoff only.

## Architecture (v1, consumer-facing)

| Piece | Role |
|-------|------|
| `AGENTS.md` | Shared map for Claude + Grok |
| `CLAUDE.md` | Orchestrator duties + Karpathy principles |
| `GROK.md` | Thin coder contract |
| `docs/specs`, `docs/plans`, `docs/reviews` | Durable artifacts |
| `docs/agent-team/HANDOFF.md` | Active Grok task (anti-context-loss) |
| `docs/agent-team/STATE.md` | Phase + gates (one feature at a time) |
| Context7 / index MCP | Code lookup only |

## Copy into a new project

See [README.md](./README.md) for greenfield and brownfield install (do not blindly overwrite existing `CLAUDE.md`).
