# Agent Team Template

Copy these files into a **new project root** so Claude (orchestrator) and Grok CLI (coder) share disk context.

## Install into a project

From this repo (example):

```bash
# dry-run: list files
rsync -a --dry-run templates/agent-team/ /path/to/your-project/

# copy contents into project root
rsync -a templates/agent-team/ /path/to/your-project/
# or:
# cp -R templates/agent-team/. /path/to/your-project/
```

After copy you should have `CLAUDE.md`, `AGENTS.md`, `GROK.md`, `docs/`, `scripts/invoke-grok.sh` at the project root.

## Daily loop (short)

1. Claude/Opus: write spec → Sonnet review  
2. Claude/Opus: write plan → Sonnet review  
3. Claude: fill `docs/agent-team/HANDOFF.md` + `STATE.md`  
4. Run `./scripts/invoke-grok.sh`  
5. Claude/Sonnet: code review → if blocking findings, update HANDOFF and repeat from 4  

Details: [WORKFLOW.md](./WORKFLOW.md). Design: repo `docs/superpowers/specs/2026-07-20-agent-team-template-design.md`.

## Grok CLI

```bash
export GROK_CMD="grok"   # or your grok-build binary
./scripts/invoke-grok.sh
./scripts/invoke-grok.sh "optional extra instruction"
```

## MCP (Context7-style)

Copy `.mcp.json.example` entries into your real MCP config. Index MCP is for code/docs lookup only.
