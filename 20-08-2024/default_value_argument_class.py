class Vehicle:
    def __init__(self, name, max_speed, mileage):
        self.name = name
        self.max_speed = max_speed
        self.mileage = mileage

class Bus(Vehicle):  # Capitalize the class name
    def seating_capacity(self, capacity=50):
        return f"The seating capacity of a {self.name} is {capacity} passengers"

# Creating an instance of Bus and calling the seating_capacity method
print(Bus("School Bus", 120, 2990).seating_capacity())  # Added print to display the result
