from flask import Flask
from config import config
import router
import db

def create_app():
    app = Flask(__name__)

    # setting 
    app.config.from_object(config.Config)
    db.init_db(app)
    db.init_ma(app)

    # router
    app.register_blueprint(router.router)

    return app
app = create_app()

if __name__ == "__main__":
    app.run(host='0.0.0.0', debug=True, port=5000, threaded=True, use_reloader=True)

