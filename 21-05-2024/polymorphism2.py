#Create a Bus child class that inherits from the Vehicle class. The default fare charge of any vehicle is seating capacity * 100.
#If Vehicle is Bus instance, we need to add an extra 10% on full fare as a maintenance charge.
#So total fare for bus instance will become the final amount = total fare + 10% of the total fare.

class Vehicle:
    def __init__(self, name, seating_capacity):
        self.name = name
        self.seating_capacity = seating_capacity

    def move(self):
        raise NotImplementedError("Subclass must implement abstract method")

    def fare(self):
        return self.seating_capacity * 100

    def __str__(self):
        return f"This is a {self.name} with a seating capacity of {self.seating_capacity}"

class Bus(Vehicle):
    def move(self):
        return f"{self.name} is moving on the road."

    def fare(self):
        base_fare = super().fare()
        total_fare = base_fare + 0.1 * base_fare
        return total_fare

# Creating an instance of the Bus class
bus = Bus("City Bus", 50)

# Printing the details of the bus
print(bus)  # This is a City Bus with a seating capacity of 50

# Printing the move action
print(bus.move())  # City Bus is moving on the road.

# Printing the fare
print(f"Total fare for the bus is: {bus.fare()}")  # Total fare for the bus is: 5500.0
