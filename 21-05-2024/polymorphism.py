class Vehicle:
    def __init__(self, name):
        self.name = name

    def move(self):
        raise NotImplementedError("Subclass must implement abstract method")

    def __str__(self):
        return f"This is a {self.name}"

class Bus(Vehicle):
    def move(self):
        return f"{self.name} is moving on the road."

class Boat(Vehicle):
    def move(self):
        return f"{self.name} is sailing on the water."

class Car(Vehicle):
    def move(self):
        return f"{self.name} is driving on the road."

class Plane(Vehicle):
    def move(self):
        return f"{self.name} is flying in the sky."

def vehicle_move(vehicle):
    print(vehicle.move())

# Creating instances of each class
bus = Bus("Bus")
boat = Boat("Boat")
car = Car("Car")
plane = Plane("Plane")

# Using the vehicle_move function to demonstrate polymorphism
vehicles = [bus, boat, car, plane]
for vehicle in vehicles:
    vehicle_move(vehicle)
