# Agent Team Template Changelog

## 1.3.3 — 2026-07-20

- **Model routing (Opus vs Sonnet):** size-based author/reviewer rules in WORKFLOW, CLAUDE, AGENTS, USAGE.
  - **full** author = Opus required; **small** author = Sonnet default with escalate triggers; reviews = Sonnet.
  - Artifact templates record `Author: Opus | Sonnet`.

## 1.3.2 — 2026-07-20

- **Grok always codes** (including **micro**); Claude = spec/plan/review/orchestrate only.
- **micro:** thin HANDOFF + `invoke-grok`; pre-code gates `n/a` (no longer rejects micro).
- Docs/USAGE/guards updated.

## 1.3.1 — 2026-07-20

- Detailed Vietnamese user guide: `docs/agent-team/USAGE.md` (install, sizing, prompts, checklists, troubleshooting).

## 1.3.0 — 2026-07-20

- **Sizing:** `STATE.size` = `micro` | `small` | `full` picks the path (WORKFLOW + CLAUDE).
- **micro:** lightweight path (later: Grok always).
- **small:** spec ⟲ → human → Grok; plan optional.
- **full:** full pipeline.
- Guard tests for sizing.

## 1.2.3 — 2026-07-20

- Code fix ↔ CODE_REVIEW loop cap raised to **10** (same as spec/plan).

## 1.2.2 — 2026-07-20

- Spec/plan author↔review loop cap raised to **10** (code fix loop remains 5).

## 1.2.1 — 2026-07-20

- **Mandatory Claude review-until-clean** for spec and plan (loop on open critical/high/medium until APPROVED).
- Human `WAIT_HUMAN_SPEC` / `WAIT_HUMAN_PLAN` only **after** Claude gates `spec_review` / `plan_review` approved.
- SPEC_REVIEW template: Status column + blocking rules; STATE tracks `latest_spec_review` / `latest_plan_review`.

## 1.2.0 — 2026-07-20

- **Human-in-the-loop gates:** `WAIT_HUMAN_SPEC`, `WAIT_HUMAN_PLAN`, `WAIT_HUMAN_CODE_FIX`.
- Claude must stop after writing spec/plan and after code review with blocking findings; Grok fix only when `human_code_fix: approved`.
- `invoke-grok.sh` requires `human_spec` + `human_plan` approved; iteration ≥ 2 also requires `human_code_fix` approved.
- STATE gates + WORKFLOW/CLAUDE/AGENTS/README/demo updated; guard tests for human gates.

## 1.1.3 — 2026-07-20

- **invoke-grok harden:** strict `pending` line (reject pass/fail that mention pending); exact idle Goal sentinel; strip YAML quotes; normalize iteration ints; require `gates.spec_review` + `plan_review` = `approved` (case-insensitive); bare `pass`/`fail` lines rejected.
- **install harden:** auto empty→greenfield / any-files→brownfield; greenfield refuses non-empty unless `--force`; brownfield preserves `STATE.md`/`HANDOFF.md`; VERSION/CHANGELOG sidecars if app already owns them; GROK sidecar on skip.
- Demo DONE uses code-review iter-2 APPROVED; expanded `test-guards` + CI install safety cases.
- `verify-skeleton` accepts VERSION/CHANGELOG sidecars.
- Docs: README preflight + design hard-preflight aligned with invoker.

## 1.1.2 — 2026-07-20

- Standing rules for optional packs (5 rules): agent-team primary; Superpowers pre-CODE only; mental-model remaps; no dual Superpowers-execute + ECC multi-orch; adoption A → Superpowers light → ECC light.
- Mirrored in `CLAUDE.md`, `SUPERPOWERS-INTEGRATION.md`, `ECC-INTEGRATION.md`, `AGENTS.md`, `WORKFLOW.md`.

## 1.1.1 — 2026-07-20

- Optional Superpowers integration policy (`docs/agent-team/SUPERPOWERS-INTEGRATION.md`): CODE-path remap, skill enable/disable checklist, phase map.
- Orchestrator `CLAUDE.md` pocket checklist for Superpowers skills; AGENTS/WORKFLOW/GROK/README cross-links.

## 1.1.0 — 2026-07-20

- Hard preflight on `invoke-grok.sh` (CODE phase, STATE↔HANDOFF sync, pending Grok result).
- Packaging installer `scripts/install-agent-team.sh` (greenfield / brownfield / dry-run).
- Guard unit tests + GitHub Actions CI; expanded `verify-skeleton.sh`.
- Optional ECC integration policy (`docs/agent-team/ECC-INTEGRATION.md`) with authority order.
- Demo feature walkthrough; grok-wrapper example; install docs without broken post-copy links.
- VERSION + CHANGELOG for template tracking.

## 1.0.0 — 2026-07-20

- Initial skeleton: contracts, WORKFLOW/STATE/HANDOFF, templates, demo, MCP example.
