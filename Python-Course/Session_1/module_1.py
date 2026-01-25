from typing import List


def task_1(array: List[int], target: int) -> List[int]:
    """
    Write your code below
    """
    seen = set()
    for num in array:
        diff = target - num
        if diff in seen:
            return [diff, num]
        seen.add(num)

    return []


def task_2(number: int) -> int:
    """
    Write your code below
    """
    sign = -1 if number < 0 else 1
    number = abs(number)
    reversed_num = 0
    while number > 0:
        digit = number % 10
        reversed_num = reversed_num * 10 + digit
        number //= 10

    return reversed_num * sign


def task_3(array: List[int]) -> int:
    """
    Write your code below
    """
    for x in array:
        val = abs(x)
        if array[val - 1] < 0:
            return val
        array[val - 1] *= -1

    return -1


def task_4(string: str) -> int:
    """
    Write your code below
    """
    roman_map = {
        'I': 1, 'V': 5, 'X': 10, 'L': 50,
        'C': 100, 'D': 500, 'M': 1000
    }
    total = 0
    for i in range(len(string)):
        current_val = roman_map[string[i]]
        if i + 1 < len(string) and current_val < roman_map[string[i + 1]]:
            total -= current_val
        else:
            total += current_val

    return total


def task_5(array: List[int]) -> int:
    """
    Write your code below
    """
    if not array:
        return 0
    minimum = array[0]
    for num in array:
        if num < minimum:
            minimum = num

    return minimum
