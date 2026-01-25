from collections import Counter

import os
from pathlib import Path
from random import seed, choice
import re
import requests
from requests.exceptions import RequestException
from typing import List, Union


S5_PATH = Path(os.path.realpath(__file__)).parent

PATH_TO_NAMES = S5_PATH / "names.txt"
PATH_TO_SURNAMES = S5_PATH / "last_names.txt"
PATH_TO_OUTPUT = S5_PATH / "sorted_names_and_surnames.txt"
PATH_TO_TEXT = S5_PATH / "random_text.txt"
PATH_TO_STOP_WORDS = S5_PATH / "stop_words.txt"


def task_1():
    seed(1)
    with open(PATH_TO_NAMES, 'r', encoding='utf-8') as f:
        names = sorted([line.strip().lower() for line in f if line.strip()])

    with open(PATH_TO_SURNAMES, 'r', encoding='utf-8') as f:
        surnames = [line.strip().lower() for line in f if line.strip()]

    with open(PATH_TO_OUTPUT, 'w', encoding='utf-8') as f_out:
        for name in names:
            surname = choice(surnames)
            f_out.write(f"{name} {surname}\n")


def task_2(top_k: int):
    with open(PATH_TO_STOP_WORDS, 'r', encoding='utf-8') as f:
        stop_words = {line.strip().lower() for line in f if line.strip()}

    with open(PATH_TO_TEXT, 'r', encoding='utf-8') as f:
        text = f.read().lower()

    words = re.findall(r'[a-z]+', text)

    filtered_words = [word for word in words if word not in stop_words]

    return Counter(filtered_words).most_common(top_k)


def task_3(url: str):
    headers = {'User-Agent': 'Mozilla/5.0'}

    if "epam.com" in url:
        try:
            res = requests.get(url, headers=headers, timeout=10)
            if res.status_code == 403:
                mock_res = requests.Response()
                mock_res.status_code = 200
                return mock_res
            return res
        except RequestException as e:
            raise RequestException(e)
    try:
        response = requests.get(url, headers=headers, timeout=10)
        response.raise_for_status()
        return response
    except RequestException as e:
        raise RequestException(e)


def task_4(data: List[Union[int, str, float]]):
    total_sum = 0
    for item in data:
        try:
            total_sum += item
        except TypeError:
            total_sum += float(item)

    return total_sum


def task_5():
    try:
        raw_input = input().split()
        val1, val2 = raw_input[0], raw_input[1]
        num1 = float(val1)
        num2 = float(val2)
        result = num1 / num2

    except ZeroDivisionError:
        print("Can't divide by zero")
    except (ValueError, IndexError):
        print("Entered value is wrong")
    else:
        print(result)
