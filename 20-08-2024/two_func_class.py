class Contact:
    def store_contact(self, name, phone_number):
        self.name = name
        self.phone_number = phone_number

    def print_contact(self):
        print(f"Name: {self.name}, Phone Number: {self.phone_number}")

# Creating an object of the Contact class
contact = Contact()

# Storing the contact information
contact.store_contact("Akash", "1234567891")

# Printing the contact information
contact.print_contact()
