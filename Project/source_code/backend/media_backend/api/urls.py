from django.urls import path
from .views import (
    object_detection, describe_image, add_face, recognize_face, 
    read_text, activity_recognition, detect_currency
)

urlpatterns = [
    path('yolo/', object_detection),
    path('describe/', describe_image),
    path('add_face/', add_face),
    path('recognize_face/', recognize_face),
    path('read_text/', read_text),
    path('activity/', activity_recognition),
    path('currency/', detect_currency),
]
