class MyClass:
    # Class attribute
    shared_property = "This value is the same for all instances"

    def __init__(self, instance_value):
        # Instance attribute
        self.instance_value = instance_value

# Creating instances
obj1 = MyClass("Value for obj1")
obj2 = MyClass("Value for obj2")

# Accessing the class attribute
print(obj1.shared_property)  # Output: This value is the same for all instances
print(obj2.shared_property)  # Output: This value is the same for all instances

# Accessing instance attributes
print(obj1.instance_value)  # Output: Value for obj1
print(obj2.instance_value)  # Output: Value for obj2

# Modifying the class attribute
MyClass.shared_property = "New shared value"

# All instances will see the updated class attribute
print(obj1.shared_property)  # Output: New shared value
print(obj2.shared_property)  # Output: New shared value
