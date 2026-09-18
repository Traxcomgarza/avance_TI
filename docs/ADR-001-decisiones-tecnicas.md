# ADR-001: Decisiones tecnicas - Red Social Corta

## Contexto

El reto pide backend Python, 2 o mas contenedores propios, S3, RDS, identificacion de usuario, endpoint de salud, cero credenciales en codigo, IaC y Dockerfile endurecido. El tema (red social de formato corto) exige ademas cache en Redis para el feed.

## Decisiones

| Decision | Por que | Que se descarto |
|---|---|---|
| Flask, no FastAPI | Simplicidad para manejar sesiones con cookies | FastAPI no daba ventaja para este alcance |
| Sesion con cookie firmada | Cubre lo que pide el reto | JWT agregaba complejidad sin necesidad |
| Redis con TTL de 30 segundos, invalidacion en escritura | Balance entre feed actualizado y menos carga a RDS | Invalidar solo por TTL mostraria datos viejos despues de publicar |
| S3 solo para imagenes de post | Uso real del bucket sin inflar el alcance | Guardar el feed completo en S3 no tenia caso |
| SQLAlchemy sobre PostgreSQL | ORM conocido, facil de apuntar a RDS | - |
| docker-compose con 2 servicios (web, redis) | Cumple el minimo de contenedores separados | Postgres en contenedor local: el reto pide RDS real |

## Que se dejo fuera


- Notificaciones en tiempo real (nuevo seguidor, nuevo like)
- Rate limiting o proteccion anti-bots en endpoints publicos


## Declaracion de uso de IA

Ver docs/declaracion_uso_ia.md

## Vulnerabilidades del sistema operativo excluidas del escaneo de contenedor

Trivy reporta CVEs en paquetes base de Debian bookworm que no tienen parche disponible en el repositorio de Debian al momento de este avance, o que Debian ya considera resueltas sin cambiar el numero de version del paquete (practica comun de backporting de seguridad de Debian). Ninguna de estas vulnerabilidades esta en codigo propio ni en las dependencias Python de la app (Flask, Werkzeug, boto3, etc., que si se mantienen actualizadas via requirements.txt). La lista completa de CVEs excluidas esta en el archivo .trivyignore en la raiz del repositorio.
