# Tabla de decisiones del pipeline - Red Social Corta

| # | Control | Riesgo que cubre | Umbral | Por que este umbral | Herramienta |
|---|---|---|---|---|---|
| 1 | Secretos | Credenciales de RDS, S3 o SECRET_KEY hardcodeadas en el repo | 1 o mas hallazgos | Un solo secreto expuesto ya compromete RDS o S3 | gitleaks |
| 2 | SCA | Dependencias con CVE conocida | CRITICAL o HIGH con parche disponible | Si ya existe fix, no aplicarlo es evitable | pip-audit |
| 3 | SAST | Inyeccion SQL en el feed o los posts | HIGH o CRITICAL | El feed y los posts reciben input directo del usuario | bandit |
| 4 | IaC | Bucket S3 publico o RDS accesible desde internet | HIGH o CRITICAL | Mas barato bloquear el plan que remediar despues | checkov |
| 5 | Imagen de contenedor | CVEs del sistema operativo base | CRITICAL o HIGH | Es la superficie expuesta todo el tiempo en el puerto 5000 | trivy |
| 6 | SBOM | No saber que librerias corren en produccion | se bloquea si no se genera | Responder ante una CVE nueva toma segundos con SBOM, horas sin el | syft |
| 7 | DAST | Fallas que solo se ven con la app corriendo | 1 o mas alertas de riesgo alto | Los controles anteriores no ven el comportamiento en ejecucion | OWASP ZAP |

## Decision final

Las 7 etapas corren en pipeline/pipeline_local.sh. Si una etapa falla su umbral, el resultado es DESPLIEGUE BLOQUEADO. Si las 7 pasan, es DESPLIEGUE PERMITIDO.

## Que se decidio no cubrir

- Rate limiting o proteccion anti-bots en el feed publico: es una decision de infraestructura o WAF, no de un pipeline de seguridad de codigo.
- Se excluyeron del escaneo de IaC 6 checks de checkov no aplicables a un entorno de laboratorio de curso: Multi-AZ (duplica el costo de RDS), autenticacion IAM (exige cambios en el codigo de la app), monitoreo mejorado y Performance Insights (costo y complejidad fuera de alcance, ademas Performance Insights no es compatible con db.t3.micro), Query Logging via parameter group (fuera de alcance de este avance) y deletion protection (desactivada a proposito para poder destruir el entorno de QA sin friccion).
