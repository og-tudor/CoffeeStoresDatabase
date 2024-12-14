from flask import current_app as app

from flask import render_template, request, jsonify
from . import db
from .models import User

@app.route('/')
def index():
    return "Welcome to the Project"

@app.route('/users', methods=['GET'])
def get_users():
    users = User.query.all()
    return jsonify([{'id': user.id, 'name': user.name} for user in users])
