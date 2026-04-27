import pytest
import requests
import boto3
from botocore import UNSIGNED
from botocore.config import Config
from google.cloud import storage
from selenium import webdriver

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
