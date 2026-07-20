# Agent Team Contract (Shared)

This file is the **shared map** for Claude and Grok. Both tools must respect it.

Template version: see [`VERSION`](VERSION) · changelog: [`CHANGELOG.md`](CHANGELOG.md).

## Roles

| Role | Who | Responsibility |
|------|-----|----------------|
| Human approver | You (project owner) | Approve spec, plan, and code-fix lists before Grok runs those steps |
| Orchestrator | Claude main session | Advance phases, **stop at WAIT_HUMAN_***, write STATE/HANDOFF, call Grok when gates allow — **does not implement product code** |
| Spec / Plan author | Claude subagent (Opus-class) | Write `docs/specs/*` and `docs/plans/*` (when size requires) |
| Reviewer | Claude subagent (Sonnet-class) | Spec/plan/code reviews; loops until clean where required |
| Coder | Grok CLI | **All** product implement/fix via `HANDOFF` — including **micro** |

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
5. Optional packs (Superpowers, ECC skills/rules, …) — suggestions only
6. Chat / instincts / MCP hits

Optional packs (pipeline stays primary):

- Superpowers: [`docs/agent-team/SUPERPOWERS-INTEGRATION.md`](docs/agent-team/SUPERPOWERS-INTEGRATION.md)
- ECC: [`docs/agent-team/ECC-INTEGRATION.md`](docs/agent-team/ECC-INTEGRATION.md)

**Pack standing rules (summary):** disk → contracts → skills → chat; Superpowers = pre-CODE/discipline only; `writing-plans` → `docs/plans/`; implement → HANDOFF + `invoke-grok.sh`; max **10** fix loops; no dual Superpowers-execute + ECC multi-orch defaults; adopt **A → Superpowers light → ECC light**.

Grok does **not** treat Superpowers/ECC as requirements — only HANDOFF + linked files.

## Sizing (summary)

| Size | Path |
|------|------|
| `micro` | Thin HANDOFF → **Grok** (gates pre-code `n/a`) → optional code review |
| `small` | Spec ⟲ → human → **Grok** → code review (plan optional) |
| `full` | Spec ⟲ → human → plan ⟲ → human → **Grok** → code review |

Claude **never** product-codes; Grok always does (every size).

Set `STATE.size` first. Details: [`docs/agent-team/WORKFLOW.md`](docs/agent-team/WORKFLOW.md) (sizing section).  
**User guide (Vietnamese):** [`docs/agent-team/USAGE.md`](docs/agent-team/USAGE.md).

## Phases (summary) — **full** size

`DRAFT_SPEC → SPEC_REVIEW ⟲ clean → WAIT_HUMAN_SPEC → PLAN → PLAN_REVIEW ⟲ clean → WAIT_HUMAN_PLAN → CODE → CODE_REVIEW → WAIT_HUMAN_CODE_FIX → … → DONE`

- **Claude must** review **spec** (and **plan** when required) until no blocking bugs.
- **Human must** approve at every required `WAIT_HUMAN_*`.

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
