# vitalex
# VITALEX

## Overview

Vitalex is a Flutter-based mobile application designed to assist individuals with dyslexia through simple screening and supportive tools. The application focuses on providing accessible learning support, interactive activities, and assistive features to help users manage reading and comprehension challenges.

The goal of Vitalex is to create an easy-to-use and supportive platform that promotes better learning experiences for users with dyslexia.

---

## Features

* User authentication using Firebase
* Simple dyslexia screening test
* Interactive games for cognitive support
* Coping assistance tools for reading difficulties
* Text-to-speech functionality
* Secure cloud storage using Firestore
* Clean and accessible user interface

---

## Technologies Used

* Flutter
* Dart
* Firebase Authentication
* Cloud Firestore
* Firebase Core

---
## project structure
VITALEX/
│
├── .dart_tool/                 # Flutter build system files (auto-generated)
├── .idea/                      # IDE configuration (Android Studio/IntelliJ)
├── android/                    # Android platform-specific code
├── ios/                        # iOS platform-specific code
├── linux/                      # Linux support files
├── macos/                      # macOS support files
├── windows/                    # Windows support files
├── web/                        # Web support files
│
├── assets/                     # Images, audio, and other static resources
│
├── build/                      # Compiled output (auto-generated)
│
├── lib/                        # Main application source code
│   ├── screens/                # UI screens (pages of the app)
│   ├── services/               # Firebase, file handling, TTS logic
│   ├── utils/                  # Helper functions and utilities
│   ├── firebase_options.dart   # Firebase configuration (generated)
│   └── main.dart               # App entry point
│
├── test/                       # Unit and widget tests
│
├── .flutter-plugins-dependencies  # Flutter plugin metadata
├── .gitignore                  # Files ignored by Git
├── .metadata                   # Flutter project metadata
├── analysis_options.yaml       # Linting rules
├── firebase.json               # Firebase project configuration
├── pubspec.yaml                # Project dependencies and assets config
├── pubspec.lock                # Locked dependency versions
├── vitalex.iml                 # IDE module file
│
└── README.md                   # Project documentation

## Installation and Setup

### Prerequisites

* Flutter SDK installed
* Android Studio or VS Code
* Firebase account

---

### Step 1: Clone the Repository

```
git clone https://github.com/AfrinShehnas/vitalex
cd vitalex
```

---

### Step 2: Install Dependencies

```
flutter pub get
```

---

### Step 3: Firebase Setup

1. Go to Firebase Console
2. Create a new project
3. Add an Android app
4. Download `google-services.json`
5. Place it in:

```
android/app/
```

---

### Step 4: Configure Firebase

Run:

```
flutterfire configure
```

This will generate:

```
lib/firebase_options.dart
```

---

### Step 5: Enable Authentication

* Go to Firebase Console
* Enable Email/Password authentication

---

### Step 6: Setup Firestore Rules

```
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    match /results/{resultId} {
      allow create: if request.auth != null;
      allow read: if request.auth != null && request.auth.uid == resource.data.userId;
    }

    match /progress/{docId} {
      allow read, write: if request.auth != null && request.auth.uid == request.resource.data.userId;
    }

    match /materials/{docId} {
      allow read: if true;
    }

  }
}
```

---

## Security Notes

* Do not upload `google-services.json` to GitHub
* Keep Firebase rules secure
* Avoid hardcoding secret keys

---

## Future Improvements

* Enhanced dyslexia assessment methods
* More interactive learning games
* Offline support
* Improved accessibility features

---

## Author
Team leader:
Afrin Shehnas H
other members:
Aaron siju
Anjana Krishna R
Ashly Elsa Ajith
---

## License

This project is for educational and internship purposes.
