#an iterator that returns numbers, starting with 1, and each sequence will increase by 1 using class (returning 1,2,3,4,5)

class MyNumbers:
    def __init__(self, limit):
        self.limit = limit

    def __iter__(self):
        self.a = 1
        return self

    def __next__(self):
        if self.a > self.limit:
            raise StopIteration
        x = self.a
        self.a += 1
        return x

# Usage example:
myclass = MyNumbers(5)
myiter = iter(myclass)

print(next(myiter))  # 1
print(next(myiter))  # 2
print(next(myiter))  # 3
print(next(myiter))  # 4
print(next(myiter))  # 5
# The next call to next(myiter) will raise StopIteration
