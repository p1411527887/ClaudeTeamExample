# GROK.md — Coder Contract

Thin contract for Grok CLI. Details live in linked files—do not invent scope.

## Read order (every turn)

1. `GROK.md` (this file)
2. `docs/agent-team/HANDOFF.md`
3. Linked review file(s) if HANDOFF lists them
4. Spec / plan **only** if HANDOFF asks you to (prefer handoff + findings on fix iterations)

Also respect shared map: `AGENTS.md`.

Optional Claude-side packs (Superpowers, ECC, …) are **not** requirements for you. Only HANDOFF + linked files define scope.

## Rules

1. **Scope = HANDOFF only.** No nice-to-haves, no drive-by refactors. Ignore Superpowers/ECC/skills unless HANDOFF explicitly links a file.
2. **Surgical changes.** Match existing style. Touch only required files.
3. **Verify.** Run the verify commands listed in HANDOFF. Replace `## Grok result` (was `pending`) with pass/fail + commands. Do not leave a prior result sitting there.
4. **Do not** edit `docs/agent-team/WORKFLOW.md` or templates unless HANDOFF explicitly says so.
5. **Context7 / index MCP:** use only to understand in-scope code. Never treat search hits as new requirements.
6. If HANDOFF is incomplete or contradictory, stop and report what is missing—do not guess product decisions.

## Success

Work is done when HANDOFF success criteria and verify commands pass, within listed scope.
