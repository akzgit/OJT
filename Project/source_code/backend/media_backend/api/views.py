from django.shortcuts import render

# Create your views here.


# Feature 1: Continuous Object Detection Using YOLOv5
import torch
from PIL import Image
from django.core.files.storage import default_storage
from rest_framework.decorators import api_view
from rest_framework.response import Response
import os

# Load YOLOv5 model
yolo_model = torch.hub.load('ultralytics/yolov5', 'yolov5s')

@api_view(['POST'])
def object_detection(request):
    if 'file' in request.FILES:
        image = request.FILES['file']
        file_path = default_storage.save(os.path.join('uploads', image.name), image)
        img = Image.open(file_path)

        # Perform object detection
        results = yolo_model(img)
        objects_detected = results.pandas().xyxy[0].to_dict(orient="records")

        return Response({"detected_objects": objects_detected})
    return Response({"error": "No image provided"}, status=400)

# Feature 2: Image Description Using OpenAI GPT-4

import base64
import requests
from django.core.files.storage import default_storage
from rest_framework.decorators import api_view
from rest_framework.response import Response
import os

# OpenAI API Key
api_key = "YOUR_OPENAI_API_KEY"

@api_view(['POST'])
def describe_image(request):
    if 'file' in request.FILES:
        image = request.FILES['file']
        file_path = default_storage.save(os.path.join('uploads', image.name), image)
        
        # Convert image to base64
        with open(file_path, "rb") as image_file:
            base64_image = base64.b64encode(image_file.read()).decode('utf-8')

        # Make request to OpenAI API
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {api_key}"
        }
        payload = {
            "model": "gpt-4o-mini",
            "messages": [
                {
                    "role": "user",
                    "content": [
                        {"type": "text", "text": "What's in this image?"},
                        {"type": "image_url", "image_url": {"url": f"data:image/jpeg;base64,{base64_image}"}}
                    ]
                }
            ],
            "max_tokens": 300
        }
        
        response = requests.post("https://api.openai.com/v1/chat/completions", headers=headers, json=payload)
        if response.status_code == 200:
            description = response.json()['choices'][0]['message']['content']
            return Response({"description": description})
        else:
            return Response({"error": "OpenAI API error"}, status=response.status_code)
    return Response({"error": "No image provided"}, status=400)


# Feature 3: Add Face for Recognition
import face_recognition
from django.core.files.storage import default_storage
from rest_framework.decorators import api_view
from rest_framework.response import Response
import os

@api_view(['POST'])
def add_face(request):
    if 'file' in request.FILES and 'name' in request.data:
        image = request.FILES['file']
        name = request.data['name']
        file_path = default_storage.save(os.path.join('faces', f'{name}.jpg'), image)
        return Response({"status": "Face added successfully"})
    return Response({"error": "No face or name provided"}, status=400)

@api_view(['POST'])
def recognize_face(request):
    if 'file' in request.FILES:
        image = request.FILES['file']
        file_path = default_storage.save(os.path.join('uploads', image.name), image)
        unknown_image = face_recognition.load_image_file(file_path)
        unknown_encoding = face_recognition.face_encodings(unknown_image)[0]

        for face_file in os.listdir('media/faces'):
            known_image = face_recognition.load_image_file(f'media/faces/{face_file}')
            known_encoding = face_recognition.face_encodings(known_image)[0]
            results = face_recognition.compare_faces([known_encoding], unknown_encoding)
            if results[0]:
                return Response({"name": face_file.split('.')[0]})
        return Response({"status": "No match found"})
    return Response({"error": "No image provided"}, status=400)


# Feature 4: Activity Recognition
import tensorflow as tf
import tensorflow_hub as hub
import numpy as np
import pandas as pd
from moviepy.editor import VideoFileClip
from django.core.files.storage import default_storage
from rest_framework.decorators import api_view
from rest_framework.response import Response
from PIL import Image
import os

# Path to the activity labels CSV file
LABELS_PATH = os.path.join('static_data', 'kinetics_600_labels.csv')

# Load the activity labels from the CSV file (use 'name' as the column name for activity labels)
labels_df = pd.read_csv(LABELS_PATH)
activity_labels = labels_df['name'].tolist()  # Updated to use 'name' column

# Load the MoViNet-A2 model pre-trained on Kinetics-600
model = hub.load('https://tfhub.dev/tensorflow/movinet/a2/base/kinetics-600/classification/3')

@api_view(['POST'])
def activity_recognition(request):
    if 'file' in request.FILES:
        video = request.FILES['file']
        file_path = default_storage.save(os.path.join('uploads', video.name), video)

        # Process the video into frames
        clip = VideoFileClip(file_path)
        frames = [frame for frame in clip.iter_frames(fps=5)]  # Take 5 FPS to reduce computation

        # Resize frames and stack them as a batch
        def preprocess_frame(frame):
            # Preprocess frames to 224x224, MoViNet expects 224x224x3 inputs
            frame = tf.image.resize(frame, [224, 224])
            frame = tf.cast(frame, tf.float32) / 255.0  # Normalize to [0, 1]
            return frame

        frames_tensor = tf.convert_to_tensor([preprocess_frame(frame) for frame in frames])

        # MoViNet expects frames in [Batch, NumFrames, H, W, C] format
        frames_tensor = tf.expand_dims(frames_tensor, axis=0)  # Add batch dimension

        # Perform activity recognition
        outputs = model(frames_tensor)
        predictions = tf.nn.softmax(outputs, axis=-1)
        top_indices = np.argsort(predictions)[0, ::-1][:10]  # Get top 10 predictions

        # Filter predictions with confidence greater than 30%
        results = [(activity_labels[i], float(predictions[0][i]) * 100) 
                   for i in top_indices 
                   if predictions[0][i] > 0.3]

        return Response({"activities": results})
    return Response({"error": "No video provided"}, status=400)


# Feature 5: Text Extraction

import pytesseract
from PIL import Image
from django.core.files.storage import default_storage
from rest_framework.decorators import api_view
from rest_framework.response import Response
import os

# Path to Tesseract executable (if required, set the path explicitly)
pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'  # Update this path

@api_view(['POST'])
def read_text(request):
    if 'file' in request.FILES:
        image = request.FILES['file']
        file_path = default_storage.save(os.path.join('uploads', image.name), image)
        img = Image.open(file_path)

        # Use Tesseract to extract text from the image
        extracted_text = pytesseract.image_to_string(img)

        return Response({"extracted_text": extracted_text})
    return Response({"error": "No image provided"}, status=400)


# Feature 5: Currency recognition 
import torch
from PIL import Image
from django.core.files.storage import default_storage
from rest_framework.decorators import api_view
from rest_framework.response import Response
import os

# Load the custom currency recognition model
model = torch.load('/path/to/your_custom_currency_model.pth', map_location=torch.device('cpu'))
model.eval()

# Define currency labels
currency_labels = {0: "10 Rupee", 1: "20 Rupee", 2: "50 Rupee", 3: "100 Rupee", 4: "500 Rupee", 5: "2000 Rupee"}

@api_view(['POST'])
def detect_currency(request):
    if 'file' in request.FILES:
        image = request.FILES['file']
        file_path = default_storage.save(os.path.join('uploads', image.name), image)
        img = Image.open(file_path)

        # Preprocess the image for the model (adjust as necessary for your model's requirements)
        preprocess = transforms.Compose([
            transforms.Resize((224, 224)),  # Adjust this size as required
            transforms.ToTensor(),
        ])
        input_tensor = preprocess(img).unsqueeze(0)  # Add batch dimension

        # Make prediction
        with torch.no_grad():
            outputs = model(input_tensor)
            confidence, predicted_class = torch.max(outputs, 1)

        return Response({
            "currency": currency_labels[int(predicted_class)],
            "confidence": confidence.item() * 100
        })
    return Response({"error": "No image provided"}, status=400)
