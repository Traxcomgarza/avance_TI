# Declaracion de uso de IA - El Reto Avance 2

## Que se genero con ayuda de IA

* Estructura inicial de la app Flask (modelos, rutas de auth, posts, follow, like, feed y buscador de usuarios)
* Cache de feed con Redis y su invalidacion
* Plantillas y estructura base para documentacion (README, ADR y tabla de decisiones)

## Que hice, corregi, ajuste o verifique directamente

* Desarrollo y configuracion del pipeline de CI/CD, incluyendo sus 7 etapas y el orquestador con la decision final integrada
* Desarrollo y configuracion de Docker y Docker Compose para la aplicacion
* Desarrollo y configuracion de la infraestructura con Terraform y AWS CLI para los recursos necesarios de la aplicacion
* Adaptacion de la infraestructura al entorno real de AWS Academy
* Pruebas manuales del flujo completo de la aplicacion: registro, login, publicaciones con y sin imagen, seguir usuarios, likes y busqueda de usuarios
* Ajustes de UX realizados durante las pruebas, como evitar la recarga de la pagina al dar like y permitir el filtrado de usuarios en vivo
* Ejecucion y validacion del pipeline hasta obtener una corrida roja real y posteriormente una corrida verde despues de aplicar las correcciones necesarias

## Uso de IA

La IA se utilizo como herramienta de apoyo para generar estructuras iniciales de codigo, proponer soluciones y apoyar la elaboracion y organizacion de la documentacion del proyecto.

El desarrollo y configuracion de Docker, la infraestructura y el pipeline fueron realizados directamente por mi. Tambien realice las pruebas y validaciones necesarias para comprobar el funcionamiento de la aplicacion y del entorno de despliegue.

En la parte de infraestructura fue donde mas apoyo necesite. Tuve un problema grande con el bucket de S3 en Terraform: AWS Academy tiene una politica a nivel organizacion (SCP) que bloquea el permiso `s3:GetBucketObjectLockConfiguration`, y sin ese permiso Terraform no puede leer el estado del bucket despues de crearlo. Probe varias cosas para evitarlo, entre ellas poner `object_lock_enabled = false` explicitamente en el recurso, pero seguia fallando exactamente igual en el plan y en el destroy. Al final entendi que no es algo que se arregle desde el codigo, es un bloqueo del laboratorio que no puedo quitar. Decidi dejar el recurso del bucket en el `.tf` para que quede como evidencia de que si se crea por Terraform, aunque despues ya no lo pueda seguir gestionando ahi (la encriptacion y el bloqueo de acceso publico los aplique aparte por CLI).

Tambien use la IA para resolver varios errores mientras montaba las instancias: el volumen raiz de la instancia se quedaba sin espacio al instalar dependencias, tuve que agrandarlo desde Terraform y despues extender la particion dentro de la instancia. Tambien me trabe con un error de conexion a la base de datos porque SQLAlchemy intentaba usar un driver de Postgres que no tenia instalado, y con el comando correcto para levantar los contenedores (docker-compose con guion, no docker compose con espacio, porque asi quedo instalado el binario en la instancia).
