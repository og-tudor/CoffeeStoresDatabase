from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from config import Config

db = SQLAlchemy()

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)
    db.init_app(app)

    # Importăm rutele aici, după inițializarea aplicației
    with app.app_context():
        from . import routes  # Importă routes fără a crea ciclu
        db.create_all()  # Creează tabelele

    return app
