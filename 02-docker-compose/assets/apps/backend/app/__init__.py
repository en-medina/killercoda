from flask import Flask
from flask_cors import CORS
import redis
import os

def create_app():
    app = Flask(__name__)
    CORS(app)

    # Redis connection with connection pooling
    redis_host = os.getenv('REDIS_HOST', 'localhost')
    redis_port = int(os.getenv('REDIS_PORT', 6379))

    pool = redis.ConnectionPool(
        host=redis_host,
        port=redis_port,
        decode_responses=True,
        socket_connect_timeout=5,
        socket_timeout=5,
        socket_keepalive=True,
        health_check_interval=30,
        max_connections=10,
        retry_on_timeout=True
    )

    app.redis_client = redis.Redis(connection_pool=pool)

    # Register routes
    from app.routes import bp
    app.register_blueprint(bp)

    return app
