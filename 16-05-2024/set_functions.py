def get_set_from_user(set_number):
    user_set = set()
    print(f"Enter elements for set {set_number} (type 'done' to finish):")
    
    while True:
        element = input("Enter element: ")
        if element.lower() == 'done':
            break
        user_set.add(element)
    
    return user_set

def main():
    # Get two sets from the user
    set1 = get_set_from_user(1)
    set2 = get_set_from_user(2)
    
    # Compute the intersection, union, and difference
    intersection = set1.intersection(set2)
    union = set1.union(set2)
    difference = set1.difference(set2)
    
    # Display the results
    print(f"Set 1: {set1}")
    print(f"Set 2: {set2}")
    print(f"Intersection: {intersection}")
    print(f"Union: {union}")
    print(f"Difference (Set 1 - Set 2): {difference}")

if __name__ == "__main__":
    main()
