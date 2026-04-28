import pytest
import yaml
import allure

def add_numbers(a, b, c):
    if not all(isinstance(x, (int, float)) for x in [a, b, c]):
        raise TypeError('All parameters must be numeric')
    return a + b + c

def get_numbers_data():
    with open('Configs/config_unit.yaml', 'r') as f:
        return yaml.safe_load(f)['cases']

@allure.feature("Unit Tests")
@pytest.mark.parametrize("data", get_numbers_data(), ids=lambda d: d['case_name'])
def test_add_numbers_logic(data):
    result = add_numbers(*data['input'])
    assert result == data['expected']
