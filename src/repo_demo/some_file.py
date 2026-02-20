def my_function(x: int, y: int) -> int:
    """Adds two numbers.

    Args:
        x: The first number.
        y: The second number.

    Returns:
        The sum of the two numbers.
    """
    return x + y


if __name__ == "__main__":
    result = my_function(3, 5)
    print(f"The result is: {result}")
