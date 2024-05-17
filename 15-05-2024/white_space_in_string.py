# Original string
original_string = "This is an example string with white spaces."

# Initialize a counter
num_white_spaces = 0

# Iterate through the string and count white spaces
for char in original_string:
    if char == ' ':
        num_white_spaces += 1

# Print the number of white spaces
print("Number of white spaces:", num_white_spaces)
