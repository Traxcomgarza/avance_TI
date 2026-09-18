import json
from datetime import datetime
import os
import uuid
from functools import wraps

import boto3
import hashlib
import redis
from flask import Flask, jsonify, redirect, render_template, request, session, url_for
from models import Follow, Like, Post, User, db

app = Flask(__name__)
app.config["SECRET_KEY"] = os.environ["SECRET_KEY"]
app.config["SQLALCHEMY_DATABASE_URI"] = (
    f"postgresql://{os.environ['DB_USER']}:{os.environ['DB_PASSWORD']}"
    f"@{os.environ['DB_HOST']}:{os.environ.get('DB_PORT', '5432')}/{os.environ['DB_NAME']}"
)
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

db.init_app(app)

with app.app_context():
    db.create_all()
#  Rediscache del feed
redis_client = redis.Redis(
    host=os.environ.get("REDIS_HOST", "redis"),
    port=int(os.environ.get("REDIS_PORT", 6379)),
    decode_responses=True,
)
FEED_TTL_SECONDS = 30  


S3_BUCKET = os.environ.get("S3_BUCKET")
s3_client = boto3.client("s3", region_name=os.environ.get("AWS_REGION", "us-east-1"))


def login_required(view):
    @wraps(view)
    def wrapped(*args, **kwargs):
        if "user_id" not in session:
            if request.path.startswith("/api/"):
                return jsonify({"error": "no autenticado"}), 401
            return redirect(url_for("login"))
        return view(*args, **kwargs)

    return wrapped


def presigned_url(image_key):
    if not image_key:
        return None
    return s3_client.generate_presigned_url(
        "get_object",
        Params={"Bucket": S3_BUCKET, "Key": image_key},
        ExpiresIn=3600,
    )


def feed_cache_key(user_id: int) -> str:
    return f"feed:{user_id}"


def invalidate_feed_for_followers(target_user_id: int):
    """Invalida el feed cacheado de quienes siguen a target_user_id."""
    follower_ids = [
        f.follower_id for f in Follow.query.filter_by(followed_id=target_user_id).all()
    ]
    follower_ids.append(target_user_id) 
    if follower_ids:
        redis_client.delete(*[feed_cache_key(uid) for uid in follower_ids])


# ---------- Salud ----------
@app.route("/salud")
def salud():
    checks = {"db": False, "redis": False}
    try:
        db.session.execute(db.text("SELECT 1"))
        checks["db"] = True
    except Exception:
        pass
    try:
        redis_client.ping()
        checks["redis"] = True
    except Exception:
        pass
    status = 200 if all(checks.values()) else 503
    return jsonify({"status": "ok" if status == 200 else "degradado", "checks": checks}), status


# ---------- Auth ----------
@app.route("/register", methods=["GET", "POST"])
def register():
    if request.method == "GET":
        return render_template("register.html")
    username = request.form.get("username", "").strip()
    password = request.form.get("password", "")
    if not username or not password:
        return render_template("register.html", error="Usuario y contraseña son obligatorios")
    if User.query.filter_by(username=username).first():
        return render_template("register.html", error="Ese usuario ya existe")
    user = User(username=username)
    user.set_password(password)
    db.session.add(user)
    db.session.commit()
    session["user_id"] = user.id
    return redirect(url_for("feed"))


@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "GET":
        return render_template("login.html")
    username = request.form.get("username", "").strip()
    password = request.form.get("password", "")
    user = User.query.filter_by(username=username).first()
    if not user or not user.check_password(password):
        return render_template("login.html", error="Credenciales inválidas")
    session["user_id"] = user.id
    return redirect(url_for("feed"))


@app.route("/logout", methods=["POST"])
def logout():
    session.clear()
    return redirect(url_for("login"))


# ---------- Posts ----------
@app.route("/posts", methods=["POST"])
@login_required
def create_post():
    content = request.form.get("content", "").strip()
    if not content or len(content) > 280:
        return jsonify({"error": "contenido inválido (1-280 caracteres)"}), 400

    image_key = None
    file = request.files.get("image")
    if file and file.filename:
        image_key = f"posts/{uuid.uuid4().hex}_{file.filename}"
        s3_client.upload_fileobj(file, S3_BUCKET, image_key)

    post = Post(user_id=session["user_id"], content=content, image_key=image_key)
    db.session.add(post)
    db.session.commit()

    invalidate_feed_for_followers(session["user_id"])
    return redirect(url_for("feed"))


@app.route("/like/<int:post_id>", methods=["POST"])
@login_required
def like_post(post_id):
    existing = Like.query.filter_by(user_id=session["user_id"], post_id=post_id).first()
    if existing:
        db.session.delete(existing)
    else:
        db.session.add(Like(user_id=session["user_id"], post_id=post_id))
    db.session.commit()

    post = Post.query.get_or_404(post_id)
    invalidate_feed_for_followers(post.user_id)

    if request.headers.get("X-Requested-With") == "fetch":
        return jsonify({"likes": post.likes.count()})
    return redirect(request.referrer or url_for("feed"))


# ---------- Follow ----------
@app.route("/follow/<username>", methods=["POST"])
@login_required
def follow(username):
    target = User.query.filter_by(username=username).first_or_404()
    if target.id == session["user_id"]:
        return redirect(url_for("feed"))
    existing = Follow.query.filter_by(follower_id=session["user_id"], followed_id=target.id).first()
    if existing:
        db.session.delete(existing)
    else:
        db.session.add(Follow(follower_id=session["user_id"], followed_id=target.id))
    db.session.commit()
    redis_client.delete(feed_cache_key(session["user_id"]))
    return redirect(url_for("profile", username=username))


# ---------- Feed  ----------
@app.route("/")
@app.route("/feed")
@login_required
def feed():
    user_id = session["user_id"]
    cache_key = feed_cache_key(user_id)
    cached = redis_client.get(cache_key)

    if cached:
        posts_data = json.loads(cached)
        source = "cache"
    else:
        followed_ids = [f.followed_id for f in Follow.query.filter_by(follower_id=user_id).all()]
        followed_ids.append(user_id)
        posts = (
            Post.query.filter(Post.user_id.in_(followed_ids))
            .order_by(Post.created_at.desc())
            .limit(50)
            .all()
        )
        posts_data = [p.to_dict() for p in posts]
        redis_client.setex(cache_key, FEED_TTL_SECONDS, json.dumps(posts_data))
        source = "db"

    for p in posts_data:
        p["image_url"] = presigned_url(p.get("image_key"))

    return render_template("feed.html", posts=posts_data, source=source, username=_current_username())


@app.route("/u/<username>")
@login_required
def profile(username):
    user = User.query.filter_by(username=username).first_or_404()
    posts = user.posts.order_by(Post.created_at.desc()).all()
    is_following = Follow.query.filter_by(
    follower_id=session["user_id"], followed_id=user.id
    ).first() is not None
    posts_data = [p.to_dict() for p in posts]
    for p in posts_data:
        p["image_url"] = presigned_url(p.get("image_key"))

    return render_template(
        "profile.html",
        profile_user=user,
        posts=posts_data,
        is_following=is_following,
        username=_current_username(),
    )

@app.route("/usuarios")
@login_required
def usuarios():
    q = request.args.get("q", "").strip()
    query = User.query.filter(User.id != session["user_id"])
    if q:
        query = query.filter(User.username.ilike(f"%{q}%"))
    all_users = query.order_by(User.username).all()
    following_ids = {
        f.followed_id for f in Follow.query.filter_by(follower_id=session["user_id"]).all()
    }
    users_data = [
        {"username": u.username, "is_following": u.id in following_ids} for u in all_users
    ]
    return render_template("usuarios.html", users=users_data, username=_current_username(), q=q)

@app.route("/usuarios/buscar")
@login_required
def buscar_usuarios():
    q = request.args.get("q", "").strip()
    query = User.query.filter(User.id != session["user_id"])
    if q:
        query = query.filter(User.username.ilike(f"%{q}%"))
    all_users = query.order_by(User.username).limit(20).all()
    following_ids = {
        f.followed_id for f in Follow.query.filter_by(follower_id=session["user_id"]).all()
    }
    return jsonify(
        [{"username": u.username, "is_following": u.id in following_ids} for u in all_users]
    )

def _current_username():
    user = User.query.get(session.get("user_id"))
    return user.username if user else None

def avatar_hue(username: str) -> int:
    return int(hashlib.md5(username.encode(), usedforsecurity=False).hexdigest(), 16) % 360


app.jinja_env.globals["avatar_hue"] = avatar_hue
def format_date(iso_string):
    dt = datetime.fromisoformat(iso_string)
    meses = ["ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic"]
    return f"{dt.day} {meses[dt.month - 1]} {dt.year}"


app.jinja_env.filters["fecha"] = format_date

if __name__ == "__main__":
    with app.app_context():
        db.create_all()
    app.run(host="0.0.0.0", port=5000)
