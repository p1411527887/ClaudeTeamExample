# Agent Team State

```yaml
feature: null
size: null                   # micro | small | full — set before work (see WORKFLOW sizing)
phase: IDLE
iteration: 0
spec: null
plan: null
latest_spec_review: null
latest_plan_review: null
latest_code_review: null
handoff: docs/agent-team/HANDOFF.md
gates:
  human_spec: pending          # full/small: after Claude-clean spec; micro: n/a
  human_plan: pending          # full: required; small: approved or n/a; micro: n/a
  human_code_fix: n/a           # pending after blocking code review; approved before Grok fix
  spec_review: pending         # full/small: Claude-clean; micro: n/a
  plan_review: pending         # full: required; small: approved or n/a; micro: n/a
  code_review: pending
blockers: []
```

## Size enum

`micro` | `small` | `full` | `null` (unset — set before real work)

| Size | Spec/plan ritual | Grok via invoke-grok? | Claude implements product code? |
|------|------------------|------------------------|----------------------------------|
| `micro` | Skip (gates `n/a`) | **Yes** (thin HANDOFF) | **No** |
| `small` | Spec required; plan optional | **Yes** | **No** |
| `full` | Spec + plan required | **Yes** | **No** |

## Phase enum

`IDLE` | `DRAFT_SPEC` | `SPEC_REVIEW` | `WAIT_HUMAN_SPEC` | `PLAN` | `PLAN_REVIEW` | `WAIT_HUMAN_PLAN` | `CODE` | `CODE_REVIEW` | `WAIT_HUMAN_CODE_FIX` | `DONE`

## Gate values

- `spec_review` / `plan_review`: `pending` | `changes_requested` | `approved` | `n/a`
- `human_spec` / `human_plan`: `pending` | `approved` | `changes_requested` | `n/a`
- `human_code_fix`: `n/a` | `pending` | `approved`
- `code_review`: `pending` | `open` | `approved`

**micro:** set `human_spec`, `human_plan`, `spec_review`, `plan_review` all to **`n/a`** before first `invoke-grok`.

## Notes

- Only **one** active feature at a time (v1).
- **Grok is the only product coder** at every size; Claude orchestrates + reviews.
- Spec/plan loops max **10**; code fix loops max **10**.
- Before `invoke-grok.sh`: `size` set; `phase: CODE`; gates per size (WORKFLOW).
- Prefer unquoted YAML. First key match wins.
- Brownfield upgrades **preserve** this file and `HANDOFF.md`.
