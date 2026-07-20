# ECC integration (optional)

This project’s **agent-team pipeline is primary**.  
[ECC](https://github.com/affaan-m/ECC) (Everything Claude Code / agent harness OS) is an **optional capability pack** for Claude — skills, rules, agents — not a second orchestrator.

Official sources only: [github.com/affaan-m/ECC](https://github.com/affaan-m/ECC), plugin `ecc@ecc`, [ecc.tools](https://ecc.tools). Do not install from unofficial mirrors.

## Authority order (highest first)

When anything conflicts, obey this order:

1. `docs/agent-team/STATE.md` + `docs/agent-team/HANDOFF.md`
2. Approved `docs/specs/*` and `docs/plans/*`
3. `docs/reviews/**` (open findings drive fix loops)
4. `CLAUDE.md` + `AGENTS.md` + `GROK.md` + `docs/agent-team/WORKFLOW.md`
5. ECC skills / agents / rules / slash commands (suggestions only)
6. Chat memory, continuous-learning “instincts”, MCP search hits

**Never** promote ECC output or instincts into requirements without writing them into a spec/plan/review artifact.

## Roles stay the same

| Role | Who | ECC may help? |
|------|-----|----------------|
| Orchestrator | Claude main session | Yes — use skills; still own STATE/HANDOFF |
| Spec / plan author | Opus-class subagent | Yes — research / structure; still write `docs/specs`, `docs/plans` |
| Reviewer | Sonnet-class (or ECC reviewer agents) | Yes — **must** write `docs/reviews/**` |
| Coder | Grok CLI via `scripts/invoke-grok.sh` | **No** — ECC does not replace Grok for feature CODE |

## Recommended install (ECC light)

Do **not** stack plugin + `install.sh --profile full`.

### A. Claude Code plugin (skills/commands)

```text
/plugin marketplace add https://github.com/affaan-m/ECC
/plugin install ecc@ecc
```

### B. Rules (minimal)

Copy only what you need (user-level or project-level):

```bash
# From a local clone of ECC
mkdir -p ~/.claude/rules/ecc   # or: .claude/rules/ecc inside the app
cp -R /path/to/ECC/rules/common ~/.claude/rules/ecc/
# Exactly one language/stack pack, e.g.:
cp -R /path/to/ECC/rules/typescript ~/.claude/rules/ecc/
```

### C. Avoid at first

| Surface | Why |
|---------|-----|
| `install.sh --profile full` after plugin | Duplicates skills/hooks |
| Full `rules/*` dump | Context bloat |
| Aggressive hooks (`hooks-runtime` strict) | Side effects outside HANDOFF |
| `/multi-*` / full orch as default | Competes with this pipeline |
| Auto-learned instincts as requirements | Can invent scope |

If setup is messy: remove plugin, run ECC uninstall/doctor from their repo, reinstall **light** only.

## Phase map (when to use ECC)

| Phase | Use ECC for | Still required here |
|-------|-------------|---------------------|
| `DRAFT_SPEC` | Research, search-first, domain skills | Write `docs/specs/...` from template |
| `SPEC_REVIEW` | Security/product sharpness | Write `docs/reviews/spec/...` |
| `PLAN` | TDD / step structure | Write `docs/plans/...` with `verify:` steps |
| `PLAN_REVIEW` | Architecture review agents | Write plan review artifact |
| `CODE` | Improve HANDOFF wording only | `STATE`+`HANDOFF` CODE → `./scripts/invoke-grok.sh` |
| `CODE_REVIEW` | code-reviewer / security-scan | Findings in `docs/reviews/code/...` |
| `DONE` | Optional stocktake | `STATE.phase=DONE` |

## Operating rules

1. **One phase machine:** only `STATE.md` advances the feature.
2. **One coder path for product features:** `scripts/invoke-grok.sh` when phase is `CODE`.
3. **ECC slash output is not done** until copied into `docs/specs`, `docs/plans`, or `docs/reviews` using project templates.
4. **Grok ignores ECC.** Coder reads `GROK.md` → `HANDOFF.md` → linked files only.
5. **MCP budget:** keep connectors few; index MCP is lookup-only (see WORKFLOW).

## Adoption ladder

| Tier | What you enable |
|------|-----------------|
| **A — Baseline** | Agent-team only (this template). No ECC. |
| **B — ECC light** | Plugin + `rules/common` + one language pack; few skills (e.g. search-first, tdd-workflow, security-review). |
| **C — ECC medium** | + reviewer/security agents whose output lands in `docs/reviews/**`; hooks only if `minimal` and intentional. |

Stay on A until one feature completes cleanly through DONE. Then add B.

## Conflict resolution cheat sheet

| Situation | Decision |
|-----------|----------|
| ECC skill suggests extra feature | Out of scope unless added to approved spec |
| ECC wants Claude to implement now | Refuse if Grok is coder; write HANDOFF instead |
| ECC review finds bugs | Write CODE_REVIEW artifact → fix-only HANDOFF → Grok |
| ECC instinct ≠ HANDOFF | HANDOFF wins |
| `/ecc:plan` vs Opus plan | Merge into **one** `docs/plans/*` file; one source of truth |

## References

- Pipeline: [WORKFLOW.md](./WORKFLOW.md)
- Shared map: [AGENTS.md](../../AGENTS.md)
- Orchestrator: [CLAUDE.md](../../CLAUDE.md)
- Coder: [GROK.md](../../GROK.md)
- ECC upstream: https://github.com/affaan-m/ECC
