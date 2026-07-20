# Code Review: Hello export

- **Date:** 2026-07-20
- **Slug:** hello-export
- **Iteration:** 1
- **Plan:** examples/demo-feature/plan.md
- **Reviewer:** Sonnet
- **Verdict:** CHANGES_REQUESTED

## Findings

| ID | Severity | File:line | Repro | Expected fix | Status |
|----|----------|-----------|-------|--------------|--------|
| C1 | medium | src/greet.ts:1 | empty string `"   "` accepted | trim and reject whitespace-only | open |

Blocking for DONE: any **open** `critical` | `high` | `medium`.

## Test gaps

- Whitespace-only name case.

## Notes

- Happy path looks fine.
