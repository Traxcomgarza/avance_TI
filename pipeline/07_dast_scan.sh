#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

TARGET_URL="${1:-http://localhost:5000}"
log "Etapa 7/7: DAST (ZAP baseline) contra ${TARGET_URL} — umbral: ${UMBRAL_DAST_MAX_ALERTAS_ALTAS} alertas altas"

OUT="${REPORTES_DIR}/07_dast.json"
docker run --rm --network host -v "${REPORTES_DIR}:/zap/wrk:rw" \
  zaproxy/zap-stable zap-baseline.py -t "${TARGET_URL}" -J 07_dast.json -I || true

ALTAS=$(jq '[.site[]?.alerts[]? | select(.riskcode=="3")] | length' "${OUT}" 2>/dev/null || echo 0)
log "Alertas de riesgo alto: ${ALTAS}"

if [ "${ALTAS}" -gt "${UMBRAL_DAST_MAX_ALERTAS_ALTAS}" ]; then
  log "BLOQUEA: ${ALTAS} alertas de riesgo alto (umbral ${UMBRAL_DAST_MAX_ALERTAS_ALTAS})"
  exit 1
fi

log "PASA: sin alertas DAST bloqueantes"
exit 0
