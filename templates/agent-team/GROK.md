# GROK.md — Coder Contract

Thin contract for Grok CLI. Details live in linked files—do not invent scope.

## Read order (every turn)

1. `GROK.md` (this file)
2. `docs/agent-team/HANDOFF.md`
3. Linked review file(s) if HANDOFF lists them
4. Spec / plan **only** if HANDOFF asks you to (prefer handoff + findings on fix iterations)

Also respect shared map: `AGENTS.md`.

## Rules

1. **Scope = HANDOFF only.** No nice-to-haves, no drive-by refactors.
2. **Surgical changes.** Match existing style. Touch only required files.
3. **Verify.** Run the verify commands listed in HANDOFF. Record a short result (pass/fail + command) at the bottom of HANDOFF under `## Grok result` or in the commit message.
4. **Do not** edit `docs/agent-team/WORKFLOW.md` or templates unless HANDOFF explicitly says so.
5. **Context7 / index MCP:** use only to understand in-scope code. Never treat search hits as new requirements.
6. If HANDOFF is incomplete or contradictory, stop and report what is missing—do not guess product decisions.

## Success

Work is done when HANDOFF success criteria and verify commands pass, within listed scope.
