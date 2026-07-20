#!/usr/bin/env bash
# Example adapter between agent-team invoke-grok.sh and your local Grok CLI.
#
# Usage:
#   1. Copy:  cp scripts/grok-wrapper.example.sh scripts/grok-wrapper.sh
#   2. Edit REAL_GROK / FLAGS below for your install (Grok Build, grok CLI, etc.)
#   3. chmod +x scripts/grok-wrapper.sh
#   4. export GROK_CMD="$(pwd)/scripts/grok-wrapper.sh"
#   5. ./scripts/invoke-grok.sh
#
# invoke-grok.sh passes the full prompt as argv:  $GROK_CMD "<prompt text>"
# This wrapper receives that as "$@" — typically a single argument.
set -euo pipefail

# --- configure for your machine ---
REAL_GROK="${REAL_GROK:-grok}"
# Examples (uncomment / adjust one):
# REAL_GROK="/usr/local/bin/grok"
# FLAGS=(--print)
# FLAGS=(-p)
FLAGS=()

if [[ "$#" -lt 1 ]]; then
  echo "usage: $0 <prompt>" >&2
  exit 2
fi

PROMPT="$1"
shift || true

# If your CLI wants stdin instead of argv:
# printf '%s\n' "${PROMPT}" | exec "${REAL_GROK}" "${FLAGS[@]}"
#
# Default: forward prompt as one argument (matches invoke-grok.sh).
exec "${REAL_GROK}" "${FLAGS[@]}" "${PROMPT}" "$@"
