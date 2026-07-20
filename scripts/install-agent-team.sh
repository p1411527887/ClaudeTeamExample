#!/usr/bin/env bash
# Install agent-team skeleton into a project from this packaging repository.
#
# Usage (run from packaging repo root OR any cwd — script finds itself):
#   ./scripts/install-agent-team.sh /path/to/project              # auto: empty→greenfield, else brownfield
#   ./scripts/install-agent-team.sh /path/to/project --greenfield # full rsync; refuses non-empty unless --force
#   ./scripts/install-agent-team.sh /path/to/project --brownfield # selective; never overwrites CLAUDE.md / active STATE|HANDOFF
#   ./scripts/install-agent-team.sh /path/to/project --dry-run
#   ./scripts/install-agent-team.sh /path/to/project --greenfield --force  # allow greenfield into non-empty dest
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGING_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SRC="${PACKAGING_ROOT}/templates/agent-team"

MODE="auto"   # auto | greenfield | brownfield
DRY_RUN=0
FORCE=0
DEST=""

usage() {
  sed -n '2,14p' "$0" | sed 's/^# //; s/^#//'
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --greenfield) MODE="greenfield"; shift ;;
    --brownfield) MODE="brownfield"; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    --force) FORCE=1; shift ;;
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

# True if DEST has any entry other than . / ..
dest_nonempty() {
  local f
  shopt -s nullglob dotglob
  for f in "${DEST}"/* "${DEST}"/.*; do
    base="$(basename "${f}")"
    [[ "${base}" == "." || "${base}" == ".." ]] && continue
    shopt -u nullglob dotglob
    return 0
  done
  shopt -u nullglob dotglob
  return 1
}

if [[ "${MODE}" == "auto" ]]; then
  if dest_nonempty; then
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
  if dest_nonempty && [[ "${FORCE}" -ne 1 ]]; then
    echo "error: greenfield destination is not empty: ${DEST}" >&2
    echo "hint: use --brownfield (safe upgrade), or --greenfield --force to overwrite colliding paths" >&2
    exit 1
  fi
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

# --- brownfield: selective, never clobber CLAUDE.md; preserve active STATE/HANDOFF ---
run mkdir -p "${DEST}/docs" "${DEST}/scripts"

# Usage: copy_tree FROM TO [extra rsync args...]
copy_tree() {
  local from="$1" to="$2"
  shift 2
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    if [[ "$#" -gt 0 ]]; then
      rsync -a --dry-run "$@" "${from}" "${to}"
    else
      rsync -a --dry-run "${from}" "${to}"
    fi
  else
    if [[ "$#" -gt 0 ]]; then
      rsync -a "$@" "${from}" "${to}"
    else
      rsync -a "${from}" "${to}"
    fi
  fi
}

# Preserve live orchestration state files on upgrade
copy_tree "${SRC}/docs/agent-team/" "${DEST}/docs/agent-team/" \
  --exclude 'STATE.md' \
  --exclude 'HANDOFF.md'

# Seed STATE/HANDOFF only if missing (first brownfield install)
for seed in STATE.md HANDOFF.md; do
  if [[ ! -e "${DEST}/docs/agent-team/${seed}" ]]; then
    if [[ "${DRY_RUN}" -eq 1 ]]; then
      echo "dry-run: would seed docs/agent-team/${seed}"
    else
      mkdir -p "${DEST}/docs/agent-team"
      cp "${SRC}/docs/agent-team/${seed}" "${DEST}/docs/agent-team/${seed}"
      echo "seeded: docs/agent-team/${seed}"
    fi
  else
    echo "preserve: docs/agent-team/${seed}"
  fi
done

copy_tree "${SRC}/docs/specs/" "${DEST}/docs/specs/"
copy_tree "${SRC}/docs/plans/" "${DEST}/docs/plans/"
copy_tree "${SRC}/docs/reviews/" "${DEST}/docs/reviews/"

for f in AGENTS.md GROK.md .mcp.json.example; do
  if [[ -e "${DEST}/${f}" && "${DRY_RUN}" -eq 0 ]]; then
    echo "skip existing: ${DEST}/${f} (merge manually if needed)"
    if [[ "${f}" == "AGENTS.md" ]]; then
      echo "warn: existing AGENTS.md kept — merge role/SSOT tables from templates/agent-team/AGENTS.md by hand" >&2
      cp "${SRC}/AGENTS.md" "${DEST}/AGENTS.agent-team.md"
      echo "wrote: AGENTS.agent-team.md (sidecar for merge)"
    fi
    if [[ "${f}" == "GROK.md" ]]; then
      cp "${SRC}/GROK.md" "${DEST}/GROK.agent-team.md"
      echo "wrote: GROK.agent-team.md (sidecar for merge)"
    fi
  elif [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "dry-run: would copy ${f} (if missing)"
  elif [[ ! -e "${DEST}/${f}" ]]; then
    cp "${SRC}/${f}" "${DEST}/${f}"
    echo "copied: ${f}"
  fi
done

for f in invoke-grok.sh verify-skeleton.sh test-guards.sh grok-wrapper.example.sh; do
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "dry-run: would install scripts/${f}"
  else
    cp "${SRC}/scripts/${f}" "${DEST}/scripts/${f}"
    if [[ "${f}" == *.sh ]]; then
      chmod +x "${DEST}/scripts/${f}" 2>/dev/null || true
    fi
    echo "installed: scripts/${f}"
  fi
done

# VERSION + CHANGELOG: do not clobber app identity files — sidecar if present
for f in VERSION CHANGELOG.md; do
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    if [[ -e "${DEST}/${f}" ]]; then
      echo "dry-run: would write ${f}.agent-team (keep existing ${f})"
    else
      echo "dry-run: would copy ${f}"
    fi
  else
    if [[ -e "${DEST}/${f}" ]]; then
      # Always refresh sidecar with template identity
      if [[ "${f}" == "VERSION" ]]; then
        cp "${SRC}/${f}" "${DEST}/VERSION.agent-team"
        echo "wrote: VERSION.agent-team (existing VERSION preserved)"
      else
        cp "${SRC}/${f}" "${DEST}/CHANGELOG.agent-team.md"
        echo "wrote: CHANGELOG.agent-team.md (existing CHANGELOG.md preserved)"
      fi
    else
      cp "${SRC}/${f}" "${DEST}/${f}"
      echo "copied: ${f}"
    fi
  fi
done

# CLAUDE.md: never overwrite; write sidecar if existing
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
echo "note: docs/agent-team/STATE.md and HANDOFF.md were preserved if already present"
