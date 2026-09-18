#!/bin/bash
# Verifica que existan todas las piezas requeridas por El Reto · Avance 2.
# No evalúa calidad, solo presencia. La rúbrica la aplica el profesor.

set -uo pipefail
ERRORES=0

check_exists() {
  if [ -e "$1" ]; then
    echo "OK   $1"
  else
    echo "FALTA $1"
    ERRORES=$((ERRORES+1))
  fi
}

check_no_placeholder() {
  if [ -f "$1" ] && grep -q "\[COMPLETAR\]" "$1"; then
    echo "PENDIENTE  $1 todavía tiene [COMPLETAR]"
    ERRORES=$((ERRORES+1))
  fi
}

echo "=== Estructura del repositorio ==="
check_exists "app/app.py"
check_exists "app/models.py"
check_exists "docker-compose.yml"
check_exists "Dockerfile"
check_exists "infra/main.tf"
check_exists "pipeline/pipeline_local.sh"
check_exists "reportes/corrida_roja.txt"
check_exists "reportes/corrida_verde.txt"
check_exists "reportes/sbom_cyclonedx.json"
check_exists "docs/README.md"
check_exists "docs/diagrama_arquitectura.jpg"
check_exists "docs/ADR-001-decisiones-tecnicas.md"
check_exists "docs/tabla_decisiones_pipeline.md"
check_exists "docs/declaracion_uso_ia.md"

echo ""
echo "=== Cero credenciales en el código ==="
if git ls-files | grep -qx ".env"; then
  echo "FALTA  .env esta trackeado por git, no deberia estarlo"
  ERRORES=$((ERRORES+1))
else
  echo "OK   .env no esta trackeado por git"
fi

echo ""
echo "=== Video ==="
if [ -f "docs/enlace_video.txt" ] || [ -d "video" ]; then
  echo "OK   referencia de video presente"
else
  echo "FALTA  video/ o docs/enlace_video.txt"
  ERRORES=$((ERRORES+1))
fi

echo ""
echo "=== Plantillas sin completar ==="
check_no_placeholder "docs/README.md"
check_no_placeholder "docs/ADR-001-decisiones-tecnicas.md"
check_no_placeholder "docs/tabla_decisiones_pipeline.md"
check_no_placeholder "docs/declaracion_uso_ia.md"
check_no_placeholder "reportes/corrida_roja.txt"
check_no_placeholder "reportes/corrida_verde.txt"

echo ""
if [ "${ERRORES}" -eq 0 ]; then
  echo "TODO LISTO: no se detectaron piezas faltantes."
  exit 0
else
  echo "FALTAN ${ERRORES} elemento(s). Revisa arriba."
  exit 1
fi
