from flask import Blueprint 
from controller import user_controller

router = Blueprint('router', __name__)

@router.route("/", methods=['GET'])
def hello_world():
    return "<p>Hello, World!</p>"

@router.route("/api/v1/users")
def api_v1_users():
        return user_controller.get_users()
