from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow 

database = SQLAlchemy()
marshmallow = Marshmallow()

def init_db(app):
  database.init_app(app)

def init_ma(app):
  marshmallow.init_app(app)