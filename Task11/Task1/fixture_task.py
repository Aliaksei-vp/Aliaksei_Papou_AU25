import time
import pytest

@pytest.fixture(scope="session", autouse=True)
def track_suite_time():
    start_time = time.time()
    yield
    end_time = time.time()
    print(f"\n[SUITE] Total time to complete the suite: {end_time - start_time:.4f} sec.")

@pytest.fixture()
def track_test_time():
    start_time = time.time()
    yield
    end_time = time.time()
    print(f"\n[TEST] Test execution time: {end_time - start_time:.4f} sec.")

def add_numbers(a, b):
    return a + b

def test_add_two_positive_numbers(track_test_time):
    a, b = 3, 5
    result = add_numbers(a, b)
    time.sleep(2)
    assert result == 8

def test_add_two_negative_numbers(track_test_time):
    a, b = -3, -5
    result = add_numbers(a, b)
    time.sleep(3)
    assert result == -8

def test_add_negative_and_positive_numbers():
    a, b = -3, 5
    result = add_numbers(a, b)
    time.sleep(10)
    assert result == 2
