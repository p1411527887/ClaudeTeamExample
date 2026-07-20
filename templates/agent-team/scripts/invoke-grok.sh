#!/usr/bin/env bash
# Invoke Grok CLI with file-based handoff (no full-spec dump on argv).
# Enforces CODE phase + STATE/HANDOFF sync before launch.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

GROK_CMD="${GROK_CMD:-grok}"
EXTRA="${*:-}"
HANDOFF="docs/agent-team/HANDOFF.md"
STATE="docs/agent-team/STATE.md"

die() {
  echo "error: $*" >&2
  exit 1
}

# Extract value after "**Label:**" (first match; allows list prefix "- ").
handoff_field() {
  local label="$1"
  local line
  line="$(grep -E "\*\*${label}:\*\*" "${HANDOFF}" | head -1 || true)"
  [[ -n "${line}" ]] || return 1
  echo "${line}" | sed -E "s/.*\*\*${label}:\*\*[[:space:]]*//; s/[[:space:]]+$//"
}

# First YAML-ish key at line start inside STATE.md (works with fenced yaml).
state_field() {
  local key="$1"
  local line
  line="$(grep -E "^${key}:" "${STATE}" | head -1 || true)"
  [[ -n "${line}" ]] || return 1
  echo "${line#*:}" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//; s/[[:space:]]+#.*$//'
}

[[ -f "${HANDOFF}" ]] || die "${HANDOFF} missing"
[[ -f "GROK.md" ]] || die "GROK.md missing (run from project root after template copy)"
[[ -f "${STATE}" ]] || die "${STATE} missing — cannot verify phase/gates"

# --- HANDOFF idle / format guards ---
if grep -qF 'No active handoff' "${HANDOFF}"; then
  die "HANDOFF still contains idle sentinel text — replace Goal before invoking Grok"
fi

h_phase="$(handoff_field 'STATE phase' || true)"
h_slug="$(handoff_field 'Feature slug' || true)"
h_iter="$(handoff_field 'Iteration' || true)"

[[ -n "${h_phase}" ]] || die "HANDOFF missing '**STATE phase:**' line"
[[ -n "${h_slug}" ]] || die "HANDOFF missing '**Feature slug:**' line"
[[ -n "${h_iter}" ]] || die "HANDOFF missing '**Iteration:**' line"

[[ "${h_phase}" == "CODE" ]] || die "HANDOFF STATE phase must be CODE (got '${h_phase}')"
[[ "${h_slug}" != "null" && "${h_slug}" != "" ]] || die "HANDOFF feature slug is null/empty — set an active feature first"
[[ "${h_iter}" =~ ^[0-9]+$ ]] || die "HANDOFF Iteration must be a non-negative integer (got '${h_iter}')"
[[ "${h_iter}" -ge 1 ]] || die "HANDOFF Iteration must be >= 1 for a coding turn (got '${h_iter}')"

# --- STATE guards ---
s_phase="$(state_field phase || true)"
s_slug="$(state_field feature || true)"
s_iter="$(state_field iteration || true)"

[[ -n "${s_phase}" ]] || die "STATE.md missing phase:"
[[ -n "${s_slug}" ]] || die "STATE.md missing feature:"
[[ -n "${s_iter}" ]] || die "STATE.md missing iteration:"

[[ "${s_phase}" == "CODE" ]] || die "STATE.md phase must be CODE before invoke (got '${s_phase}')"
[[ "${s_slug}" != "null" && "${s_slug}" != "" ]] || die "STATE.md feature is null/empty"
[[ "${s_iter}" =~ ^[0-9]+$ ]] || die "STATE.md iteration must be an integer (got '${s_iter}')"

# --- Sync STATE ↔ HANDOFF ---
[[ "${s_slug}" == "${h_slug}" ]] || die "feature mismatch: STATE='${s_slug}' vs HANDOFF='${h_slug}'"
[[ "${s_iter}" == "${h_iter}" ]] || die "iteration mismatch: STATE='${s_iter}' vs HANDOFF='${h_iter}'"

# --- Grok result must not look like a stale completed run ---
# Require the word "pending" somewhere under ## Grok result (before next ##).
if grep -qE '^## Grok result' "${HANDOFF}"; then
  grok_result_block="$(
    awk '
      /^## Grok result/ {grab=1; next}
      /^## / && grab {exit}
      grab {print}
    ' "${HANDOFF}"
  )"
  if ! echo "${grok_result_block}" | grep -qiE 'pending'; then
    die "HANDOFF ## Grok result must be reset to 'pending' before invoke (stale pass/fail left behind?)"
  fi
else
  die "HANDOFF missing '## Grok result' section — set it to pending"
fi

# Optional: warn if verify is still the idle smoke command (non-fatal)
if grep -qE '^\s*true\s*$' "${HANDOFF}"; then
  echo "warn: HANDOFF verify still uses bare 'true' — OK for smoke, replace for real work" >&2
fi

PROMPT=$(cat <<'EOF'
You are the coder for this repo. Follow GROK.md strictly.

Read in order:
1. GROK.md
2. docs/agent-team/HANDOFF.md
3. Any files linked from HANDOFF (spec, plan, reviews)

Implement only HANDOFF scope. Surgical changes. Run verify commands in HANDOFF.
Replace the ## Grok result section in docs/agent-team/HANDOFF.md with pass/fail + commands (do not leave previous results).
EOF
)

if [[ -n "${EXTRA}" ]]; then
  PROMPT="${PROMPT}

Additional orchestrator note:
${EXTRA}"
fi

echo "invoke-grok: ROOT=${ROOT}"
echo "invoke-grok: feature=${h_slug} iteration=${h_iter} phase=CODE"
echo "invoke-grok: GROK_CMD=${GROK_CMD}"
echo "invoke-grok: launching..."

# Word-split on GROK_CMD is intentional so multi-word commands work.
# Prefer: GROK_CMD='grok --print' or a wrapper script for complex CLIs.
# shellcheck disable=SC2086
exec ${GROK_CMD} "${PROMPT}"
