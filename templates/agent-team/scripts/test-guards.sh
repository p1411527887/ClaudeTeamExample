#!/usr/bin/env bash
# Unit tests for invoke-grok.sh preflight guards (no real Grok binary required).
# Usage: from templates/agent-team/ → ./scripts/test-guards.sh
#    or: from packaging repo root → ./templates/agent-team/scripts/test-guards.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
INVOKE="${TEMPLATE_ROOT}/scripts/invoke-grok.sh"

failures=0
passes=0

pass() {
  echo "  PASS: $*"
  passes=$((passes + 1))
}

fail() {
  echo "  FAIL: $*"
  failures=$((failures + 1))
}

# Build a minimal valid CODE handoff + STATE inside $1
make_valid_fixture() {
  local dest="$1"
  rsync -a --delete \
    --exclude 'docs/agent-team/examples' \
    "${TEMPLATE_ROOT}/" "${dest}/"

  cat > "${dest}/docs/agent-team/HANDOFF.md" <<'EOF'
# HANDOFF — Grok coding turn

- **Feature slug:** hello-export
- **Iteration:** 1
- **STATE phase:** CODE

## Goal

Implement greet for demo.

## Success criteria

- [ ] works

## Links

- Spec: docs/specs/x.md
- Plan: docs/plans/x.md
- Latest review:

## In scope

- src/greet.ts

## Out of scope

- CLI

## Allowed files / constraints

- Surgical only.

## Open findings (iteration > 1 only)

| ID | File | Expected fix |
|----|------|--------------|
|  |  |  |

## Verify commands

```bash
true
```

## Grok result

pending
EOF

  cat > "${dest}/docs/agent-team/STATE.md" <<'EOF'
# Agent Team State

```yaml
feature: hello-export
phase: CODE
iteration: 1
spec: docs/specs/x.md
plan: docs/plans/x.md
latest_code_review: null
handoff: docs/agent-team/HANDOFF.md
gates:
  spec_review: approved
  plan_review: approved
  code_review: pending
blockers: []
```
EOF
}

expect_reject() {
  local name="$1"
  local dest="$2"
  local needle="$3"
  local out rc
  set +e
  out="$("${dest}/scripts/invoke-grok.sh" 2>&1)"
  rc=$?
  set -e
  if [[ "${rc}" -eq 0 ]]; then
    fail "${name} (expected non-zero, got 0)"
    return
  fi
  if echo "${out}" | grep -qF "${needle}"; then
    pass "${name}"
  else
    fail "${name} (expected message containing: ${needle})"
    echo "    got: ${out}" | head -c 400
    echo
  fi
}

expect_pass_preflight() {
  # Guards pass → script reaches exec; with fake GROK_CMD that exits 0 we get 0.
  local name="$1"
  local dest="$2"
  local out rc
  set +e
  out="$(
    cd "${dest}" && \
    GROK_CMD="true" ./scripts/invoke-grok.sh 2>&1
  )"
  rc=$?
  set -e
  if [[ "${rc}" -eq 0 ]] && echo "${out}" | grep -q 'launching'; then
    pass "${name}"
  else
    fail "${name} (rc=${rc})"
    echo "    got: ${out}" | head -c 400
    echo
  fi
}

echo "test-guards: running..."

# --- idle starter (template default) ---
# Idle HANDOFF includes both STATE phase IDLE and "No active handoff" sentinel;
# either rejection is correct (sentinel is checked first).
tmp="$(mktemp -d)"
rsync -a "${TEMPLATE_ROOT}/" "${tmp}/"
expect_reject "idle handoff" "${tmp}" "idle sentinel"
rm -rf "${tmp}"

# --- valid CODE fixture ---
tmp="$(mktemp -d)"
make_valid_fixture "${tmp}"
expect_pass_preflight "valid CODE handoff + STATE" "${tmp}"

# --- STATE not CODE ---
sed -i.bak 's/phase: CODE/phase: DRAFT_SPEC/' "${tmp}/docs/agent-team/STATE.md"
expect_reject "STATE phase DRAFT_SPEC" "${tmp}" "must be CODE"
sed -i.bak 's/phase: DRAFT_SPEC/phase: CODE/' "${tmp}/docs/agent-team/STATE.md"

# --- HANDOFF phase not CODE ---
sed -i.bak 's/\*\*STATE phase:\*\* CODE/**STATE phase:** PLAN_REVIEW/' "${tmp}/docs/agent-team/HANDOFF.md"
expect_reject "HANDOFF phase PLAN_REVIEW" "${tmp}" "must be CODE"
sed -i.bak 's/\*\*STATE phase:\*\* PLAN_REVIEW/**STATE phase:** CODE/' "${tmp}/docs/agent-team/HANDOFF.md"

# --- feature mismatch ---
sed -i.bak 's/feature: hello-export/feature: other/' "${tmp}/docs/agent-team/STATE.md"
expect_reject "feature mismatch" "${tmp}" "feature mismatch"
sed -i.bak 's/feature: other/feature: hello-export/' "${tmp}/docs/agent-team/STATE.md"

# --- iteration mismatch ---
sed -i.bak 's/iteration: 1/iteration: 2/' "${tmp}/docs/agent-team/STATE.md"
expect_reject "iteration mismatch" "${tmp}" "iteration mismatch"
sed -i.bak 's/iteration: 2/iteration: 1/' "${tmp}/docs/agent-team/STATE.md"

# --- stale Grok result ---
cat > "${tmp}/docs/agent-team/HANDOFF.md" <<'EOF'
# HANDOFF

- **Feature slug:** hello-export
- **Iteration:** 1
- **STATE phase:** CODE

## Goal

x

## Grok result

- Status: pass
- Commands: npm test
EOF
expect_reject "stale Grok result without pending" "${tmp}" "pending"

# --- idle sentinel ---
make_valid_fixture "${tmp}"
# inject sentinel into Goal
perl -i -0pe 's/## Goal\n\n/## Goal\n\n_No active handoff. Orchestrator replaces this file before calling `scripts\/invoke-grok.sh`._\n\n/' "${tmp}/docs/agent-team/HANDOFF.md" 2>/dev/null || \
  sed -i.bak 's/Implement greet for demo./No active handoff. Orchestrator replaces this file/' "${tmp}/docs/agent-team/HANDOFF.md"
expect_reject "idle sentinel text" "${tmp}" "idle sentinel"

rm -rf "${tmp}"

echo "test-guards: ${passes} passed, ${failures} failed"
if [[ "${failures}" -ne 0 ]]; then
  exit 1
fi
echo "test-guards: OK"
