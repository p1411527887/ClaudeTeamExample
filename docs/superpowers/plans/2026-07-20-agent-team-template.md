# Agent Team Template Implementation Plan

> **Status: IMPLEMENTED** (2026-07-20). Tasks 1–7 delivered on `master`; later polish (guards, install, ECC, VERSION) shipped as follow-ups.  
> Historical plan — do not re-execute unless resurrecting a greenfield rewrite. Checkboxes below are archival.

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a copy-paste skeleton at `templates/agent-team/` so new projects can run Claude (orchestrator) + Grok CLI (coder) with disk SSOT, HANDOFF, and light phase gates.

**Architecture:** All deliverable files live under `templates/agent-team/`. Users copy *contents* of that directory into a project root. Contracts (`AGENTS.md`, `CLAUDE.md`, `GROK.md`) plus `docs/agent-team/*` hold workflow, state, handoff, and templates. A thin `scripts/invoke-grok.sh` launches Grok with file-based context. A small verify script checks the skeleton is complete.

**Tech Stack:** Markdown contracts, bash scripts, optional Context7-style MCP example JSON. No application runtime.

## Global Constraints

- Packaging path is fixed: `templates/agent-team/` (contents → project root after copy).
- No app boilerplate (frontend/backend frameworks).
- One active feature in `STATE.md` (v1).
- Code review blocks DONE on open `critical` | `high` | `medium` only; `low`/`nit` deferred by default.
- Max code-review iterations: 5 then human escalate.
- Context7/index MCP is lookup only—not requirements authority.
- Do not duplicate long Karpathy text inside `GROK.md` (thin contract only).
- Prefer file links in HANDOFF over inlining full specs.
- Follow design: `docs/superpowers/specs/2026-07-20-agent-team-template-design.md`.

---

## File map (create)

| Path under `templates/agent-team/` | Responsibility |
|------------------------------------|----------------|
| `CLAUDE.md` | Orchestrator rules + Karpathy principles |
| `AGENTS.md` | Shared role matrix + SSOT map |
| `GROK.md` | Thin coder contract |
| `docs/agent-team/README.md` | How to copy/use the skeleton |
| `docs/agent-team/WORKFLOW.md` | Pipeline + gates |
| `docs/agent-team/STATE.md` | Starter state (idle) |
| `docs/agent-team/HANDOFF.md` | Starter empty handoff shell |
| `docs/agent-team/templates/*.template.md` | Spec/plan/review/handoff templates |
| `docs/specs/.gitkeep` | Specs output dir |
| `docs/plans/.gitkeep` | Plans output dir |
| `docs/reviews/spec/.gitkeep` | Spec/plan reviews |
| `docs/reviews/code/.gitkeep` | Code reviews |
| `scripts/invoke-grok.sh` | Claude → Grok CLI wrapper |
| `.mcp.json.example` | Context7-style MCP example |
| `scripts/verify-skeleton.sh` | Completeness check (also used as test) |

Also modify repo root:

| Path | Responsibility |
|------|----------------|
| `README.md` | Short section linking to template + design/plan |

---

### Task 1: Skeleton dirs + verify script (failing first)

**Files:**
- Create: `templates/agent-team/scripts/verify-skeleton.sh`
- Create: `templates/agent-team/docs/specs/.gitkeep`
- Create: `templates/agent-team/docs/plans/.gitkeep`
- Create: `templates/agent-team/docs/reviews/spec/.gitkeep`
- Create: `templates/agent-team/docs/reviews/code/.gitkeep`
- Create: `templates/agent-team/docs/agent-team/templates/.gitkeep`
- Test: run `templates/agent-team/scripts/verify-skeleton.sh` from repo root (or from template root as documented)

**Interfaces:**
- Consumes: nothing
- Produces: `verify-skeleton.sh` exits 0 only when all required paths exist; prints missing paths otherwise

- [ ] **Step 1: Write verify script that lists required files**

Create `templates/agent-team/scripts/verify-skeleton.sh`:

```bash
#!/usr/bin/env bash
# Verify agent-team skeleton completeness.
# Usage: from templates/agent-team/  →  ./scripts/verify-skeleton.sh
#    or: from repo root              →  ./templates/agent-team/scripts/verify-skeleton.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${ROOT}"

REQUIRED=(
  "CLAUDE.md"
  "AGENTS.md"
  "GROK.md"
  "docs/agent-team/README.md"
  "docs/agent-team/WORKFLOW.md"
  "docs/agent-team/STATE.md"
  "docs/agent-team/HANDOFF.md"
  "docs/agent-team/templates/SPEC.template.md"
  "docs/agent-team/templates/PLAN.template.md"
  "docs/agent-team/templates/SPEC_REVIEW.template.md"
  "docs/agent-team/templates/CODE_REVIEW.template.md"
  "docs/agent-team/templates/HANDOFF.template.md"
  "docs/specs/.gitkeep"
  "docs/plans/.gitkeep"
  "docs/reviews/spec/.gitkeep"
  "docs/reviews/code/.gitkeep"
  "scripts/invoke-grok.sh"
  ".mcp.json.example"
)

missing=0
for f in "${REQUIRED[@]}"; do
  if [[ ! -e "${f}" ]]; then
    echo "MISSING: ${f}"
    missing=1
  fi
done

if [[ "${missing}" -ne 0 ]]; then
  echo "verify-skeleton: FAIL"
  exit 1
fi

if [[ ! -x "scripts/invoke-grok.sh" ]]; then
  echo "MISSING executable bit: scripts/invoke-grok.sh"
  echo "verify-skeleton: FAIL"
  exit 1
fi

echo "verify-skeleton: OK (${#REQUIRED[@]} paths + invoke-grok executable)"
```

- [ ] **Step 2: Create empty placeholder dirs only**

```bash
mkdir -p templates/agent-team/scripts \
  templates/agent-team/docs/agent-team/templates \
  templates/agent-team/docs/specs \
  templates/agent-team/docs/plans \
  templates/agent-team/docs/reviews/spec \
  templates/agent-team/docs/reviews/code
touch templates/agent-team/docs/specs/.gitkeep \
  templates/agent-team/docs/plans/.gitkeep \
  templates/agent-team/docs/reviews/spec/.gitkeep \
  templates/agent-team/docs/reviews/code/.gitkeep
chmod +x templates/agent-team/scripts/verify-skeleton.sh
```

- [ ] **Step 3: Run verify — expect FAIL (missing contracts)**

Run:

```bash
./templates/agent-team/scripts/verify-skeleton.sh
```

Expected: exit 1, lines like `MISSING: CLAUDE.md`, ends with `verify-skeleton: FAIL`

- [ ] **Step 4: Commit**

```bash
git add templates/agent-team/scripts/verify-skeleton.sh \
  templates/agent-team/docs/specs/.gitkeep \
  templates/agent-team/docs/plans/.gitkeep \
  templates/agent-team/docs/reviews/spec/.gitkeep \
  templates/agent-team/docs/reviews/code/.gitkeep
git commit -m "test: add agent-team skeleton verify script (failing)"
```

---

### Task 2: Shared contracts — AGENTS.md + WORKFLOW.md + STATE.md

**Files:**
- Create: `templates/agent-team/AGENTS.md`
- Create: `templates/agent-team/docs/agent-team/WORKFLOW.md`
- Create: `templates/agent-team/docs/agent-team/STATE.md`
- Test: partial path existence; full green only after later tasks

**Interfaces:**
- Consumes: design §4–§5
- Produces: phase enum names used by HANDOFF and CLAUDE.md: `DRAFT_SPEC`, `SPEC_REVIEW`, `PLAN`, `PLAN_REVIEW`, `CODE`, `CODE_REVIEW`, `DONE`

- [ ] **Step 1: Write `templates/agent-team/AGENTS.md`**

```markdown
# Agent Team Contract (Shared)

This file is the **shared map** for Claude and Grok. Both tools must respect it.

## Roles

| Role | Who | Responsibility |
|------|-----|----------------|
| Orchestrator | Claude main session | Advance phases, write STATE/HANDOFF, call Grok CLI, enforce gates |
| Spec / Plan author | Claude subagent (Opus-class) | Write `docs/specs/*` and `docs/plans/*` |
| Reviewer | Claude subagent (Sonnet-class) | Write reviews under `docs/reviews/**` |
| Coder | Grok CLI | Implement and fix **only** what `docs/agent-team/HANDOFF.md` allows |

## Source of truth (SSOT)

| Source | Authority for |
|--------|----------------|
| `docs/specs/*` | Requirements, goals, non-goals |
| `docs/plans/*` | Implementation steps + verify commands |
| `docs/reviews/**` | Verdicts and findings |
| `docs/agent-team/HANDOFF.md` | Active coding task for Grok |
| `docs/agent-team/STATE.md` | Current phase and gates |
| Context7 / index MCP | Codebase lookup **only** — never invent requirements |

**Never** store sole requirements in chat memory or MCP memory alone.

## Phases (summary)

`DRAFT_SPEC → SPEC_REVIEW → PLAN → PLAN_REVIEW → CODE → CODE_REVIEW → DONE`

Full rules: [`docs/agent-team/WORKFLOW.md`](docs/agent-team/WORKFLOW.md).

## Behavioral principles

Follow Karpathy-style guidelines in [`CLAUDE.md`](CLAUDE.md): Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution.

Grok: also read [`GROK.md`](GROK.md) before every coding turn.
```

- [ ] **Step 2: Write `templates/agent-team/docs/agent-team/WORKFLOW.md`**

```markdown
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
```

- [ ] **Step 3: Write starter `templates/agent-team/docs/agent-team/STATE.md`**

```markdown
# Agent Team State

```yaml
feature: null
phase: IDLE
iteration: 0
spec: null
plan: null
latest_code_review: null
handoff: docs/agent-team/HANDOFF.md
gates:
  spec_review: pending
  plan_review: pending
  code_review: open
blockers: []
```

## Phase enum

`IDLE` | `DRAFT_SPEC` | `SPEC_REVIEW` | `PLAN` | `PLAN_REVIEW` | `CODE` | `CODE_REVIEW` | `DONE`

## Notes

- Only **one** active feature at a time (v1).
- Orchestrator updates this file after every phase.
```

- [ ] **Step 4: Commit**

```bash
git add templates/agent-team/AGENTS.md \
  templates/agent-team/docs/agent-team/WORKFLOW.md \
  templates/agent-team/docs/agent-team/STATE.md
git commit -m "docs: add shared agent-team AGENTS, WORKFLOW, STATE"
```

---

### Task 3: CLAUDE.md + GROK.md

**Files:**
- Create: `templates/agent-team/CLAUDE.md`
- Create: `templates/agent-team/GROK.md`

**Interfaces:**
- Consumes: phases and paths from Task 2
- Produces: orchestrator + coder contracts referenced by invoke-grok

- [ ] **Step 1: Write `templates/agent-team/CLAUDE.md`**

```markdown
# CLAUDE.md — Orchestrator

Behavioral guidelines to reduce common LLM coding mistakes, plus **agent-team orchestration**.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## Agent-team orchestration

You are the **orchestrator** for this project’s multi-agent workflow. Full rules: `docs/agent-team/WORKFLOW.md` and `AGENTS.md`.

### Duties

1. Use a strong subagent (Opus-class) to **write** specs and plans into `docs/specs/` and `docs/plans/` from templates under `docs/agent-team/templates/`.
2. Use a review subagent (Sonnet-class) for **spec, plan, and code** reviews into `docs/reviews/**`.
3. After every phase: write the artifact, update `docs/agent-team/STATE.md`, check gates before advancing.
4. For coding: write `docs/agent-team/HANDOFF.md`, then run `scripts/invoke-grok.sh`. Do **not** implement large features yourself when Grok is the coder (tiny orchestrator fixes OK).
5. Code-review loop: open critical/high/medium → rewrite HANDOFF with fix list only → Grok again. Stop at 5 iterations and escalate to human.

### HANDOFF mandatory fields

Goal, success criteria, links (spec/plan/review), scope, out-of-scope, open findings (if iter>1), verify commands.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.
```

- [ ] **Step 2: Write `templates/agent-team/GROK.md`**

```markdown
# GROK.md — Coder Contract

Thin contract for Grok CLI. Details live in linked files—do not invent scope.

## Read order (every turn)

1. `GROK.md` (this file)
2. `docs/agent-team/HANDOFF.md`
3. Linked review file(s) if HANDOFF lists them
4. Spec / plan **only** if HANDOFF asks you to (prefer handoff + findings on fix iterations)

Also respect shared map: `AGENTS.md`.

## Rules

1. **Scope = HANDOFF only.** No nice-to-haves, no drive-by refactors.
2. **Surgical changes.** Match existing style. Touch only required files.
3. **Verify.** Run the verify commands listed in HANDOFF. Record a short result (pass/fail + command) at the bottom of HANDOFF under `## Grok result` or in the commit message.
4. **Do not** edit `docs/agent-team/WORKFLOW.md` or templates unless HANDOFF explicitly says so.
5. **Context7 / index MCP:** use only to understand in-scope code. Never treat search hits as new requirements.
6. If HANDOFF is incomplete or contradictory, stop and report what is missing—do not guess product decisions.

## Success

Work is done when HANDOFF success criteria and verify commands pass, within listed scope.
```

- [ ] **Step 3: Commit**

```bash
git add templates/agent-team/CLAUDE.md templates/agent-team/GROK.md
git commit -m "docs: add CLAUDE orchestrator and thin GROK coder contracts"
```

---

### Task 4: Artifact templates

**Files:**
- Create: `templates/agent-team/docs/agent-team/templates/SPEC.template.md`
- Create: `templates/agent-team/docs/agent-team/templates/PLAN.template.md`
- Create: `templates/agent-team/docs/agent-team/templates/SPEC_REVIEW.template.md`
- Create: `templates/agent-team/docs/agent-team/templates/CODE_REVIEW.template.md`
- Create: `templates/agent-team/docs/agent-team/templates/HANDOFF.template.md`
- Delete if present: `templates/agent-team/docs/agent-team/templates/.gitkeep` (optional; not required by verify)

**Interfaces:**
- Consumes: required fields from design §6.4
- Produces: copy-paste templates for Opus/Sonnet/orchestrator

- [ ] **Step 1: Write SPEC.template.md**

```markdown
# Spec: <title>

- **Date:** YYYY-MM-DD
- **Slug:** <slug>
- **Author:** Opus (spec)
- **Status:** draft | approved

## Problem

<what hurts today>

## Goals

- 

## Non-goals

- 

## Requirements

1. 
2. 

## Success criteria

- [ ] 
- [ ] 

## Open questions

- 
```

- [ ] **Step 2: Write PLAN.template.md**

```markdown
# Plan: <title>

- **Date:** YYYY-MM-DD
- **Slug:** <slug>
- **Spec:** docs/specs/YYYY-MM-DD-<slug>-spec.md
- **Author:** Opus (plan)
- **Status:** draft | approved

## File touch list

- `path/to/file` — reason

## Steps

1. **<step name>**
   - Work: 
   - verify: <command or check>

2. **<step name>**
   - Work: 
   - verify: 

## Risks

| Risk | Mitigation |
|------|------------|
|  |  |
```

- [ ] **Step 3: Write SPEC_REVIEW.template.md**

```markdown
# Spec/Plan Review: <title>

- **Date:** YYYY-MM-DD
- **Target:** docs/specs/... or docs/plans/...
- **Reviewer:** Sonnet
- **Verdict:** APPROVED | CHANGES_REQUESTED

## Findings

| ID | Severity | Location | Fix |
|----|----------|----------|-----|
| F1 | high | §Requirements |  |

Severity: `critical` | `high` | `medium` | `low` | `nit`

## Questions

- 

## Notes

- 
```

- [ ] **Step 4: Write CODE_REVIEW.template.md**

```markdown
# Code Review: <title>

- **Date:** YYYY-MM-DD
- **Slug:** <slug>
- **Iteration:** N
- **Plan:** docs/plans/...
- **Reviewer:** Sonnet
- **Verdict:** APPROVED | CHANGES_REQUESTED

## Findings

| ID | Severity | File:line | Repro | Expected fix | Status |
|----|----------|-----------|-------|--------------|--------|
| C1 | high | src/foo.ts:12 |  |  | open |

Status: `open` | `fixed` | `deferred`

Blocking for DONE: any **open** `critical` | `high` | `medium`.  
`low` / `nit` default to `deferred` (non-blocking).

## Test gaps

- 

## Notes

- 
```

- [ ] **Step 5: Write HANDOFF.template.md**

```markdown
# HANDOFF — Grok coding turn

- **Feature slug:** 
- **Iteration:** 1
- **STATE phase:** CODE

## Goal

<1–3 sentences>

## Success criteria

- [ ] 
- [ ] 

## Links

- Spec: `docs/specs/...`
- Plan: `docs/plans/...`
- Latest review: `docs/reviews/...` (if any)

## In scope

- 

## Out of scope

- 

## Allowed files / constraints

- Surgical only; match existing style.
- Files: 

## Open findings (iteration > 1 only)

| ID | File | Expected fix |
|----|------|--------------|
|  |  |  |

## Verify commands

```bash
# e.g. npm test / pytest / go test ./...
```

## Grok result

<!-- Grok fills after run -->
```

- [ ] **Step 6: Commit**

```bash
git add templates/agent-team/docs/agent-team/templates/
git commit -m "docs: add agent-team spec/plan/review/handoff templates"
```

---

### Task 5: HANDOFF starter, invoke-grok.sh, MCP example, README

**Files:**
- Create: `templates/agent-team/docs/agent-team/HANDOFF.md`
- Create: `templates/agent-team/docs/agent-team/README.md`
- Create: `templates/agent-team/scripts/invoke-grok.sh`
- Create: `templates/agent-team/.mcp.json.example`

**Interfaces:**
- Consumes: `GROK.md`, `HANDOFF.md` paths
- Produces: `invoke-grok.sh` executable; env `GROK_CMD` default

- [ ] **Step 1: Write starter HANDOFF.md**

Copy structure from HANDOFF.template.md but mark idle:

```markdown
# HANDOFF — Grok coding turn

- **Feature slug:** null
- **Iteration:** 0
- **STATE phase:** IDLE

## Goal

_No active handoff. Orchestrator replaces this file before calling `scripts/invoke-grok.sh`._

## Success criteria

- [ ] (none)

## Links

- Spec: 
- Plan: 
- Latest review: 

## In scope

- 

## Out of scope

- 

## Allowed files / constraints

- 

## Open findings (iteration > 1 only)

| ID | File | Expected fix |
|----|------|--------------|
|  |  |  |

## Verify commands

```bash
true
```

## Grok result

<!-- Grok fills after run -->
```

- [ ] **Step 2: Write `docs/agent-team/README.md`**

```markdown
# Agent Team Template

Copy these files into a **new project root** so Claude (orchestrator) and Grok CLI (coder) share disk context.

## Install into a project

From this repo (example):

```bash
# dry-run: list files
rsync -a --dry-run templates/agent-team/ /path/to/your-project/

# copy contents into project root
rsync -a templates/agent-team/ /path/to/your-project/
# or:
# cp -R templates/agent-team/. /path/to/your-project/
```

After copy you should have `CLAUDE.md`, `AGENTS.md`, `GROK.md`, `docs/`, `scripts/invoke-grok.sh` at the project root.

## Daily loop (short)

1. Claude/Opus: write spec → Sonnet review  
2. Claude/Opus: write plan → Sonnet review  
3. Claude: fill `docs/agent-team/HANDOFF.md` + `STATE.md`  
4. Run `./scripts/invoke-grok.sh`  
5. Claude/Sonnet: code review → if blocking findings, update HANDOFF and repeat from 4  

Details: [WORKFLOW.md](./WORKFLOW.md). Design: repo `docs/superpowers/specs/2026-07-20-agent-team-template-design.md`.

## Grok CLI

```bash
export GROK_CMD="grok"   # or your grok-build binary
./scripts/invoke-grok.sh
./scripts/invoke-grok.sh "optional extra instruction"
```

## MCP (Context7-style)

Copy `.mcp.json.example` entries into your real MCP config. Index MCP is for code/docs lookup only.
```

- [ ] **Step 3: Write `scripts/invoke-grok.sh`**

```bash
#!/usr/bin/env bash
# Invoke Grok CLI with file-based handoff (no full-spec dump on argv).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

GROK_CMD="${GROK_CMD:-grok}"
EXTRA="${*:-}"

if [[ ! -f "docs/agent-team/HANDOFF.md" ]]; then
  echo "error: docs/agent-team/HANDOFF.md missing" >&2
  exit 1
fi

if [[ ! -f "GROK.md" ]]; then
  echo "error: GROK.md missing (run from project root after template copy)" >&2
  exit 1
fi

PROMPT=$(cat <<'EOF'
You are the coder for this repo. Follow GROK.md strictly.

Read in order:
1. GROK.md
2. docs/agent-team/HANDOFF.md
3. Any files linked from HANDOFF (spec, plan, reviews)

Implement only HANDOFF scope. Surgical changes. Run verify commands in HANDOFF.
Append a short ## Grok result section update to docs/agent-team/HANDOFF.md (pass/fail + commands).
EOF
)

if [[ -n "${EXTRA}" ]]; then
  PROMPT="${PROMPT}

Additional orchestrator note:
${EXTRA}"
fi

echo "invoke-grok: ROOT=${ROOT}"
echo "invoke-grok: GROK_CMD=${GROK_CMD}"
echo "invoke-grok: launching..."

# Prefer passing prompt as args; override GROK_CMD if your CLI differs, e.g.:
#   GROK_CMD='grok --print' ./scripts/invoke-grok.sh
exec ${GROK_CMD} "${PROMPT}"
```

- [ ] **Step 4: chmod + write `.mcp.json.example`**

```bash
chmod +x templates/agent-team/scripts/invoke-grok.sh
```

Create `templates/agent-team/.mcp.json.example`:

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"],
      "env": {}
    }
  },
  "_comment": "Example only. Merge into your Claude/Grok MCP config. Index MCP is lookup-only; requirements stay in docs/specs and HANDOFF."
}
```

- [ ] **Step 5: Commit**

```bash
git add templates/agent-team/docs/agent-team/HANDOFF.md \
  templates/agent-team/docs/agent-team/README.md \
  templates/agent-team/scripts/invoke-grok.sh \
  templates/agent-team/.mcp.json.example
git commit -m "feat: add invoke-grok handoff script and MCP example"
```

---

### Task 6: Green verify + root README pointer

**Files:**
- Modify: `README.md` (add short section at end, before License if present)
- Test: `templates/agent-team/scripts/verify-skeleton.sh`

- [ ] **Step 1: Run verify — expect OK**

```bash
./templates/agent-team/scripts/verify-skeleton.sh
```

Expected stdout:

```text
verify-skeleton: OK (18 paths + invoke-grok executable)
```

Exit code 0. If FAIL, create any still-missing files from Tasks 2–5 then re-run.

- [ ] **Step 2: Append section to root `README.md`**

Add before the `## License` section (or at end of file if no License):

```markdown
## Agent Team Template (Claude + Grok)

Copy-paste skeleton for multi-agent workflow (Claude orchestrates, Grok codes via CLI, disk SSOT + HANDOFF):

- Skeleton: [`templates/agent-team/`](./templates/agent-team/)
- How to copy: [`templates/agent-team/docs/agent-team/README.md`](./templates/agent-team/docs/agent-team/README.md)
- Design: [`docs/superpowers/specs/2026-07-20-agent-team-template-design.md`](./docs/superpowers/specs/2026-07-20-agent-team-template-design.md)
- Plan: [`docs/superpowers/plans/2026-07-20-agent-team-template.md`](./docs/superpowers/plans/2026-07-20-agent-team-template.md)

```bash
rsync -a templates/agent-team/ /path/to/your-project/
```
```

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "docs: link agent-team template from README"
```

---

### Task 7: Smoke check HANDOFF sections + script syntax

**Files:**
- Test only (no new production files unless fix needed)

- [ ] **Step 1: Bash syntax check**

```bash
bash -n templates/agent-team/scripts/invoke-grok.sh
bash -n templates/agent-team/scripts/verify-skeleton.sh
```

Expected: no output, exit 0.

- [ ] **Step 2: Required HANDOFF headings present**

```bash
for h in "## Goal" "## Success criteria" "## Links" "## In scope" "## Out of scope" "## Verify commands"; do
  grep -qF "$h" templates/agent-team/docs/agent-team/HANDOFF.md || { echo "missing $h"; exit 1; }
  grep -qF "$h" templates/agent-team/docs/agent-team/templates/HANDOFF.template.md || { echo "missing template $h"; exit 1; }
done
echo "handoff headings: OK"
```

Expected: `handoff headings: OK`

- [ ] **Step 3: Re-run full verify**

```bash
./templates/agent-team/scripts/verify-skeleton.sh
```

Expected: `verify-skeleton: OK`

- [ ] **Step 4: Final commit only if fixes were needed**

If Step 1–3 required file fixes:

```bash
git add templates/agent-team
git commit -m "fix: complete agent-team skeleton smoke checks"
```

If already green, no commit.

---

## Self-review (plan vs spec)

| Spec section | Task coverage |
|--------------|---------------|
| §4.2 Skeleton layout | Tasks 1–5 (all paths in verify list) |
| §4.3 SSOT map | Task 2 AGENTS + WORKFLOW |
| §5 Workflow + gates | Task 2 WORKFLOW + STATE |
| §5.4 HANDOFF fields | Tasks 4–5 templates + starter |
| §5.5 invoke-grok | Task 5 |
| §6.1–6.3 contracts | Tasks 2–3 |
| §6.4 templates | Task 4 |
| §7 Context7 MCP example | Task 5 `.mcp.json.example` |
| §8 `templates/agent-team/` packaging | All tasks; README Task 5–6 |
| §9 Success criteria | Tasks 6–7 verify + smoke |
| Severity low non-blocking | WORKFLOW + CODE_REVIEW.template |
| Max 5 iterations | WORKFLOW + CLAUDE.md |

Placeholder scan: none intentional.  
Type/path consistency: phase names and paths match across AGENTS, WORKFLOW, STATE, CLAUDE, GROK, invoke-grok.

---

## Execution handoff

Plan complete and saved to `docs/superpowers/plans/2026-07-20-agent-team-template.md`.

**Two execution options:**

1. **Subagent-Driven (recommended)** — fresh subagent per task, review between tasks  
2. **Inline Execution** — execute tasks in this session with checkpoints  

Which approach?
