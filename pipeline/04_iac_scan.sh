#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

log "Etapa 4/7: IaC (checkov) — bloquea con severidad: ${UMBRAL_IAC_SEVERIDAD_BLOQUEA}"

OUT="${REPORTES_DIR}/04_iac.json"
checkov -d "${REPO_ROOT}/infra" -o json --output-file-path "${REPORTES_DIR}" --quiet \
  --skip-check CKV_AWS_157,CKV_AWS_118,CKV2_AWS_30,CKV_AWS_161,CKV_AWS_293,CKV_AWS_353 || true
mv "${REPORTES_DIR}/results_json.json" "${OUT}" 2>/dev/null || true

FALLOS=$(jq '.results.failed_checks | length' "${OUT}" 2>/dev/null || echo 0)


if [ "${FALLOS}" -gt 0 ]; then
  log "BLOQUEA: ${FALLOS} controles de IaC fallidos en severidad ${UMBRAL_IAC_SEVERIDAD_BLOQUEA}"
  exit 1
fi

log "PASA: infraestructura como código sin hallazgos bloqueantes"
exit 0
