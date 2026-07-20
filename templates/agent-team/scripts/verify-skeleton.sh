#!/usr/bin/env bash
# Verify agent-team skeleton completeness.
# Usage: from templates/agent-team/  →  ./scripts/verify-skeleton.sh
#    or: from repo root              →  ./templates/agent-team/scripts/verify-skeleton.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${ROOT}"

REQUIRED=(
  "CLAUDE.md"
  "AGENTS.md"
  "GROK.md"
  "docs/agent-team/README.md"
  "docs/agent-team/WORKFLOW.md"
  "docs/agent-team/STATE.md"
  "docs/agent-team/HANDOFF.md"
  "docs/agent-team/templates/SPEC.template.md"
  "docs/agent-team/templates/PLAN.template.md"
  "docs/agent-team/templates/SPEC_REVIEW.template.md"
  "docs/agent-team/templates/CODE_REVIEW.template.md"
  "docs/agent-team/templates/HANDOFF.template.md"
  "docs/specs/.gitkeep"
  "docs/plans/.gitkeep"
  "docs/reviews/spec/.gitkeep"
  "docs/reviews/code/.gitkeep"
  "scripts/invoke-grok.sh"
  ".mcp.json.example"
)

missing=0
for f in "${REQUIRED[@]}"; do
  if [[ ! -e "${f}" ]]; then
    echo "MISSING: ${f}"
    missing=1
  fi
done

if [[ "${missing}" -ne 0 ]]; then
  echo "verify-skeleton: FAIL"
  exit 1
fi

if [[ ! -x "scripts/invoke-grok.sh" ]]; then
  echo "MISSING executable bit: scripts/invoke-grok.sh"
  echo "verify-skeleton: FAIL"
  exit 1
fi

echo "verify-skeleton: OK (${#REQUIRED[@]} paths + invoke-grok executable)"
