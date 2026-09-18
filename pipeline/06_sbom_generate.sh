#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

log "Etapa 6/7: Generación de SBOM (syft, formato CycloneDX)"

OUT="${REPORTES_DIR}/sbom_cyclonedx.json"
syft "${IMAGE_NAME}" -o cyclonedx-json="${OUT}"

if [ -s "${OUT}" ]; then
  log "PASA: SBOM generado en ${OUT}"
  exit 0
else
  log "BLOQUEA: no se pudo generar el SBOM"
  exit 1
fi
