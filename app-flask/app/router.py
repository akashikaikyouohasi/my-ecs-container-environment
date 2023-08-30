from flask import Blueprint 

router = Blueprint('router', __name__)

@router.route("/", methods=['GET'])
def hello_world():
    return "<p>Hello, World!</p>"
