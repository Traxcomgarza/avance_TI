# Evidencia de despliegue en Produccion

## Infraestructura

Toda la infraestructura (RDS, bucket S3, las instancias EC2 de QA y
Produccion, y sus Security Groups) la cree con Terraform (infra/main.tf),
detectando la VPC y las subnets automaticamente con data sources en vez de
ponerlas a mano.

Una cosa que tuve que documentar como limitacion: AWS Academy tiene una
politica a nivel de organizacion que le niega a mi usuario el permiso
s3:GetBucketObjectLockConfiguration sin excepcion. Por eso Terraform si
puede crear el bucket S3, pero no lo puede volver a leer despues (falla
cada vez que intenta refrescar su estado). El bucket se creo con Terraform,
y el cifrado (AES256) y el bloqueo de acceso publico se los puse aparte con
AWS CLI, porque Terraform ya no podia gestionar ese recurso despues de
creado.

## Instancia de Produccion

- Instancia: bacm-redsocial-produccion
- IP publica: 3.234.242.102
- Codigo desplegado: commit 8383d95 de la rama entrega-final (ya con la
  correccion del SQL injection y el fix del driver de PostgreSQL)

## Como lo verifique

La app remediada esta corriendo en Produccion conectada a la base de datos
RDS real y al bucket S3 real:

curl -I http://localhost:5000/salud
HTTP/1.1 200 OK


Tambien volvi a intentar el payload de explotacion original contra esta
instancia y ya no funciona, el endpoint remediado ya no es vulnerable.
