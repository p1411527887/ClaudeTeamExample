#!/usr/bin/env bash
# Invoke Grok CLI with file-based handoff (no full-spec dump on argv).
# Enforces CODE phase + STATE/HANDOFF sync + gates + pending result before launch.
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

# Strip optional surrounding single/double quotes and trailing comments.
strip_value() {
  local v="$1"
  v="$(echo "${v}" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//; s/[[:space:]]+#.*$//')"
  # strip one layer of matching quotes
  if [[ "${v}" =~ ^\"(.*)\"$ ]]; then
    v="${BASH_REMATCH[1]}"
  elif [[ "${v}" =~ ^\'(.*)\'$ ]]; then
    v="${BASH_REMATCH[1]}"
  fi
  echo "${v}"
}

# Extract value after "**Label:**" (first match; allows list prefix "- ").
handoff_field() {
  local label="$1"
  local line
  line="$(grep -E "\*\*${label}:\*\*" "${HANDOFF}" | head -1 || true)"
  [[ -n "${line}" ]] || return 1
  strip_value "$(echo "${line}" | sed -E "s/.*\*\*${label}:\*\*[[:space:]]*//")"
}

# First YAML-ish key at line start inside STATE.md (works with fenced yaml).
state_field() {
  local key="$1"
  local line
  line="$(grep -E "^${key}:" "${STATE}" | head -1 || true)"
  [[ -n "${line}" ]] || return 1
  strip_value "${line#*:}"
}

# Nested or indented keys (e.g. gates.spec_review). First match wins — avoid duplicates.
gate_field() {
  local key="$1"
  local line
  line="$(grep -E "^[[:space:]]*${key}:" "${STATE}" | head -1 || true)"
  [[ -n "${line}" ]] || return 1
  strip_value "$(echo "${line}" | sed -E "s/^[[:space:]]*${key}:[[:space:]]*//")"
}

# Normalize non-negative integer string (allows leading zeros) → decimal base-10.
normalize_uint() {
  local raw="$1"
  [[ "${raw}" =~ ^[0-9]+$ ]] || return 1
  echo $((10#${raw}))
}

[[ -f "${HANDOFF}" ]] || die "${HANDOFF} missing"
[[ -f "GROK.md" ]] || die "GROK.md missing (run from project root after template copy)"
[[ -f "${STATE}" ]] || die "${STATE} missing — cannot verify phase/gates"

# --- HANDOFF idle sentinel (exact template Goal line only; not free-text mentions) ---
if grep -qE '^_No active handoff\. Orchestrator replaces this file before calling' "${HANDOFF}"; then
  die "HANDOFF still contains idle sentinel Goal — replace Goal before invoking Grok"
fi
if grep -qE '^[[:space:]]*_No active handoff\. Orchestrator replaces this file' "${HANDOFF}"; then
  die "HANDOFF still contains idle sentinel Goal — replace Goal before invoking Grok"
fi

h_phase="$(handoff_field 'STATE phase' || true)"
h_slug="$(handoff_field 'Feature slug' || true)"
h_iter_raw="$(handoff_field 'Iteration' || true)"

[[ -n "${h_phase}" ]] || die "HANDOFF missing '**STATE phase:**' line"
[[ -n "${h_slug}" ]] || die "HANDOFF feature slug is empty — set '**Feature slug:**' to an active feature"
[[ -n "${h_iter_raw}" ]] || die "HANDOFF missing '**Iteration:**' line"

[[ "${h_phase}" == "CODE" ]] || die "HANDOFF STATE phase must be CODE (got '${h_phase}')"
[[ "${h_slug}" != "null" ]] || die "HANDOFF feature slug is null — set an active feature first"

h_iter="$(normalize_uint "${h_iter_raw}" || true)"
[[ -n "${h_iter}" ]] || die "HANDOFF Iteration must be a non-negative integer (got '${h_iter_raw}')"
[[ "${h_iter}" -ge 1 ]] || die "HANDOFF Iteration must be >= 1 for a coding turn (got '${h_iter}')"

# --- STATE guards ---
s_phase="$(state_field phase || true)"
s_slug="$(state_field feature || true)"
s_iter_raw="$(state_field iteration || true)"

[[ -n "${s_phase}" ]] || die "STATE.md missing phase:"
[[ -n "${s_slug}" ]] || die "STATE.md missing feature:"
[[ -n "${s_iter_raw}" ]] || die "STATE.md missing iteration:"

[[ "${s_phase}" == "CODE" ]] || die "STATE.md phase must be CODE before invoke (got '${s_phase}')"
[[ "${s_slug}" != "null" && "${s_slug}" != "" ]] || die "STATE.md feature is null/empty"

s_iter="$(normalize_uint "${s_iter_raw}" || true)"
[[ -n "${s_iter}" ]] || die "STATE.md iteration must be an integer (got '${s_iter_raw}')"

# --- Sync STATE ↔ HANDOFF ---
[[ "${s_slug}" == "${h_slug}" ]] || die "feature mismatch: STATE='${s_slug}' vs HANDOFF='${h_slug}'"
[[ "${s_iter}" == "${h_iter}" ]] || die "iteration mismatch: STATE='${s_iter}' vs HANDOFF='${h_iter}' (normalized)"

# --- Sizing: micro|small|full all may invoke Grok (Claude never implements product code) ---
s_size_raw="$(state_field size || true)"
s_size="$(echo "${s_size_raw:-}" | tr '[:upper:]' '[:lower:]')"
[[ -n "${s_size}" && "${s_size}" != "null" ]] || die "STATE.md size must be set to micro|small|full before invoke (got '${s_size_raw:-empty}')"
case "${s_size}" in
  micro|small|full) ;;
  *)
    die "STATE.md size must be micro|small|full (got '${s_size_raw}')"
    ;;
esac

# --- Human + review gates (by size) ---
require_approved_gate() {
  local key="$1"
  local label="$2"
  local raw lower
  raw="$(gate_field "${key}" || true)"
  [[ -n "${raw}" ]] || die "STATE.md missing gates.${key} (${label})"
  lower="$(echo "${raw}" | tr '[:upper:]' '[:lower:]')"
  [[ "${lower}" == "approved" ]] || die "STATE.md gates.${key} must be approved before invoke (got '${raw}') — wait for human/orchestrator"
}

# approved OR n/a
require_approved_or_na_gate() {
  local key="$1"
  local label="$2"
  local raw lower
  raw="$(gate_field "${key}" || true)"
  [[ -n "${raw}" ]] || die "STATE.md missing gates.${key} (${label})"
  lower="$(echo "${raw}" | tr '[:upper:]' '[:lower:]')"
  if [[ "${lower}" == "n/a" || "${lower}" == "na" ]]; then
    return 0
  fi
  [[ "${lower}" == "approved" ]] || die "STATE.md gates.${key} must be approved or n/a before invoke (got '${raw}') — ${label}"
}

if [[ "${s_size}" == "micro" ]]; then
  # Lightweight: no full spec/plan ritual; all pre-code gates may be n/a
  require_approved_or_na_gate human_spec "micro: human_spec usually n/a"
  require_approved_or_na_gate human_plan "micro: human_plan usually n/a"
  require_approved_or_na_gate spec_review "micro: spec_review usually n/a"
  require_approved_or_na_gate plan_review "micro: plan_review usually n/a"
elif [[ "${s_size}" == "full" ]]; then
  require_approved_gate human_spec "human must approve the spec first"
  require_approved_gate spec_review "Claude spec review must be clean (approved)"
  require_approved_gate human_plan "human must approve the plan before Grok CODE (full size)"
  require_approved_gate plan_review "Claude plan review must be clean (full size)"
else
  # small
  require_approved_gate human_spec "human must approve the spec first"
  require_approved_gate spec_review "Claude spec review must be clean (approved)"
  require_approved_or_na_gate human_plan "small size: approve plan or set n/a if plan skipped"
  require_approved_or_na_gate plan_review "small size: plan review approved or n/a if plan skipped"
fi

# Fix loops (iteration >= 2): human must have approved the code-review findings list
if [[ "${h_iter}" -ge 2 ]]; then
  hfix="$(gate_field human_code_fix || true)"
  [[ -n "${hfix}" ]] || die "STATE.md missing gates.human_code_fix (required when iteration >= 2)"
  hfix_l="$(echo "${hfix}" | tr '[:upper:]' '[:lower:]')"
  if [[ "${hfix_l}" == "n/a" || "${hfix_l}" == "na" ]]; then
    die "STATE.md gates.human_code_fix is n/a but iteration=${h_iter} — set pending then human-approved before fix"
  fi
  [[ "${hfix_l}" == "approved" ]] || die "STATE.md gates.human_code_fix must be approved before Grok fix (got '${hfix}') — stop at WAIT_HUMAN_CODE_FIX until human approves"
fi

# --- Grok result must be a fresh pending (not a stale pass/fail that still mentions pending) ---
# Heading must be exactly "## Grok result" (optional trailing space), not "## Grok result pending"
if ! grep -qE '^## Grok result[[:space:]]*$' "${HANDOFF}"; then
  die "HANDOFF missing '## Grok result' heading (own line) — set section body to pending"
fi

grok_result_block="$(
  awk '
    /^## Grok result[[:space:]]*$/ {grab=1; next}
    /^## / && grab {exit}
    grab {print}
  ' "${HANDOFF}"
)"

# Collapse to non-empty, non-comment lines for checks
grok_result_body="$(
  echo "${grok_result_block}" | sed -E 's/[[:space:]]+$//' | grep -vE '^[[:space:]]*$' | grep -vE '^[[:space:]]*<!--' || true
)"

if [[ -z "${grok_result_body}" ]]; then
  die "HANDOFF ## Grok result body is empty — set it to pending"
fi

# Reject completed-looking results even if the word "pending" appears in prose
if echo "${grok_result_body}" | grep -qiE '(^|[[:space:]])(status|result)[[:space:]]*:[[:space:]]*(pass|fail|passed|failed)\b'; then
  die "HANDOFF ## Grok result looks completed (pass/fail) — reset body to pending only before invoke"
fi
# Bare pass/fail lines (common short Grok result style)
if echo "${grok_result_body}" | grep -qiE '^[[:space:]]*(-[[:space:]]*)?`?(pass|fail|passed|failed)`?[[:space:]]*$'; then
  die "HANDOFF ## Grok result looks completed (pass/fail) — reset body to pending only before invoke"
fi

# Require at least one line that is exactly "pending" (optional bullets / backticks)
if ! echo "${grok_result_body}" | grep -qiE '^[[:space:]]*(-[[:space:]]*)?`?pending`?[[:space:]]*$'; then
  die "HANDOFF ## Grok result must contain a line that is only 'pending' (stale pass/fail left behind?)"
fi

# Optional: warn if verify is still the idle smoke command (non-fatal)
if awk '
  /^## Verify commands/ {grab=1; next}
  /^## / && grab {exit}
  grab {print}
' "${HANDOFF}" | grep -qE '^\s*true\s*$'; then
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
echo "invoke-grok: size=${s_size} feature=${h_slug} iteration=${h_iter} phase=CODE"
echo "invoke-grok: GROK_CMD=${GROK_CMD}"
echo "invoke-grok: launching..."

# Word-split on GROK_CMD is intentional so multi-word commands work.
# Prefer: GROK_CMD='grok --print' or a wrapper script for complex CLIs (paths with spaces).
# shellcheck disable=SC2086
exec ${GROK_CMD} "${PROMPT}"
