from flask import Blueprint, request, jsonify
from sqlalchemy import text
from models import db

buscar_bp = Blueprint("buscar", __name__)


def obtener_conexion():
    return db.engine.connect()


@buscar_bp.route("/publicaciones/buscar", methods=["GET"])
def buscar_por_usuario():
    nombre_usuario = request.args.get("usuario", "")

    consulta = (
        "SELECT posts.id, posts.content, posts.created_at "
        "FROM posts JOIN users ON posts.user_id = users.id "
        "WHERE users.username = '" + nombre_usuario + "' "
        "ORDER BY posts.created_at DESC LIMIT 20"
    )

    conexion = obtener_conexion()
    resultado = conexion.execute(text(consulta))
    publicaciones = [dict(fila._mapping) for fila in resultado]

    return jsonify({"usuario": nombre_usuario, "publicaciones": publicaciones})
