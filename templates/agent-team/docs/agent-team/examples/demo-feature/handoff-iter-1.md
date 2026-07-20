# HANDOFF — Grok coding turn

- **Feature slug:** hello-export
- **Iteration:** 1
- **STATE phase:** CODE

## Goal

Implement `greet` and unit tests per approved plan.

## Success criteria

- [x] `greet("Ada")` → `Hello, Ada!`
- [x] Empty name errors clearly
- [x] Tests pass

## Links

- Spec: `docs/agent-team/examples/demo-feature/spec.md`
- Plan: `docs/agent-team/examples/demo-feature/plan.md`
- Latest review: (none yet)

## In scope

- `src/greet.ts`, `src/greet.test.ts` (illustrative paths)

## Out of scope

- CLI, HTTP, formatting drive-bys

## Allowed files / constraints

- Surgical only; match existing style.
- Files: `src/greet.ts`, `src/greet.test.ts`

## Open findings (iteration > 1 only)

| ID | File | Expected fix |
|----|------|--------------|
|  |  |  |

## Verify commands

```bash
# illustrative — use your project's test runner
npm test -- greet
```

## Grok result

- Status: pass (demo)
- Commands: `npm test -- greet` → exit 0
