#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

log "Etapa 1/7: Secretos (gitleaks) — umbral: ${UMBRAL_SECRETS_MAX_HALLAZGOS} hallazgos"

OUT="${REPORTES_DIR}/01_secrets.json"
gitleaks detect --source "${REPO_ROOT}" -r "${OUT}" --exit-code 0

HALLAZGOS=$(jq 'length' "${OUT}" 2>/dev/null || echo 0)
log "Hallazgos de secretos: ${HALLAZGOS}"

if [ "${HALLAZGOS}" -gt "${UMBRAL_SECRETS_MAX_HALLAZGOS}" ]; then
  log "BLOQUEA: se encontraron ${HALLAZGOS} posibles secretos (umbral ${UMBRAL_SECRETS_MAX_HALLAZGOS})"
  exit 1
fi

log "PASA: sin secretos por encima del umbral"
exit 0
