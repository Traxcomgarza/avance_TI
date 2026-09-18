#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

log "Etapa 3/7: SAST (bandit) — bloquea con severidad: ${UMBRAL_SAST_SEVERIDAD_BLOQUEA}+"

OUT="${REPORTES_DIR}/03_sast.json"
bandit -r "${REPO_ROOT}/app" -f json -o "${OUT}" -ll || true

ALTOS=$(jq '[.results[] | select(.issue_severity=="HIGH" or .issue_severity=="CRITICAL")] | length' "${OUT}" 2>/dev/null || echo 0)
log "Hallazgos HIGH/CRITICAL: ${ALTOS}"

if [ "${ALTOS}" -gt 0 ]; then
  log "BLOQUEA: ${ALTOS} hallazgos de severidad ${UMBRAL_SAST_SEVERIDAD_BLOQUEA} o mayor"
  exit 1
fi

log "PASA: sin hallazgos SAST bloqueantes"
exit 0
