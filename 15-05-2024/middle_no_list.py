def find_middle_number(lst):
    n = len(lst)
    
    if n == 0:
        return None  # Handle the case for an empty list
    
    middle_index = n // 2
    
    if n % 2 == 1:
        # Odd number of elements, return the middle one
        return lst[middle_index]
    else:
        # Even number of elements, return the average of the two middle elements
        return (lst[middle_index - 1] + lst[middle_index]) / 2

# Example usage
example_list_odd = [1, 2, 3, 4, 5]
example_list_even = [1, 2, 3, 4, 5, 6]

print("Middle number in odd-length list:", find_middle_number(example_list_odd))
print("Middle number in even-length list:", find_middle_number(example_list_even))
