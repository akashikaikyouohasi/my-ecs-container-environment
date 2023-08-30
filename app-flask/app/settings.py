# coding: UTF-8
import os
from os.path import join, dirname
from dotenv import load_dotenv

# load local .env
dotenv_path = join(dirname(__file__), '.env')
load_dotenv(dotenv_path)

# MySQL config
MYSQL_ROOT_PASSWORD = os.environ.get("MYSQL_ROOT_PASSWORD")
MYSQL_HOST = os.environ.get("MYSQL_HOST")
MYSQL_DATABASE = os.environ.get("MYSQL_DATABASE")
MYSQL_USER = os.environ.get("MYSQL_USER")
MYSQL_PASSWORD = os.environ.get("MYSQL_PASSWORD")
