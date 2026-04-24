import pytest
import yaml

def get_numbers_data(config_name):
    with open(config_name, 'r') as stream:
        config = yaml.safe_load(stream)
    return config['cases']

def add_numbers(a, b, c):
    if not all(isinstance(x, (int, float)) for x in [a, b, c]):
        raise TypeError('Please check the parameters. All of them must be numeric')
    return a + b + c

cases = get_numbers_data('config.yaml')

@pytest.mark.smoke
@pytest.mark.parametrize(
    "data",
    cases,
    ids=[case['case_name'] for case in cases]
)
def test_add_numbers(data):
    result = add_numbers(*data['input'])
    assert result == data['expected']

@pytest.mark.critical
def test_add_invalid_types():
    with pytest.raises(TypeError) as excinfo:
        add_numbers('a', 2, 1)
    assert 'Please check the parameters. All of them must be numeric' in str(excinfo.value)
