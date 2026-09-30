# Red Social Corta - El Reto (LSCA2314)

Autor: Brandon Alan

## Que hace la app

Red social de formato corto. Los usuarios se registran, inician sesion, publican mensajes de hasta 280 caracteres (con imagen opcional), siguen a otros usuarios, dan like y ven un feed con las publicaciones de las cuentas que siguen. Tambien pueden buscar contenido dentro de su feed (posts propios + de las cuentas que siguen) por palabra clave.

Pieza tecnica distintiva: el feed se sirve desde una cache en Redis (contenedor separado) durante 30 segundos antes de volver a consultar la base de datos. Cada publicacion o follow nuevo invalida la cache de los usuarios afectados.

## Arquitectura

- API: Flask + Gunicorn (contenedor web)
- Cache de feed: Redis (contenedor redis)
- Base de datos: PostgreSQL en Amazon RDS (fuera de docker-compose, real)
- Almacenamiento de imagenes: Amazon S3 (bucket privado, cifrado)

Diagrama completo en docs/diagrama_arquitectura.jpg.

## Dos ambientes (Entrega Final)

- **QA**: la instancia original, donde se aplica el parche vulnerable, corre el pipeline en rojo, se remedia el codigo y el pipeline pasa a verde.
- **Produccion**: instancia nueva y separada, que solo recibe el codigo ya remediado. Nunca se le aplica el parche vulnerable directamente.

Ambas comparten la misma RDS y el mismo bucket S3.

## Herramientas que necesitas en la instancia

- Docker y docker-compose (binario standalone, se instala via Terraform user_data)
- Terraform
- AWS CLI configurado con credenciales de AWS Academy
- Para correr el pipeline: gitleaks, pip-audit, bandit, checkov, trivy, syft

Instalacion:

    pip3 install --user --ignore-installed pip-audit bandit checkov
    export PATH="$HOME/.local/bin:$PATH"

    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin
    curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sudo sh -s -- -b /usr/local/bin

    GITLEAKS_VERSION=$(curl -s https://api.github.com/repos/gitleaks/gitleaks/releases/latest | grep tag_name | cut -d '"' -f4 | sed 's/v//')
    curl -sSL "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz" -o /tmp/gitleaks.tar.gz
    sudo tar -xzf /tmp/gitleaks.tar.gz -C /usr/local/bin gitleaks

## Como se levanta

1. Aprovisionar toda la infraestructura con Terraform (RDS, bucket S3, EC2 de QA, EC2 de Produccion y sus Security Groups). Crea infra/terraform.tfvars con tus valores de bucket_name, db_name, db_username, key_name, luego:

    cd infra
    export TF_VAR_db_password="<tu-password-real>"
    terraform init
    terraform apply

Nota: AWS Academy bloquea via SCP la operacion que Terraform necesita para releer el bucket S3 despues de crearlo (s3:GetBucketObjectLockConfiguration, denegada a nivel organizacion). El bucket SI se crea correctamente, pero Terraform no puede volver a hacerle plan/refresh despues. Es una limitacion del laboratorio, no del codigo. Encriptacion y bloqueo de acceso publico del bucket se aplican por CLI una sola vez tras la creacion.

2. Crear el archivo .env en cada instancia con SECRET_KEY, DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD, S3_BUCKET, AWS_REGION y las credenciales de AWS. Nunca subir .env al repo.

3. Levantar contenedores:

    docker-compose up -d --build

4. Verificar salud: curl http://localhost:5000/salud

## Servicios de AWS

- S3: bacm-redsocial-app-2026
- RDS: ver output rds_endpoint de Terraform (endpoint cambia si se recrea la instancia)

## Incidente de seguridad (SQL Injection)

Detectado, clasificado y remediado como parte de la Entrega Final. Ver:
- docs/clasificacion_hallazgo.md
- docs/respuesta_incidente.md
- docs/evidencia_produccion.md

## Pipeline

Ver pipeline/Jenkinsfile y docs/tabla_decisiones_pipeline.md.
