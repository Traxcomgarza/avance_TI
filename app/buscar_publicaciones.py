"""
PARCHE - Nueva funcionalidad: buscar publicaciones por nombre de usuario
Tema: Red social de formato corto

Producto pide: dentro del feed, un cuadro de busqueda que permita encontrar
las publicaciones de un usuario especifico por su nombre. Integra este
endpoint en tu API (usa tu misma conexion a RDS).
"""
from flask import Blueprint, request, jsonify
import sqlalchemy

buscar_bp = Blueprint("buscar", __name__)


def obtener_conexion():
    # Reutiliza el engine/conexion que ya tienes configurado hacia RDS.
    from app.db import engine
    return engine.connect()


@buscar_bp.route("/publicaciones/buscar", methods=["GET"])
def buscar_por_usuario():
    """Devuelve las publicaciones de un usuario dado su nombre."""
    nombre_usuario = request.args.get("usuario", "")

    consulta = (
        "SELECT id, contenido, fecha_creacion FROM publicaciones "
        "WHERE usuario = '" + nombre_usuario + "' "
        "ORDER BY fecha_creacion DESC LIMIT 20"
    )

    conexion = obtener_conexion()
    resultado = conexion.execute(sqlalchemy.text(consulta))
    publicaciones = [dict(fila) for fila in resultado]

    return jsonify({"usuario": nombre_usuario, "publicaciones": publicaciones})
