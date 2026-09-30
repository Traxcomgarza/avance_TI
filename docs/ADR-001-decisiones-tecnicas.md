# ADR-001: Decisiones tecnicas - Red Social Corta

## Contexto

El reto pide backend Python, 2 o mas contenedores propios, S3, RDS, identificacion de usuario, endpoint de salud, cero credenciales en codigo, IaC y Dockerfile endurecido. El tema (red social de formato corto) exige ademas cache en Redis para el feed. La Entrega Final agrega un ambiente de Produccion separado de QA y la deteccion/remediacion de una vulnerabilidad real inyectada en el codigo.

## Decisiones

| Decision | Por que | Que se descarto |
|---|---|---|
| Flask, no FastAPI | Simplicidad para manejar sesiones con cookies | FastAPI no daba ventaja para este alcance |
| Sesion con cookie firmada | Cubre lo que pide el reto | JWT agregaba complejidad sin necesidad |
| Redis con TTL de 30 segundos, invalidacion en escritura | Balance entre feed actualizado y menos carga a RDS | Invalidar solo por TTL mostraria datos viejos despues de publicar |
| S3 solo para imagenes de post | Uso real del bucket sin inflar el alcance | Guardar el feed completo en S3 no tenia caso |
| SQLAlchemy sobre PostgreSQL | ORM conocido, facil de apuntar a RDS | - |
| docker-compose con 2 servicios (web, redis) | Cumple el minimo de contenedores separados | Postgres en contenedor local: el reto pide RDS real |
| Terraform crea RDS, S3, ambas EC2 y sus Security Groups | Todo queda documentado y se puede recrear igual | Crear las instancias a mano: no queda registro reproducible |
| Bucket S3 se crea por Terraform pero se saca del state despues | AWS Academy bloquea por SCP la relectura del bucket (s3:GetBucketObjectLockConfiguration); el bucket ya existe y funciona, Terraform simplemente no puede volver a tocarlo | Manejar el bucket 100% manual: se pierde la evidencia de que si se creo por IaC |
| Busqueda de contenido por ORM (filter + ilike), acotada a posts propios y de cuentas seguidas | Extra que agregamos desde el inicio, sin exponer SQL crudo | Busqueda con SQL directo: mismo riesgo que la vulnerabilidad que estamos remediando |
| Produccion como instancia EC2 nueva, nunca recibe el parche vulnerable | Mantiene separado lo que esta bien de lo que estamos probando arreglar | Reusar la instancia de QA como Produccion: mezclaria evidencia de ambos ambientes |

## Que se dejo fuera

- Notificaciones en tiempo real (nuevo seguidor, nuevo like)
- Rate limiting o proteccion anti-bots en endpoints publicos

## Declaracion de uso de IA

Ver docs/declaracion_uso_ia.md

## Vulnerabilidades del sistema operativo excluidas del escaneo de contenedor

Trivy reporta CVEs en paquetes base de Debian bookworm que no tienen parche disponible en el repositorio de Debian al momento de este avance, o que Debian ya considera resueltas sin cambiar el numero de version del paquete (practica comun de backporting de seguridad de Debian). Ninguna de estas vulnerabilidades esta en codigo propio ni en las dependencias Python de la app (Flask, Werkzeug, boto3, etc., que si se mantienen actualizadas via requirements.txt). La lista completa de CVEs excluidas esta en el archivo .trivyignore en la raiz del repositorio.
