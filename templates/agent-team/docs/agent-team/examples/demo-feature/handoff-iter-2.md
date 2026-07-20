# HANDOFF — Grok coding turn

- **Feature slug:** hello-export
- **Iteration:** 2
- **STATE phase:** CODE

## Goal

Fix open code-review findings only (no new features).

## Success criteria

- [x] C1 resolved: whitespace-only names rejected
- [x] Tests cover whitespace-only case
- [x] Verify commands pass

## Links

- Spec: `docs/agent-team/examples/demo-feature/spec.md`
- Plan: `docs/agent-team/examples/demo-feature/plan.md`
- Latest review: `docs/agent-team/examples/demo-feature/code-review-iter-1.md`

## In scope

- Fix C1 only.

## Out of scope

- Anything not listed in open findings.

## Allowed files / constraints

- Surgical only.
- Files: `src/greet.ts`, `src/greet.test.ts`

## Open findings (iteration > 1 only)

| ID | File | Expected fix |
|----|------|--------------|
| C1 | src/greet.ts | trim input; reject whitespace-only with clear error |

## Verify commands

```bash
npm test -- greet
```

## Grok result

- Status: pass (demo)
- Commands: `npm test -- greet` → exit 0
- Notes: C1 fixed
