import cv2
import numpy as np
import sys
import os

# Path to save cropped image
output_path = sys.argv[2]

# Load the image
input_image_path = sys.argv[1]
img = cv2.imread(input_image_path)

if img is None:
    print(f"Error loading image: {input_image_path}")
    sys.exit(1)

# Convert the image to grayscale (required for face detection)
gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

# Load pre-trained Haar Cascade Classifier for face detection
face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')

# Detect faces in the image
faces = face_cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5, minSize=(30, 30), flags=cv2.CASCADE_SCALE_IMAGE)

if len(faces) == 0:
    print("No faces detected, cropping the center of the image")
    # If no faces detected, crop the center of the image
    height, width = img.shape[:2]
    center = (width // 2, height // 2)
    size = min(width, height)
    cropped_img = img[center[1] - size // 2:center[1] + size // 2, center[0] - size // 2:center[0] + size // 2]
else:
    # Crop around the largest face
    x, y, w, h = max(faces, key=lambda rect: rect[2] * rect[3])  # Find the largest face by area
    cropped_img = img[y:y+h, x:x+w]

# Save the cropped image
cv2.imwrite(output_path, cropped_img)

# Optionally, show the result
# cv2.imshow('Cropped Image', cropped_img)
# cv2.waitKey(0)
# cv2.destroyAllWindows()

print(f"Cropped image saved to {output_path}")

