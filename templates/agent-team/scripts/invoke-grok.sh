#!/usr/bin/env bash
# Invoke Grok CLI with file-based handoff (no full-spec dump on argv).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

GROK_CMD="${GROK_CMD:-grok}"
EXTRA="${*:-}"

if [[ ! -f "docs/agent-team/HANDOFF.md" ]]; then
  echo "error: docs/agent-team/HANDOFF.md missing" >&2
  exit 1
fi

if [[ ! -f "GROK.md" ]]; then
  echo "error: GROK.md missing (run from project root after template copy)" >&2
  exit 1
fi

PROMPT=$(cat <<'EOF'
You are the coder for this repo. Follow GROK.md strictly.

Read in order:
1. GROK.md
2. docs/agent-team/HANDOFF.md
3. Any files linked from HANDOFF (spec, plan, reviews)

Implement only HANDOFF scope. Surgical changes. Run verify commands in HANDOFF.
Append a short ## Grok result section update to docs/agent-team/HANDOFF.md (pass/fail + commands).
EOF
)

if [[ -n "${EXTRA}" ]]; then
  PROMPT="${PROMPT}

Additional orchestrator note:
${EXTRA}"
fi

echo "invoke-grok: ROOT=${ROOT}"
echo "invoke-grok: GROK_CMD=${GROK_CMD}"
echo "invoke-grok: launching..."

# Prefer passing prompt as args; override GROK_CMD if your CLI differs, e.g.:
#   GROK_CMD='grok --print' ./scripts/invoke-grok.sh
exec ${GROK_CMD} "${PROMPT}"
