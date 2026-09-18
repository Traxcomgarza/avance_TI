#!/bin/bash


set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPORTES_DIR="${REPO_ROOT}/reportes"
mkdir -p "${REPORTES_DIR}"

IMAGE_NAME="red-social-corta-web:pipeline"

UMBRAL_SECRETS_MAX_HALLAZGOS=0        
UMBRAL_SCA_SEVERIDAD_BLOQUEA="CRITICAL,HIGH"
UMBRAL_SAST_SEVERIDAD_BLOQUEA="HIGH"
UMBRAL_IAC_SEVERIDAD_BLOQUEA="cualquier check fallido (checkov OSS no expone severidad)"
UMBRAL_CONTAINER_SEVERIDAD_BLOQUEA="CRITICAL,HIGH"
UMBRAL_DAST_MAX_ALERTAS_ALTAS=0

log() {
  echo "[$(date '+%H:%M:%S')] $1"
}
