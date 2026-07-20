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
  # VERSION / CHANGELOG: root or brownfield sidecars (app may own root VERSION)
  "VERSION_OR_SIDECAR"
  "CHANGELOG_OR_SIDECAR"
  "docs/agent-team/README.md"
  "docs/agent-team/USAGE.md"
  "docs/agent-team/WORKFLOW.md"
  "docs/agent-team/STATE.md"
  "docs/agent-team/HANDOFF.md"
  "docs/agent-team/ECC-INTEGRATION.md"
  "docs/agent-team/SUPERPOWERS-INTEGRATION.md"
  "docs/agent-team/templates/SPEC.template.md"
  "docs/agent-team/templates/PLAN.template.md"
  "docs/agent-team/templates/SPEC_REVIEW.template.md"
  "docs/agent-team/templates/CODE_REVIEW.template.md"
  "docs/agent-team/templates/HANDOFF.template.md"
  "docs/agent-team/examples/demo-feature/README.md"
  "docs/specs/.gitkeep"
  "docs/plans/.gitkeep"
  "docs/reviews/spec/.gitkeep"
  "docs/reviews/code/.gitkeep"
  "scripts/invoke-grok.sh"
  "scripts/test-guards.sh"
  "scripts/grok-wrapper.example.sh"
  ".mcp.json.example"
)

missing=0
for f in "${REQUIRED[@]}"; do
  if [[ "${f}" == "VERSION_OR_SIDECAR" ]]; then
    if [[ ! -e "VERSION" && ! -e "VERSION.agent-team" ]]; then
      echo "MISSING: VERSION (or VERSION.agent-team sidecar)"
      missing=1
    fi
    continue
  fi
  if [[ "${f}" == "CHANGELOG_OR_SIDECAR" ]]; then
    if [[ ! -e "CHANGELOG.md" && ! -e "CHANGELOG.agent-team.md" ]]; then
      echo "MISSING: CHANGELOG.md (or CHANGELOG.agent-team.md sidecar)"
      missing=1
    fi
    continue
  fi
  if [[ ! -e "${f}" ]]; then
    echo "MISSING: ${f}"
    missing=1
  fi
done

if [[ "${missing}" -ne 0 ]]; then
  echo "verify-skeleton: FAIL"
  exit 1
fi

for exe in scripts/invoke-grok.sh scripts/test-guards.sh scripts/verify-skeleton.sh; do
  if [[ ! -x "${exe}" ]]; then
    echo "MISSING executable bit: ${exe}"
    missing=1
  fi
done

if [[ "${missing}" -ne 0 ]]; then
  echo "verify-skeleton: FAIL"
  exit 1
fi

# Required headings in idle HANDOFF + template
for h in "## Goal" "## Success criteria" "## Links" "## In scope" "## Out of scope" "## Verify commands" "## Grok result"; do
  grep -qF "$h" docs/agent-team/HANDOFF.md || { echo "MISSING heading in HANDOFF.md: $h"; missing=1; }
  grep -qF "$h" docs/agent-team/templates/HANDOFF.template.md || { echo "MISSING heading in HANDOFF.template.md: $h"; missing=1; }
done

if [[ "${missing}" -ne 0 ]]; then
  echo "verify-skeleton: FAIL"
  exit 1
fi

echo "verify-skeleton: OK (${#REQUIRED[@]} paths + executables + HANDOFF headings)"
