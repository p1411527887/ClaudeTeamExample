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
