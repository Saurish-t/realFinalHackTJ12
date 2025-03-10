# -*- coding: utf-8 -*-
"""VIDEOAnalyze.ipynb

Automatically generated by Colab.

Original file is located at
    https://colab.research.google.com/drive/1kNGaFargl_ZDCXW66GxSWGbcpOnlCvgE
"""

import os
import cv2
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Conv2D, Flatten, MaxPooling2D, Dropout
from tensorflow.keras.optimizers import Adam


emotion_map = {
    'angry': 0,
    'disgust': 1,
    'fear': 2,
    'happy': 3,
    'sad': 4,
    'surprise': 5,
    'neutral': 6
}


reverse_emotion_map = {v: k for k, v in emotion_map.items()}

def load_dataset(dataset_path):
    csv_path = os.path.join(dataset_path, "formatted_dataset.csv")

    if not os.path.exists(csv_path):
        raise FileNotFoundError(f"Dataset file not found at {csv_path}")

    print("Loading dataset...")
    data = pd.read_csv(csv_path)

    images = []
    labels = []

    for i, row in data.iterrows():
        pixels = np.fromstring(row["pixels"], sep=" ").reshape(48, 48)
        images.append(pixels)
        labels.append(emotion_map.get(row["emotion"], -1))

    images = np.array(images, dtype=np.uint8)
    labels = np.array(labels, dtype=np.int64)

    print(f"Loaded {len(images)} images.")
    return images, labels

def preprocess_images(images):
    processed_images = []

    for img in images:
        img = cv2.resize(img, (48, 48))
        img = img.astype("float32") / 255.0
        processed_images.append(img)

    return np.array(processed_images)


def preprocess_test_image(test_image_path):
    img = cv2.imread(test_image_path, cv2.IMREAD_GRAYSCALE)
    if img is None:
        raise FileNotFoundError(f"Test image not found at {test_image_path}")

    img = cv2.resize(img, (48, 48))
    img = img.astype("float32") / 255.0
    img = np.expand_dims(img, axis=-1)
    return np.array([img])


def create_model():
    model = Sequential([
        Conv2D(64, (3, 3), activation='relu', input_shape=(48, 48, 1)),
        MaxPooling2D(2, 2),
        Conv2D(128, (3, 3), activation='relu'),
        MaxPooling2D(2, 2),
        Flatten(),
        Dense(128, activation='relu'),
        Dropout(0.5),
        Dense(7, activation='softmax')
    ])

    model.compile(optimizer=Adam(), loss='sparse_categorical_crossentropy', metrics=['accuracy'])
    return model


def train_model(X_train, y_train):
    model = create_model()
    model.fit(X_train, y_train, epochs=10, batch_size=32, validation_split=0.2)
    return model


def predict_emotion(model, test_image):
    prediction = model.predict(test_image)
    predicted_label = np.argmax(prediction, axis=1)[0]
    emotion = reverse_emotion_map[predicted_label]
    return emotion


dataset_path = "C:/Users/kisla/Downloads/HackTjBackend25"

if dataset_path:

    images, labels = load_dataset(dataset_path)
    images = preprocess_images(images)


    X_train, X_val, y_train, y_val = train_test_split(images, labels, test_size=0.2, random_state=42, stratify=labels)
    X_train = np.expand_dims(X_train, axis=-1)
    X_val = np.expand_dims(X_val, axis=-1)

    print(f"Training set: {X_train.shape}, Validation set: {X_val.shape}")


    model = train_model(X_train, y_train)


    test_image_path = "C:/Users/kisla/Downloads/archive (3)/angry/Training_992349.jpg"
    test_image = preprocess_test_image(test_image_path)


    emotion = predict_emotion(model, test_image)

    print(f"The predicted emotion for the test image is: {emotion}")

model.save('emotion_recognition_model.keras')