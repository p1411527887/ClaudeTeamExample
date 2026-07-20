#!/usr/bin/env bash
# Invoke Grok CLI with file-based handoff (no full-spec dump on argv).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

GROK_CMD="${GROK_CMD:-grok}"
EXTRA="${*:-}"
HANDOFF="docs/agent-team/HANDOFF.md"
STATE="docs/agent-team/STATE.md"

if [[ ! -f "${HANDOFF}" ]]; then
  echo "error: ${HANDOFF} missing" >&2
  exit 1
fi

if [[ ! -f "GROK.md" ]]; then
  echo "error: GROK.md missing (run from project root after template copy)" >&2
  exit 1
fi

# --- Idle / empty-handoff guard (anti no-op coding turns) ---
if grep -qE '\*\*STATE phase:\*\*[[:space:]]*IDLE' "${HANDOFF}"; then
  echo "error: HANDOFF is IDLE — fill docs/agent-team/HANDOFF.md before invoking Grok" >&2
  exit 1
fi

if grep -qE '\*\*Feature slug:\*\*[[:space:]]*null\b' "${HANDOFF}"; then
  echo "error: HANDOFF feature slug is null — set an active feature first" >&2
  exit 1
fi

if grep -qF 'No active handoff' "${HANDOFF}"; then
  echo "error: HANDOFF still contains idle sentinel text — replace Goal before invoking Grok" >&2
  exit 1
fi

if [[ -f "${STATE}" ]] && grep -qE '^phase:[[:space:]]*IDLE\b' "${STATE}"; then
  echo "error: STATE.md phase is IDLE — set phase to CODE before invoking Grok" >&2
  exit 1
fi

PROMPT=$(cat <<'EOF'
You are the coder for this repo. Follow GROK.md strictly.

Read in order:
1. GROK.md
2. docs/agent-team/HANDOFF.md
3. Any files linked from HANDOFF (spec, plan, reviews)

Implement only HANDOFF scope. Surgical changes. Run verify commands in HANDOFF.
Update docs/agent-team/HANDOFF.md section ## Grok result with pass/fail + commands (replace any previous result).
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
# Word-split on GROK_CMD is intentional so multi-word commands work.
# shellcheck disable=SC2086
exec ${GROK_CMD} "${PROMPT}"
