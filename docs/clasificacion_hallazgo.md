# Clasificacion del hallazgo

## Que tipo de falla es

Es una inyeccion SQL (CWE-89). La detecto bandit como B608
(hardcoded_sql_expressions). El endpoint /publicaciones/buscar tomaba el
parametro "usuario" y lo pegaba directo dentro del string de la consulta SQL
en lugar de usar parametros bindeados, entonces cualquiera podia meter su
propio SQL ahi y cambiar lo que hacia la consulta original.

## Severidad que le di

Alta. Probe manualmente y con un solo parametro por GET, sin necesitar login,
se puede meter un UNION SELECT y sacar el username y el password_hash de
toda la tabla de usuarios. No necesitas herramientas raras, con un curl
basta, y el impacto es grande porque se filtran las credenciales de todos
los usuarios registrados.

## Si fue falso positivo o no

No lo fue. Lo confirme explotando el endpoint con este payload:

x' UNION SELECT 1, username || ':' || password_hash, NOW() FROM users --


y me regreso el username y password_hash de los 9 usuarios que tenia
registrados en ese momento.

## Por que mi pipeline no lo detuvo al principio

Bandit si marco el hallazgo (B608), pero con severidad MEDIUM y confianza
LOW. Mi pipeline original solo bloqueaba si algo salia HIGH o CRITICAL, asi
que este parche paso sin problema. Tuve que ajustar el pipeline para que
bloqueara especificamente cualquier hallazgo con test_id B608, sin importar
que severidad le pusiera bandit.
