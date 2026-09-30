# Respuesta al incidente

## Contencion inmediata

Comente el registro del blueprint en app.py
(app.register_blueprint(buscar_bp)) para que el endpoint vulnerable
dejara de estar disponible de volada en QA, sin tener que tocar ni tumbar
el resto de la app. Esto quedo en el commit 038ef87.

## Prevencion, el arreglo real

Reescribi buscar_publicaciones.py usando el ORM de SQLAlchemy
(User.query.filter_by(...), Post.query.filter(...)) en vez de armar el SQL
a mano con strings. Ahora el parametro que manda el usuario nunca se mete
directo en la consulta, SQLAlchemy lo bindea de forma segura por su cuenta.
Con esto arreglado volvi a activar el endpoint. Esto quedo en el commit
98937e3.

## Como verifique que si quedo arreglado

Despues de la remediacion volvi a probar el mismo payload de explotacion y
ya no funciono, el endpoint ya no deja alterar la consulta. Corri el
pipeline otra vez y paso en verde, sin hallazgos B608 ni nada HIGH o
CRITICAL.
