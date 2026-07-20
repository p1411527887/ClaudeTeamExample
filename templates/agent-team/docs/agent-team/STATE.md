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
  code_review: pending   # use open only while in CODE_REVIEW with unresolved findings
blockers: []
```

## Phase enum

`IDLE` | `DRAFT_SPEC` | `SPEC_REVIEW` | `PLAN` | `PLAN_REVIEW` | `CODE` | `CODE_REVIEW` | `DONE`

## Gate values

- `spec_review` / `plan_review`: `pending` | `approved` | `changes_requested`  
  (map review verdicts: `APPROVED` → `approved`, `CHANGES_REQUESTED` → `changes_requested`)
- `code_review`: `pending` | `open` | `approved`

## Notes

- Only **one** active feature at a time (v1).
- Orchestrator updates this file after every phase.
- Before `invoke-grok.sh`: `phase` must be `CODE` and must match HANDOFF.
