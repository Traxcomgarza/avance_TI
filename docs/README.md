# Red Social Corta - El Reto Avance 2 (LSCA2314)

Autor: Brandon Alan

## Que hace la app

Red social de formato corto. Los usuarios se registran, inician sesion, publican mensajes de hasta 280 caracteres (con imagen opcional), siguen a otros usuarios, dan like y ven un feed con las publicaciones de las cuentas que siguen.

Pieza tecnica distintiva: el feed se sirve desde una cache en Redis (contenedor separado) durante 30 segundos antes de volver a consultar la base de datos. Cada publicacion o follow nuevo invalida la cache de los usuarios afectados.

## Arquitectura

- API: Flask + Gunicorn (contenedor web)
- Cache de feed: Redis (contenedor redis)
- Base de datos: PostgreSQL en Amazon RDS (fuera de docker-compose, real)
- Almacenamiento de imagenes: Amazon S3 (bucket privado, cifrado)

Diagrama completo en docs/diagrama_arquitectura.jpg.

## Herramientas que necesitas en la instancia

- Docker y Docker Compose v2
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

1. Aprovisionar S3 y RDS (la instancia EC2 ya existe, esto no la crea). Crea infra/terraform.tfvars con tus valores de vpc_id, subnet_ids, app_instance_sg_id, bucket_name, db_name y db_username, luego:

    cd infra
    export TF_VAR_db_password="<tu-password-real, ya guardada en ~/.bashrc>"
    terraform init
    terraform apply

2. Crear el archivo .env con SECRET_KEY, DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD, S3_BUCKET, AWS_REGION y las credenciales de AWS. Nunca subir .env al repo.

3. Levantar contenedores:

    docker compose up -d --build

4. Verificar salud: curl http://localhost:5000/salud

## Servicios de AWS

- S3: redsocial-bucket-meme2fb6
- RDS: bacm-redsocial-db.cjksav3zrw2a.us-east-1.rds.amazonaws.com

## Pipeline

Ver pipeline/pipeline_local.sh y docs/tabla_decisiones_pipeline.md.
