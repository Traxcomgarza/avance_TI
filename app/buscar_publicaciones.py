
from flask import Blueprint, request, jsonify
from models import Post, User

buscar_bp = Blueprint("buscar", __name__)


@buscar_bp.route("/publicaciones/buscar", methods=["GET"])
def buscar_por_usuario():
    nombre_usuario = request.args.get("usuario", "").strip()

    user = User.query.filter_by(username=nombre_usuario).first()
    publicaciones = []
    if user:
        posts = (
            Post.query.filter_by(user_id=user.id)
            .order_by(Post.created_at.desc())
            .limit(20)
            .all()
        )
        publicaciones = [p.to_dict() for p in posts]

    return jsonify({"usuario": nombre_usuario, "publicaciones": publicaciones})
