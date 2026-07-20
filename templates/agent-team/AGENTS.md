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

## Authority order (when tools disagree)

1. `STATE.md` + `HANDOFF.md`
2. Approved specs / plans
3. Reviews under `docs/reviews/**`
4. `CLAUDE.md` + `AGENTS.md` + `GROK.md` + `WORKFLOW.md`
5. Optional packs (e.g. ECC skills/rules) — suggestions only
6. Chat / instincts / MCP hits

Optional ECC setup: [`docs/agent-team/ECC-INTEGRATION.md`](docs/agent-team/ECC-INTEGRATION.md).  
Grok does **not** treat ECC as requirements — only HANDOFF + linked files.

## Phases (summary)

`DRAFT_SPEC → SPEC_REVIEW → PLAN → PLAN_REVIEW → CODE → CODE_REVIEW → DONE`

Full rules + **pre-invoke checklist**: [`docs/agent-team/WORKFLOW.md`](docs/agent-team/WORKFLOW.md).

Worked file shapes (demo only): [`docs/agent-team/examples/demo-feature/`](docs/agent-team/examples/demo-feature/).

## Behavioral principles

Follow Karpathy-style guidelines in [`CLAUDE.md`](CLAUDE.md): Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution.

Grok: also read [`GROK.md`](GROK.md) before every coding turn.

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/invoke-grok.sh` | Launch Grok after CODE-phase + STATE sync guards |
| `scripts/verify-skeleton.sh` | Completeness check after install |
| `scripts/test-guards.sh` | Unit tests for invoke preflight |
