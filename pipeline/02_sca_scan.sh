#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

log "Etapa 2/7: SCA (pip-audit) — bloquea con: ${UMBRAL_SCA_SEVERIDAD_BLOQUEA}"

OUT="${REPORTES_DIR}/02_sca.json"
pip-audit -r "${REPO_ROOT}/app/requirements.txt" -f json -o "${OUT}" || true

CRITICOS_ALTOS=$(jq '[.dependencies[]?.vulns[]? | select(.fix_versions != null)] | length' "${OUT}" 2>/dev/null || echo 0)
log "Vulnerabilidades con parche disponible: ${CRITICOS_ALTOS}"

if [ "${CRITICOS_ALTOS}" -gt 0 ]; then
  log "BLOQUEA: hay ${CRITICOS_ALTOS} vulnerabilidades de dependencias con fix disponible"
  exit 1
fi

log "PASA: sin vulnerabilidades bloqueantes en dependencias"
exit 0
