# Plan: Hello export

- **Date:** 2026-07-20
- **Slug:** hello-export
- **Spec:** examples/demo-feature/spec.md
- **Author:** Opus (plan)
- **Status:** approved

## File touch list

- `src/greet.ts` — implement function
- `src/greet.test.ts` — unit tests

## Steps

1. **Add greet function**
   - Work: implement `greet` per spec
   - verify: unit tests pass

2. **Add tests**
   - Work: happy path + empty name
   - verify: test runner green

## Risks

| Risk | Mitigation |
|------|------------|
| Over-engineering | Keep pure function only |
