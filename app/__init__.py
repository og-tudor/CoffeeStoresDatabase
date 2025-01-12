from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from config import Config
from flask_bootstrap import Bootstrap

db = SQLAlchemy()
bootstrap = Bootstrap()

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)
    db.init_app(app)
    bootstrap.init_app(app)

    with app.app_context():
        from .routes import register_routes
        register_routes(app)

    return app
