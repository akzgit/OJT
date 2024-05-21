#Create a class 'Shape' with a method 'area()'. Then create two subclasses, 'Rectangle' and 'Circle', which override the 'area()' 
# method to calculate the area of their respective shapes

class Shape:
    def area(self):
        raise NotImplementedError("Subclass must implement abstract method")

class Rectangle(Shape):
    def __init__(self, width, height):
        self.width = width
        self.height = height

    def area(self):
        return self.width * self.height

import math

class Circle(Shape):
    def __init__(self, radius):
        self.radius = radius

    def area(self):
        return math.pi * (self.radius ** 2)

# Creating instances of Rectangle and Circle
rectangle = Rectangle(10, 5)
circle = Circle(7)

# Printing the areas of the shapes
print(f"Area of the rectangle: {rectangle.area()}")  # Area of the rectangle: 50
print(f"Area of the circle: {circle.area()}")        # Area of the circle: 153.93804002589985
