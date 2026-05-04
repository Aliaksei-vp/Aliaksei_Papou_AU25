import pytest
import os
import psycopg2
import yaml
import boto3
import requests
from selenium import webdriver
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.chrome.service import Service
from google.cloud import storage
from botocore.config import Config
from botocore import UNSIGNED
from Pages.captureReportPage import CaptureReportPage

# --- fixture Time ---
@pytest.fixture(scope="session", autouse=True)
def track_suite_time():
    import time
    start = time.time()
    yield
    print(f"\n[SUITE] Total: {time.time() - start:.2f}s")

# --- fixture DB ---
@pytest.fixture(scope="session")
def db_connection():
    db_pass = os.getenv('DB_PASSWORD')
    conn = psycopg2.connect(
        database="dwh_hw_db",
        user='postgres',
        password=db_pass,
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
    with open('Configs/config_db.yaml', 'r') as f:
        data = yaml.safe_load(f)
    return data[category]

# --- fixture browser ---
def get_config():
    current_dir = os.path.dirname(os.path.abspath(__file__))
    config_path = os.path.join(current_dir, '..', 'Configs', 'config_selenium.yaml')
    with open(config_path, 'r') as f:
        return yaml.safe_load(f)['global']


@pytest.fixture(scope="function")
def pbi_page():
    conf = get_config()
    options = webdriver.ChromeOptions()
    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)
    driver.maximize_window()
    driver.get(conf['report_uri'])

    page = CaptureReportPage(driver, conf['delay'])
    yield page
    driver.quit()


@pytest.fixture
def driver():
    options = webdriver.ChromeOptions()
    options.add_experimental_option("excludeSwitches", ["enable-automation"])
    options.add_experimental_option('useAutomationExtension', False)

    driver = webdriver.Chrome(options=options)
    driver.maximize_window()

    yield driver
    driver.quit()

# --- fixture Cloud/API ---
@pytest.fixture(scope='session')
def browser():
    options = webdriver.ChromeOptions()
    options.add_argument("--headless")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    driver = webdriver.Chrome(options=options)
    yield driver
    driver.quit()

@pytest.fixture(scope='function')
def provide_config():
    return {
        'prefix': '2024/01/01/KTLX/',
        'gcp_bucket_name': "gcp-public-data-nexrad-l2",
        'aws_bucket_name': 'unidata-nexrad-level2',
        's3_anon_client': boto3.client('s3', config=Config(signature_version=UNSIGNED)),
        'gcp_storage_anon_client': storage.Client.create_anonymous_client()
    }

@pytest.fixture(scope='function')
def gcp_objects(provide_config):
    config = provide_config
    blobs = config['gcp_storage_anon_client'].list_blobs(
        config['gcp_bucket_name'],
        prefix=config['prefix']
    )
    return [blob.name for blob in blobs]

@pytest.fixture(scope='function')
def aws_objects(provide_config):
    config = provide_config
    response = config['s3_anon_client'].list_objects(
        Bucket=config['aws_bucket_name'],
        Prefix=config['prefix']
    )
    return [content['Key'] for content in response.get('Contents', [])]

@pytest.fixture(scope='function')
def user_posts():
    url = "https://jsonplaceholder.typicode.com/posts"
    response = requests.get(url, params={'userId': 3}, timeout=10)
    response.raise_for_status()
    return response.json()
