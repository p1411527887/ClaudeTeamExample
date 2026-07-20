# Demo feature walkthrough (structure only)

Fictional feature `hello-export` showing the **file shapes** after a **full**-size loop.  
Not real product code — copy patterns, then reset `STATE` / `HANDOFF` for real work.  
(See `WORKFLOW.md` sizing for **micro** / **small** shortcuts.)

| Phase | Sample artifact |
|-------|-----------------|
| Spec | [`spec.md`](./spec.md) |
| Spec review | [`spec-review.md`](./spec-review.md) |
| Plan | [`plan.md`](./plan.md) |
| Plan review | [`plan-review.md`](./plan-review.md) |
| Code handoff (iter 1) | [`handoff-iter-1.md`](./handoff-iter-1.md) |
| Code review (iter 1, changes) | [`code-review-iter-1.md`](./code-review-iter-1.md) |
| Fix handoff (iter 2) | [`handoff-iter-2.md`](./handoff-iter-2.md) |
| Code review (iter 2, approved) | [`code-review-iter-2.md`](./code-review-iter-2.md) |
| Final state snapshot | [`state-done.md`](./state-done.md) |

**How to learn**

1. Read artifacts in order.
2. In a real run: Claude **reviews spec/plan until clean**, then **stops for you**; after code review with bugs, stops again — your approve unlocks the next step / Grok fix.
3. Notice fix loop: iter-2 HANDOFF lists **only** open findings, not a full restate of the feature.
4. DONE only after a code review with **no open** blocking findings (`code-review-iter-2` APPROVED, not iter-1).
5. For a real feature: copy templates from `../templates/`, not these samples, into `docs/specs/` etc.
