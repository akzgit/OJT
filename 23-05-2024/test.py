import torch
from matplotlib import pyplot as plt

# Load the YOLOv5 model
model = torch.hub.load('ultralytics/yolov5', 'yolov5s', pretrained=True)

# Function to load and process an image
def detect_objects(model, img_path):
    # Perform inference
    results = model(img_path)
    results.print()  # Print results to the console
    return results

# Path to your image
image_path = 'Untitled2.jpg'

# Detect objects in the image
results = detect_objects(model, image_path)

# Display the results
# This will plot the images with bounding boxes and labels
results.show()  # Show detected image with bounding boxes

# Optionally, if you want to save the output images with detections
results.save(save_dir='path/to/save')  # Specify the directory to save output images

# If you want to plot using matplotlib (optional)
plt.figure(figsize=(10, 10))  # Set figure size
plt.imshow(plt.imread(f"{results.files[0]}"))  # Display image from the results
plt.axis('off')  # Hide the axes
plt.show()
