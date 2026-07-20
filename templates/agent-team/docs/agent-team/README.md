# Agent Team Template

Copy these files into a **project root** so Claude (orchestrator) and Grok CLI (coder) share disk context.

> **Identity note (packaging repo vs consumer):**  
> In the *packaging* repository, root `CLAUDE.md` is pure Karpathy guidelines for this docs project.  
> **After copy**, consumer `CLAUDE.md` is the **orchestrator** contract from this template (Karpathy + agent-team duties).

## Install — greenfield (empty / new project)

```bash
# always dry-run first
rsync -a --dry-run templates/agent-team/ /path/to/your-project/

# copy contents into project root
rsync -a templates/agent-team/ /path/to/your-project/
# or: cp -R templates/agent-team/. /path/to/your-project/
```

After copy you should have `CLAUDE.md`, `AGENTS.md`, `GROK.md`, `docs/`, `scripts/invoke-grok.sh`, and optionally `.mcp.json.example` + `scripts/verify-skeleton.sh` at the project root.

## Install — brownfield (existing project)

**Do not** blind `rsync` over a repo that already has `CLAUDE.md`, `docs/`, or `scripts/` — it can silently overwrite project rules.

1. Dry-run and inspect collisions:
   ```bash
   rsync -a --dry-run templates/agent-team/ /path/to/your-project/
   ```
2. Prefer **selective copy**:
   ```bash
   mkdir -p /path/to/your-project/docs /path/to/your-project/scripts
   rsync -a templates/agent-team/docs/agent-team/ /path/to/your-project/docs/agent-team/
   rsync -a templates/agent-team/docs/specs/ /path/to/your-project/docs/specs/
   rsync -a templates/agent-team/docs/plans/ /path/to/your-project/docs/plans/
   rsync -a templates/agent-team/docs/reviews/ /path/to/your-project/docs/reviews/
   cp templates/agent-team/AGENTS.md templates/agent-team/GROK.md /path/to/your-project/
   cp templates/agent-team/scripts/invoke-grok.sh templates/agent-team/scripts/verify-skeleton.sh /path/to/your-project/scripts/
   chmod +x /path/to/your-project/scripts/invoke-grok.sh /path/to/your-project/scripts/verify-skeleton.sh
   # optional: cp templates/agent-team/.mcp.json.example /path/to/your-project/
   ```
3. **Merge `CLAUDE.md`** (do not replace without reading):
   - Keep your existing project rules.
   - Append the **Agent-team orchestration** section from `templates/agent-team/CLAUDE.md` (or copy that file to `CLAUDE.agent-team.md` and link it from your main instructions).
4. If you already have `AGENTS.md`, merge the role/SSOT tables instead of overwriting.

## Daily loop (short)

1. Claude/Opus: write spec → Sonnet review  
2. Claude/Opus: write plan → Sonnet review  
3. Claude: fill `docs/agent-team/HANDOFF.md` + `STATE.md` (pre-invoke checklist in [WORKFLOW.md](./WORKFLOW.md))  
4. Run `./scripts/invoke-grok.sh`  
5. Claude/Sonnet: code review → if blocking findings, update HANDOFF and repeat from 4  

Details: [WORKFLOW.md](./WORKFLOW.md).  
Worked sample (structure only): [examples/demo-feature/](./examples/demo-feature/).  
Architecture summary is in WORKFLOW (no packaging-repo path required).

## Grok CLI

```bash
# default (override if your binary differs)
export GROK_CMD="grok"

# common adapter examples (pick what matches your install):
# export GROK_CMD="grok --print"
# export GROK_CMD="grok -p"
# export GROK_CMD="/usr/local/bin/grok"

./scripts/invoke-grok.sh
./scripts/invoke-grok.sh "optional extra instruction"
```

`invoke-grok.sh` **refuses** IDLE / null-slug / idle-sentinel handoffs. Fill a real HANDOFF first.

If launch fails, fix `GROK_CMD` — that is a CLI adapter issue, not a broken workflow.

## MCP (Context7-style)

Merge the `mcpServers` entry from `.mcp.json.example` into your real MCP config (do not rename-and-run the example wholesale). Index MCP is for code/docs lookup only. See comments in the example file’s sibling note in WORKFLOW / this README.

## Verify skeleton (after install)

```bash
./scripts/verify-skeleton.sh   # if you copied it
```
