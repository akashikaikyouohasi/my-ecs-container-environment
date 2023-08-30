import settings

class SystemConfig:
    # Flask
    DEBUG = True

    # SQLAlchemy
    SQLALCHEMY_DATABASE_URI = 'mysql+pymysql://{user}:{password}@{host}/{db}?charset=utf8mb4'.format(**{
        'user': settings.MYSQL_USER,
        'password': settings.MYSQL_PASSWORD,
        'host': settings.MYSQL_HOST,
        'db': settings.MYSQL_DATABASE
    })
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_ECHO = True # Print executed SQL 

# 外部に見せる用
Config = SystemConfig
