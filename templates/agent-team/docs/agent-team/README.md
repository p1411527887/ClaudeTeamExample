# Agent Team Template

**Version:** see [`VERSION`](../../VERSION) · **Changelog:** [`CHANGELOG.md`](../../CHANGELOG.md)

Disk-based multi-agent workflow: **Claude orchestrates**, **Grok codes** via CLI, shared SSOT (spec / plan / reviews / HANDOFF / STATE).

> **CLAUDE.md identity**  
> - *Packaging repo* root `CLAUDE.md` = Karpathy-only (this docs project).  
> - *After install into a consumer project*, `CLAUDE.md` = orchestrator contract from this template (Karpathy + agent-team duties).

---

## Where am I?

| You are… | What to do |
|----------|------------|
| In the **packaging repo** (directory `templates/agent-team/` exists at repo root) | Install with the command below from the **packaging repo root** (not from this file’s folder). |
| Already **inside a consumer project** (this file is at `docs/agent-team/README.md`) | Skeleton is installed. Use [Daily loop](#daily-loop-short). Do **not** re-run packaging install paths. |

**Packaging-only command** (run from packaging repo root — path is text, not a relative markdown link, so it stays valid after copy):

```bash
./scripts/install-agent-team.sh /path/to/your-project
```

Paths like `templates/agent-team/...` only work from the packaging repository root.

---

## Install from packaging repository (recommended)

From the **packaging repo root**:

```bash
# auto-detect greenfield vs brownfield
./scripts/install-agent-team.sh /path/to/your-project

# force full copy (overwrites collisions — empty projects only)
./scripts/install-agent-team.sh /path/to/your-project --greenfield

# existing project: selective copy, never overwrites CLAUDE.md
./scripts/install-agent-team.sh /path/to/your-project --brownfield

# preview
./scripts/install-agent-team.sh /path/to/your-project --brownfield --dry-run
```

Then:

```bash
cd /path/to/your-project
./scripts/verify-skeleton.sh
./scripts/test-guards.sh
```

### Manual greenfield (packaging repo only)

```bash
rsync -a --dry-run templates/agent-team/ /path/to/your-project/
rsync -a templates/agent-team/ /path/to/your-project/
chmod +x /path/to/your-project/scripts/*.sh
```

### Manual brownfield (packaging repo only)

**Do not** blind full-tree rsync over an existing `CLAUDE.md` / `docs/`.

Prefer:

```bash
./scripts/install-agent-team.sh /path/to/your-project --brownfield
```

If you must copy by hand: rsync only `docs/agent-team/`, `docs/specs|plans|reviews/`, `AGENTS.md`, `GROK.md`, `scripts/*`; **merge** CLAUDE (or keep `CLAUDE.agent-team.md` sidecar from the installer). If `AGENTS.md` already exists, merge role/SSOT tables manually (installer skips overwrite).

---

## Daily loop (short)

1. Claude/Opus: write spec → Sonnet review  
2. Claude/Opus: write plan → Sonnet review  
3. Claude: fill `docs/agent-team/HANDOFF.md` + `STATE.md` using the [pre-invoke checklist](./WORKFLOW.md#before-every-scriptsinvoke-groksh-checklist)  
4. `./scripts/invoke-grok.sh`  
5. Claude/Sonnet: code review → blocking findings → fix-only HANDOFF → step 4  

Details: [WORKFLOW.md](./WORKFLOW.md).  
Worked sample: [examples/demo-feature/](./examples/demo-feature/).  
Optional ECC (Claude skill pack) while keeping this pipeline primary: [ECC-INTEGRATION.md](./ECC-INTEGRATION.md).

---

## Grok CLI adapter

```bash
# default binary name
export GROK_CMD="grok"

# multi-word command (word-split intentional):
# export GROK_CMD="grok --print"
# export GROK_CMD="grok -p"

# absolute path
# export GROK_CMD="/usr/local/bin/grok"

# recommended for complex CLIs: copy and edit the example wrapper
# cp scripts/grok-wrapper.example.sh scripts/grok-wrapper.sh
# chmod +x scripts/grok-wrapper.sh
# # edit REAL_GROK inside the wrapper
# export GROK_CMD="$(pwd)/scripts/grok-wrapper.sh"

./scripts/invoke-grok.sh
./scripts/invoke-grok.sh "optional extra instruction"
```

See comments in [`scripts/grok-wrapper.example.sh`](../../scripts/grok-wrapper.example.sh).

### Preflight (enforced by `invoke-grok.sh`)

Refuses launch unless:

- HANDOFF `STATE phase` **and** STATE.md `phase` are both `CODE`
- Feature slug + iteration match between STATE and HANDOFF
- Iteration ≥ 1, slug not `null`
- No idle sentinel text
- `## Grok result` contains `pending` (clear stale pass/fail)

If launch fails after preflight, fix `GROK_CMD` / CLI install — that is adapter config, not workflow design.

---

## MCP (Context7-style)

Merge the `mcpServers` entry from project-root `.mcp.json.example` into your real MCP config. Do not rename-and-run the example wholesale. Index MCP = lookup only; requirements stay in specs + HANDOFF.

---

## Verify & tests (after install)

```bash
./scripts/verify-skeleton.sh   # required files + headings
./scripts/test-guards.sh       # invoke-grok preflight unit tests
```
