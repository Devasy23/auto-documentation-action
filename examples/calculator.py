```python
def fibonacci(n):
    """Compute the nth Fibonacci number.

    Args:
        n: The index of the desired Fibonacci number (non-negative integer).

    Returns:
        The nth Fibonacci number.

    Raises:
        ValueError: If n is negative.

    """
    if n < 0:
        raise ValueError("Input must be a non-negative integer.")
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

class Calculator:
    """A simple calculator class.

    This class provides basic arithmetic operations.
    """
    def add(self, a, b):
        """Add two numbers.

        Args:
            a: The first number.
            b: The second number.

        Returns:
            The sum of a and b.
        """
        return a + b
    
    def subtract(self, a, b):
        """Subtract two numbers.

        Args:
            a: The first number.
            b: The second number.

        Returns:
            The difference between a and b.
        """
        return a - b

def process_list(items, filter_func):
    """Applies a filter function to a list.

    Args:
        items: The input list.
        filter_func: A function that takes a single item and returns a boolean.

    Returns:
        A new list containing only the items that satisfy the filter function.
    """
    return [item for item in items if filter_func(item)]
```
