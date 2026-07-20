#!/usr/bin/env bash
# Install agent-team skeleton into a project from this packaging repository.
#
# Usage (run from packaging repo root OR any cwd — script finds itself):
#   ./scripts/install-agent-team.sh /path/to/project              # auto: greenfield if empty-ish
#   ./scripts/install-agent-team.sh /path/to/project --greenfield # full rsync (overwrites collisions)
#   ./scripts/install-agent-team.sh /path/to/project --brownfield # selective; never overwrites CLAUDE.md
#   ./scripts/install-agent-team.sh /path/to/project --dry-run
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGING_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SRC="${PACKAGING_ROOT}/templates/agent-team"

MODE="auto"   # auto | greenfield | brownfield
DRY_RUN=0
DEST=""

usage() {
  sed -n '2,12p' "$0" | sed 's/^# //; s/^#//'
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --greenfield) MODE="greenfield"; shift ;;
    --brownfield) MODE="brownfield"; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage ;;
    -*)
      echo "unknown flag: $1" >&2
      usage
      ;;
    *)
      if [[ -z "${DEST}" ]]; then
        DEST="$1"
        shift
      else
        echo "unexpected arg: $1" >&2
        usage
      fi
      ;;
  esac
done

[[ -n "${DEST}" ]] || usage
[[ -d "${SRC}" ]] || { echo "error: template missing at ${SRC}" >&2; exit 1; }

mkdir -p "${DEST}"
DEST="$(cd "${DEST}" && pwd)"

if [[ "${MODE}" == "auto" ]]; then
  if [[ -f "${DEST}/CLAUDE.md" || -f "${DEST}/AGENTS.md" || -d "${DEST}/src" || -d "${DEST}/.git" ]]; then
    MODE="brownfield"
  else
    MODE="greenfield"
  fi
  echo "install-agent-team: auto-detected mode=${MODE}"
fi

run() {
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "dry-run: $*"
  else
    "$@"
  fi
}

echo "install-agent-team: SRC=${SRC}"
echo "install-agent-team: DEST=${DEST}"
echo "install-agent-team: MODE=${MODE}"

if [[ "${MODE}" == "greenfield" ]]; then
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    rsync -a --dry-run "${SRC}/" "${DEST}/"
  else
    rsync -a "${SRC}/" "${DEST}/"
    chmod +x "${DEST}/scripts/invoke-grok.sh" \
             "${DEST}/scripts/verify-skeleton.sh" \
             "${DEST}/scripts/test-guards.sh" 2>/dev/null || true
  fi
  echo "install-agent-team: greenfield copy done"
  echo "next: cd ${DEST} && ./scripts/verify-skeleton.sh && ./scripts/test-guards.sh"
  exit 0
fi

# --- brownfield: selective, never clobber CLAUDE.md ---
run mkdir -p "${DEST}/docs" "${DEST}/scripts"

copy_tree() {
  local from="$1" to="$2"
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    rsync -a --dry-run "${from}" "${to}"
  else
    rsync -a "${from}" "${to}"
  fi
}

copy_tree "${SRC}/docs/agent-team/" "${DEST}/docs/agent-team/"
copy_tree "${SRC}/docs/specs/" "${DEST}/docs/specs/"
copy_tree "${SRC}/docs/plans/" "${DEST}/docs/plans/"
copy_tree "${SRC}/docs/reviews/" "${DEST}/docs/reviews/"

for f in AGENTS.md GROK.md .mcp.json.example; do
  if [[ -e "${DEST}/${f}" && "${DRY_RUN}" -eq 0 ]]; then
    echo "skip existing: ${DEST}/${f} (merge manually if needed)"
  elif [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "dry-run: would copy ${f} (if missing)"
  elif [[ ! -e "${DEST}/${f}" ]]; then
    cp "${SRC}/${f}" "${DEST}/${f}"
    echo "copied: ${f}"
  fi
done

for f in invoke-grok.sh verify-skeleton.sh test-guards.sh; do
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "dry-run: would install scripts/${f}"
  else
    cp "${SRC}/scripts/${f}" "${DEST}/scripts/${f}"
    chmod +x "${DEST}/scripts/${f}"
    echo "installed: scripts/${f}"
  fi
done

# CLAUDE.md: never overwrite; write sidecar if missing orchestrator file
if [[ -f "${DEST}/CLAUDE.md" ]]; then
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "dry-run: would write CLAUDE.agent-team.md sidecar (keep existing CLAUDE.md)"
  else
    cp "${SRC}/CLAUDE.md" "${DEST}/CLAUDE.agent-team.md"
    echo "wrote: CLAUDE.agent-team.md (existing CLAUDE.md preserved)"
    echo "action: merge Agent-team orchestration from CLAUDE.agent-team.md into CLAUDE.md"
  fi
else
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "dry-run: would copy CLAUDE.md"
  else
    cp "${SRC}/CLAUDE.md" "${DEST}/CLAUDE.md"
    echo "copied: CLAUDE.md"
  fi
fi

echo "install-agent-team: brownfield done"
echo "next: merge CLAUDE if needed; cd ${DEST} && ./scripts/verify-skeleton.sh"
