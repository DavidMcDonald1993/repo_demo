import pytest

from repo_demo.some_file import my_function


@pytest.mark.parametrize(
    "x, y, expected",
    [
        (1, 2, 3),
        (-1, -2, -3),
        (0, 0, 0),
        (5, -3, 2),
        (-7, 7, 0),
        (123456, 654321, 777777),
    ],
    ids=[
        "both positive",
        "both negative",
        "both zero",
        "positive and negative",
        "negative and positive",
        "large numbers",
    ],
)
def test_my_function(x: int, y: int, expected: int) -> None:
    assert my_function(x, y) == expected
