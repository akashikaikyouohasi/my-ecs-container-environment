from db import database, marshmallow
from sqlalchemy.dialects.mysql import TIMESTAMP as Timestamp
from sqlalchemy.sql.functions import current_timestamp

class User(database.Model):
    # テーブル定義
    __tablename__ = 'users'
    id = database.Column(database.Integer, autoincrement=True, primary_key=True)
    name = database.Column(database.String(225), nullable=False)
    created_at = database.Column(Timestamp, server_default=current_timestamp(), nullable=False)
    updated_at = database.Column(Timestamp, server_default=current_timestamp(), nullable=False)

    # コンストラクタ
    def __init__(self, id, name, created_at, updated_at):
        self.id = id
        self.name = name
        self.created_at = created_at
        self.updated_at = updated_at

    def get_user_list():
        # SELECT * FROM users
        user_list = database.session.query(User).all()
        if user_list == None:
            return []
        else:
            return user_list
    
    def get_user_by_id(id):
        return database.session.query(User).filter(User.id == id).one()

    def create_user(user):
        record = User(
            name = user['name'],
        )
        # INSERT INTO users(name) VALUES(...)
        database.session.add(record)
        database.session.commit() # クエリ実行
        return user


class UserSchema(marshmallow.SQLAlchemyAutoSchema):
    class Meta:
        model = User
