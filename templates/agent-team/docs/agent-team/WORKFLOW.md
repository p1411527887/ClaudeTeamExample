# Agent Team Workflow

## Pipeline

1. **DRAFT_SPEC** — Opus writes `docs/specs/YYYY-MM-DD-<slug>-spec.md` from `templates/SPEC.template.md`.
2. **SPEC_REVIEW** — Sonnet writes `docs/reviews/spec/YYYY-MM-DD-<slug>.md`.
   - Gate: `APPROVED` or `CHANGES_REQUESTED` (return to step 1).
3. **PLAN** — Opus writes `docs/plans/YYYY-MM-DD-<slug>-plan.md` (only if spec approved).
4. **PLAN_REVIEW** — Sonnet writes `docs/reviews/spec/YYYY-MM-DD-<slug>-plan.md`.
   - Gate: same as spec review.
5. **CODE** — Orchestrator fills `HANDOFF.md`, updates `STATE.md`, runs `scripts/invoke-grok.sh`.
6. **CODE_REVIEW** — Sonnet writes `docs/reviews/code/YYYY-MM-DD-<slug>-iter-N.md`.
   - Open `critical` / `high` / `medium` → back to CODE with fix-only HANDOFF.
   - `low` / `nit` → mark `deferred`; do not block DONE by default.
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

## Context7 / index MCP

Use for understanding existing code. **Not** a source of product requirements. Requirements live in spec + handoff only.

## Copy into a new project

Copy the **contents** of this template directory to the project root (not the wrapper folder name). See [README.md](./README.md).
