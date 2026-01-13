# from collections import defaultdict as dd
# from itertools import product
from typing import Any, Dict, List, Tuple


def task_1(data_1: Dict[str, int], data_2: Dict[str, int]):
    result = data_1.copy()
    for key, value in data_2.items():
        if key in result:
            result[key] += value
        else:
            result[key] = value

    return result


def task_2():
    return {i: i ** 2 for i in range(1, 16)}


def task_3(data: Dict[Any, List[str]]):
    if not data:
        return []

    keys = list(data.keys())
    result: List[str] = []

    def backtrack(index: int, current_string: str) -> None:
        if index == len(keys):
            result.append(current_string)
            return
        current_key = keys[index]
        letters = data[current_key]
        for char in letters:
            backtrack(index + 1, current_string + char)
    backtrack(0, "")

    return result


def task_4(data: Dict[str, int]):
    result = []
    for key in sorted(data, key=data.get, reverse=True):
        result.append(key)
        if len(result) == 3:
            break
    return result


def task_5(data: List[Tuple[Any, Any]]) -> Dict[str, List[int]]:
    result = {}
    for key, value in data:
        if key not in result:
            result[key] = []
        result[key].append(value)

    return result


def task_6(data: List[Any]):
    result = []
    seen = set()
    for item in data:
        if item not in seen:
            result.append(item)
            seen.add(item)

    return result


def task_7(words: [List[str]]) -> str:
    if not words:
        return ""
    prefix = words[0]
    for i in range(1, len(words)):
        while not words[i].startswith(prefix):
            prefix = prefix[:-1]
            if not prefix:
                return ""

    return prefix


def task_8(haystack: str, needle: str) -> int:
    if not needle:
        return 0

    n, h = len(needle), len(haystack)
    for i in range(h - n + 1):
        # Проверяем срез строки
        if haystack[i:i + n] == needle:
            return i

    return -1
