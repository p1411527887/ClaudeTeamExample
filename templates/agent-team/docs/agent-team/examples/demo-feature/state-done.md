# Agent Team State (demo snapshot — DONE)

```yaml
feature: hello-export
size: full
phase: DONE
iteration: 2
spec: docs/agent-team/examples/demo-feature/spec.md
plan: docs/agent-team/examples/demo-feature/plan.md
latest_code_review: docs/agent-team/examples/demo-feature/code-review-iter-2.md
handoff: docs/agent-team/HANDOFF.md
gates:
  human_spec: approved
  human_plan: approved
  human_code_fix: approved   # human approved fix list before Grok iter-2
  spec_review: approved
  plan_review: approved
  code_review: approved
blockers: []
```

Notes:

- Human approved spec and plan before first Grok; after iter-1 review (C1 open) human approved fix → Grok iter-2; latest review is iter-2 **APPROVED**.
- After studying the demo, reset live `STATE.md` / `HANDOFF.md` to IDLE for real work.
