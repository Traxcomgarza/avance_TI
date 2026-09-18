#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

log "Etapa 5/7: Imagen de contenedor (trivy) — bloquea con: ${UMBRAL_CONTAINER_SEVERIDAD_BLOQUEA}"

docker build -t "${IMAGE_NAME}" "${REPO_ROOT}" >/dev/null

OUT="${REPORTES_DIR}/05_container.json"
trivy image --severity "${UMBRAL_CONTAINER_SEVERIDAD_BLOQUEA}" --ignorefile "${REPO_ROOT}/.trivyignore" --exit-code 0 -f json -o "${OUT}" "${IMAGE_NAME}"

HALLAZGOS=$(jq '[.Results[]?.Vulnerabilities[]?] | length' "${OUT}" 2>/dev/null || echo 0)
log "Vulnerabilidades ${UMBRAL_CONTAINER_SEVERIDAD_BLOQUEA} en la imagen: ${HALLAZGOS}"

if [ "${HALLAZGOS}" -gt 0 ]; then
  log "BLOQUEA: ${HALLAZGOS} vulnerabilidades de severidad ${UMBRAL_CONTAINER_SEVERIDAD_BLOQUEA} en la imagen"
  exit 1
fi

log "PASA: imagen sin vulnerabilidades bloqueantes"
exit 0
