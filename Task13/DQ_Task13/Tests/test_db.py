import pytest
import allure
from Tests.conftest import get_sql_data

@allure.feature("DB Smoke")
@pytest.mark.smoke
@pytest.mark.parametrize("test_data", get_sql_data('smoke_tests'), ids=lambda d: d['name'])
def test_db_smoke(db_cursor, test_data):
    with allure.step(f"SQL: {test_data['sql']}"):
        db_cursor.execute(test_data['sql'])
        result = db_cursor.fetchone()[0]
    with allure.step("Verify"):
        assert result == test_data['expected']

@allure.feature("DB Critical")
@pytest.mark.critical
@pytest.mark.parametrize("test_data", get_sql_data('critical_tests'), ids=lambda d: d['name'])
def test_db_critical(db_cursor, test_data):
    with allure.step(f"SQL: {test_data['sql']}"):
        db_cursor.execute(test_data['sql'])
        result = db_cursor.fetchone()[0]
    with allure.step("Verify"):
        assert result == test_data['expected']
