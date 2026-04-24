import pytest
import psycopg2
import yaml
import allure

@pytest.fixture(scope="session")
def db_connection():
    conn = psycopg2.connect(
        database="dwh_hw_db",
        user='postgres',
        password='xh1931',
        host='localhost',
        port='5432'
    )
    yield conn
    conn.close()

@pytest.fixture()
def db_cursor(db_connection):
    cursor = db_connection.cursor()
    yield cursor
    db_connection.rollback()
    cursor.close()

def get_sql_data(category):
    with open('config_db.yaml', 'r') as f:
        data = yaml.safe_load(f)
    return data[category]
