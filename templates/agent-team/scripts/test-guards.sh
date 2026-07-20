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
size: full
phase: CODE
iteration: 1
spec: docs/specs/x.md
plan: docs/plans/x.md
latest_code_review: null
handoff: docs/agent-team/HANDOFF.md
gates:
  human_spec: approved
  human_plan: approved
  human_code_fix: n/a
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

# --- iteration mismatch (raw strings differ but also after normalize) ---
sed -i.bak 's/iteration: 1/iteration: 2/' "${tmp}/docs/agent-team/STATE.md"
expect_reject "iteration mismatch" "${tmp}" "iteration mismatch"
sed -i.bak 's/iteration: 2/iteration: 1/' "${tmp}/docs/agent-team/STATE.md"

# --- leading zeros: 01 vs 1 should match after normalize ---
sed -i.bak 's/iteration: 1/iteration: 01/' "${tmp}/docs/agent-team/STATE.md"
sed -i.bak 's/\*\*Iteration:\*\* 1/**Iteration:** 1/' "${tmp}/docs/agent-team/HANDOFF.md"
expect_pass_preflight "iteration 01 vs 1 normalized" "${tmp}"
sed -i.bak 's/iteration: 01/iteration: 1/' "${tmp}/docs/agent-team/STATE.md"

# --- quoted YAML phase ---
sed -i.bak 's/phase: CODE/phase: "CODE"/' "${tmp}/docs/agent-team/STATE.md"
expect_pass_preflight "quoted phase CODE" "${tmp}"
sed -i.bak 's/phase: "CODE"/phase: CODE/' "${tmp}/docs/agent-team/STATE.md"

# --- stale Grok result without pending ---
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

# --- stale pass that still mentions pending in prose (false-positive guard) ---
make_valid_fixture "${tmp}"
cat > "${tmp}/docs/agent-team/HANDOFF.md" <<'EOF'
# HANDOFF

- **Feature slug:** hello-export
- **Iteration:** 1
- **STATE phase:** CODE

## Goal

x

## Grok result

- Status: pass
- Notes: was pending earlier, now done
EOF
expect_reject "stale pass with pending in notes" "${tmp}" "completed"

# --- free-text mention of idle phrase must NOT block ---
make_valid_fixture "${tmp}"
perl -i -0pe 's/## Goal\n\nImplement greet for demo./## Goal\n\nDocument what "No active handoff" means for operators./' \
  "${tmp}/docs/agent-team/HANDOFF.md" 2>/dev/null || \
  sed -i.bak 's/Implement greet for demo./Document No active handoff meaning/' "${tmp}/docs/agent-team/HANDOFF.md"
expect_pass_preflight "No active handoff in free text OK" "${tmp}"

# --- exact idle sentinel Goal line blocks ---
make_valid_fixture "${tmp}"
perl -i -0pe 's/## Goal\n\nImplement greet for demo./## Goal\n\n_No active handoff. Orchestrator replaces this file before calling `scripts\/invoke-grok.sh`._/' \
  "${tmp}/docs/agent-team/HANDOFF.md"
expect_reject "exact idle sentinel Goal" "${tmp}" "idle sentinel"

# --- gates not approved ---
make_valid_fixture "${tmp}"
sed -i.bak 's/spec_review: approved/spec_review: pending/' "${tmp}/docs/agent-team/STATE.md"
expect_reject "spec_review pending" "${tmp}" "spec_review"
sed -i.bak 's/spec_review: pending/spec_review: approved/' "${tmp}/docs/agent-team/STATE.md"
sed -i.bak 's/plan_review: approved/plan_review: changes_requested/' "${tmp}/docs/agent-team/STATE.md"
expect_reject "plan_review changes_requested" "${tmp}" "plan_review"

# --- APPROVED (review-verdict casing) accepted ---
make_valid_fixture "${tmp}"
sed -i.bak 's/spec_review: approved/spec_review: APPROVED/' "${tmp}/docs/agent-team/STATE.md"
sed -i.bak 's/plan_review: approved/plan_review: APPROVED/' "${tmp}/docs/agent-team/STATE.md"
expect_pass_preflight "gates APPROVED case-insensitive" "${tmp}"

# --- bare pass line rejected ---
make_valid_fixture "${tmp}"
cat > "${tmp}/docs/agent-team/HANDOFF.md" <<'EOF'
# HANDOFF

- **Feature slug:** hello-export
- **Iteration:** 1
- **STATE phase:** CODE

## Goal

x

## Grok result

pass
EOF
expect_reject "bare pass Grok result" "${tmp}" "completed"

# --- human_plan pending blocks first CODE (full) ---
make_valid_fixture "${tmp}"
sed -i.bak 's/human_plan: approved/human_plan: pending/' "${tmp}/docs/agent-team/STATE.md"
expect_reject "human_plan pending" "${tmp}" "human_plan"

# --- size micro allows invoke with all pre-code gates n/a ---
make_valid_fixture "${tmp}"
sed -i.bak 's/size: full/size: micro/' "${tmp}/docs/agent-team/STATE.md"
sed -i.bak 's/human_spec: approved/human_spec: n\/a/' "${tmp}/docs/agent-team/STATE.md"
sed -i.bak 's/human_plan: approved/human_plan: n\/a/' "${tmp}/docs/agent-team/STATE.md"
sed -i.bak 's/spec_review: approved/spec_review: n\/a/' "${tmp}/docs/agent-team/STATE.md"
sed -i.bak 's/plan_review: approved/plan_review: n\/a/' "${tmp}/docs/agent-team/STATE.md"
expect_pass_preflight "size micro with n/a gates" "${tmp}"

# --- size small allows plan gates n/a ---
make_valid_fixture "${tmp}"
sed -i.bak 's/size: full/size: small/' "${tmp}/docs/agent-team/STATE.md"
sed -i.bak 's/human_plan: approved/human_plan: n\/a/' "${tmp}/docs/agent-team/STATE.md"
sed -i.bak 's/plan_review: approved/plan_review: n\/a/' "${tmp}/docs/agent-team/STATE.md"
expect_pass_preflight "size small plan n/a" "${tmp}"

# --- size missing rejects ---
make_valid_fixture "${tmp}"
sed -i.bak 's/size: full/size: null/' "${tmp}/docs/agent-team/STATE.md"
expect_reject "size null rejects" "${tmp}" "size"

# --- iter 2 requires human_code_fix approved ---
make_valid_fixture "${tmp}"
sed -i.bak 's/iteration: 1/iteration: 2/' "${tmp}/docs/agent-team/STATE.md"
sed -i.bak 's/\*\*Iteration:\*\* 1/**Iteration:** 2/' "${tmp}/docs/agent-team/HANDOFF.md"
sed -i.bak 's/human_code_fix: n\/a/human_code_fix: pending/' "${tmp}/docs/agent-team/STATE.md"
expect_reject "human_code_fix pending on iter 2" "${tmp}" "human_code_fix"
sed -i.bak 's/human_code_fix: pending/human_code_fix: approved/' "${tmp}/docs/agent-team/STATE.md"
expect_pass_preflight "human_code_fix approved on iter 2" "${tmp}"

rm -rf "${tmp}"

echo "test-guards: ${passes} passed, ${failures} failed"
if [[ "${failures}" -ne 0 ]]; then
  exit 1
fi
echo "test-guards: OK"
