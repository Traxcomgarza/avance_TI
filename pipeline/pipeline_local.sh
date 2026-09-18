#!/bin/bash


source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

TARGET_URL="${1:-http://localhost:5000}"
FALLOS=()

run_stage() {
  local script="$1"
  shift
  if bash "$(dirname "${BASH_SOURCE[0]}")/${script}" "$@"; then
    echo "  -> OK: ${script}"
  else
    echo "  -> FALLA: ${script}"
    FALLOS+=("${script}")
  fi
}

log "=== Iniciando pipeline: red-social-corta ==="

run_stage 01_secrets_scan.sh
run_stage 02_sca_scan.sh
run_stage 03_sast_scan.sh
run_stage 04_iac_scan.sh
run_stage 05_container_scan.sh
run_stage 06_sbom_generate.sh
run_stage 07_dast_scan.sh "${TARGET_URL}"

echo ""
log "=== Veredicto final ==="

if [ ${#FALLOS[@]} -eq 0 ]; then
  log "DESPLIEGUE PERMITIDO — todas las etapas pasaron sus umbrales"
  exit 0
else
  log "DESPLIEGUE BLOQUEADO — etapas que fallaron: ${FALLOS[*]}"
  exit 1
fi
