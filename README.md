# Saint Paul — Church Student Follow-Up App

<p align="center">
  <img src="https://github.com/user-attachments/assets/8e52a05c-2322-4dde-b9d5-1a97c809758c" alt="Saint Paul Logo" width="300"/>
</p>

> A Flutter mobile app for tracking and engaging church youth students — built for both teachers and students, powered by Firebase in real time.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Screenshots](#screenshots)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Data Models](#data-models)
- [Auth and Role Notes](#auth-and-role-notes)
- [Routing](#routing)
- [Run Locally](#run-locally)
- [Notes](#notes)

---

## Overview

**Saint Paul** is a dual-role Flutter application designed for church youth groups. Teachers can manage students, assign missions, organize groups, and track attendance via a "Tayo" point system. Students can view their missions, check their progress, earn badges, and see where they rank on the leaderboard — all with real-time updates from Cloud Firestore.

The app is Arabic-first with full RTL support using the Cairo font family.

> **Note:** The app currently supports the preparatory year only. Support for additional school years is planned for future releases.

---

## Features

### 👨‍🏫 Teacher Side
- View and manage all students (add, edit, delete)
- Track student attendance and behavior via the **Tayo** point system
- Create, edit, and assign **missions** to students by study level
- Organize students into **groups** and manage group details
- View birthday reminders and student contact info
- See a leaderboard of top students in real time

### 🎯 Student Side
- Browse available and completed missions
- Submit mission solutions and track enrollment
- View personal profile, Tayo score, and earned **badges**
- See group membership and group leaderboard
- Real-time score and ranking updates

### 🔐 Auth
- Email/password login and registration via Firebase Auth
- Forgot password support (email reset is availabe)
- Role-based routing (teacher vs. student) after sign-in

---

## Screenshots

### App Entry & Auth

| Splash | Welcome | Login | Register |
|--------|---------|-------|----------|
| <img src="https://github.com/user-attachments/assets/f6bfc2de-d9c3-4b0b-8df7-630245fb7046" width="180"/> | <img src="https://github.com/user-attachments/assets/7d8c23e2-55a2-49a4-91ec-5e62b12884b4" width="180"/> | <img src="https://github.com/user-attachments/assets/e9775a07-ace5-4d85-b2be-d2d841506bd1" width="180"/> | <img src="https://github.com/user-attachments/assets/e362622d-3302-411d-95fd-545055e3f9ee" width="180"/> |

---

### Teacher Screens

| Home | Tayo Details | Birthdays | Missions |
|------|--------------|-----------|----------|
| <img src="https://github.com/user-attachments/assets/d8fc37e3-2545-4584-8ad2-17b956ede436" width="180"/> | <img src="https://github.com/user-attachments/assets/9e585371-0be4-49fe-ba8c-7a0e4d82170e" width="180"/> | <img src="https://github.com/user-attachments/assets/1661432d-177d-4999-be22-2d270bf6097f" width="180"/> | <img src="https://github.com/user-attachments/assets/bc32ca7e-ceec-4200-88cf-b8bf642b36d7" width="180"/> |

| Create Mission | Groups | Group Details | Create Group |
|----------------|--------|---------------|--------------|
| <img src="https://github.com/user-attachments/assets/4efcb9b4-0874-4d8b-909b-2a625e238124" width="180"/> | <img src="https://github.com/user-attachments/assets/d6ef76d3-1927-4183-8301-0de625daf303" width="180"/> | <img src="https://github.com/user-attachments/assets/5610cc6b-40ec-48aa-92dc-f8997b6ff3d8" width="180"/> | <img src="https://github.com/user-attachments/assets/9200dee5-0975-45e3-b30b-d9d3e30d0ae0" width="180"/> |

| Student Profiles | Add Student | Edit Student |
|-----------------|-------------|--------------|
| <img src="https://github.com/user-attachments/assets/63b8cb70-d05f-46df-95f5-df850719b111" width="180"/> | <img src="https://github.com/user-attachments/assets/4afc546f-657d-4ab2-b059-c489b7932a41" width="180"/> | <img src="https://github.com/user-attachments/assets/e8f9a6fd-7d84-4859-94b7-4eeb6eb2def4" width="180"/> |

---

### Student Screens

| Home | Missions | Mission Details | Group Details |
|------|----------|-----------------|---------------|
| <img src="https://github.com/user-attachments/assets/5a9e0705-4d9c-4180-b2cf-13172375c1d2" width="180"/> | <img src="https://github.com/user-attachments/assets/e9a08f53-62bf-4c41-8b42-fa13a9471408" width="180"/> | <img src="https://github.com/user-attachments/assets/4bdc9a32-73cb-44da-b326-8f767567cec8" width="180"/> | <img src="https://github.com/user-attachments/assets/785119ab-8968-4572-ae66-dfa8f0905b9b" width="180"/> |

| Profile | Badges |
|---------|--------|
| <img src="https://github.com/user-attachments/assets/661be14c-9fc0-454b-a783-5c38519c03b1" width="180"/> | <img src="https://github.com/user-attachments/assets/937669a7-8ad5-4727-b85f-e65bae6c8872" width="180"/> |

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (Dart) |
| State Management | `flutter_bloc` — Cubit pattern |
| Backend / Database | Firebase Cloud Firestore |
| Authentication | Firebase Auth |
| Navigation | `go_router` v17 |
| Local Storage | `shared_preferences` |
| UI | Arabic-first RTL, Cairo font, `flutter_svg`, `lottie`, `google_nav_bar` |
| Images | `cached_network_image`, `image_picker` |
| Image Storage | Cloudinary (student avatar uploads) |
| Links | `url_launcher` |
| Localization | `flutter_localizations` (Arabic + English) |

---

## Architecture

The app follows a clean feature-first architecture with **Cubit** for state management:

```
Flutter UI  ──►  Cubit  ──►  Repository  ──►  Firebase Provider
                                                  │
                                          ┌───────┴────────┐
                                     Firebase Auth    Cloud Firestore
                                                          │
                                                   Realtime Streams
                                                          │
                                                    Flutter UI
```

Each feature module owns its presentation layer (screens + cubit), its data layer (repository), and its models. Shared models and utilities live in `lib/core/`.

---

## Project Structure

```
lib/
├── main.dart                  # App entry point, Firebase + locale init
├── firebase_options.dart      # Auto-generated Firebase config
│
├── core/
│   ├── constants/             # App-wide constants
│   ├── extentions/            # Dart extensions
│   ├── models/                # Shared data models
│   │   ├── student_model.dart
│   │   ├── teacher_model.dart
│   │   ├── mission_model.dart
│   │   └── group_model.dart
│   ├── routes/
│   │   └── routes.dart        # GoRouter route definitions
│   ├── services/
│   │   └── local/             # SharedPreferences helper
│   └── utils/
│       └── theme.dart         # App theme
│
├── components/                # Reusable UI widgets
│
└── feature/
    ├── auth/                  # Login, register, forgot password
    ├── home/                  # Teacher home, student home, Tayo details
    ├── missions/              # Mission list, creation, details
    ├── groups/                # Group management
    ├── profile/               # Student profile, badges, student management
    ├── main/                  # Bottom nav bar (role-aware)
    ├── splash/                # Splash screen
    └── welcome/               # Welcome / onboarding screen
```

---

## Data Models

### StudentModel
Tracks everything about a student: contact info, study level, responsible teacher, group membership, Tayo attendance scores, accepted/submitted missions, and earned badge keys.

**Current Tayo categories tracked per student:**
- Attending Mass
- Attending Mass before the teacher
- Staying quiet during Mass
- Arriving at the meeting on time (11:30–11:40 AM)
- Good behavior during the meeting
- Not using phone during sessions
- Answering a question in the lesson

### MissionModel
Represents a task assigned to students. Includes title, description, optional link, reward points, expiry duration, enrollment count, and study level targeting.

### GroupModel
Represents a student group with a teacher-managed membership list.

---

## Auth and Role Notes

- Roles are encoded using Firebase Auth `photoURL`:
  - `1` → Teacher (`خادم`)
  - `0` → Student (`مخدوم`)
- Teacher registration is protected by an admin PIN validated against Firestore.
- Email reset password is active.

---

## Routing

All routes are defined in `lib/core/routes/routes.dart` using **GoRouter**. Role-based navigation (teacher vs. student) is handled after authentication via the `mainScreen` route, which receives the user's role as an `extra` parameter.

| Route | Screen |
|-------|--------|
| `/` | Splash |
| `/welcome` | Welcome |
| `/login` | Login |
| `/Register` | Register |
| `/mainScreen` | Main Nav (role-aware) |
| `/teacherHomeScreen` | Teacher Home |
| `/studentHomeScreen` | Student Home |
| `/studentShowcaseAndEditScreen` | Students Showcase and Edit |
| `/addNewStudentScreen` | Add / Edit Student |
| `/teacherMissionScreen` | Teacher Missions |
| `/createMissionScreen` | Create / Edit Mission |
| `/studentMissionScreen` | Student Missions |
| `/missionDetailsScreen` | Mission Details |
| `/studentMissionsList` | Student Missions List (teacher preview) |
| `/groupShowcaseScreen` | Groups List |
| `/createGroupScreen` | Create Group |
| `/groupDetailsScreen` | Group Details |
| `/studentProfileScreen` | Student Profile |
| `/badgesScreen` | Badges |
| `/tayoDetailsScreen` | Tayo / Attendance Detail |

---

## Run Locally

Make sure you have a Firebase project with **Authentication** and **Cloud Firestore** enabled, then add your config files:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

Student avatar uploads use **Cloudinary**. You'll need a Cloudinary account and must configure your upload URL and unsigned upload preset in the app before image uploads will work.

Then install packages and run:

```bash
flutter pub get
flutter run
```

To build a release APK:

```bash
flutter build apk --split-per-abi
```

---

## Notes

- **Real-time leaderboard**: The home screen and Tayo-related lists use Firestore streams, so data updates appear without requiring a refresh.
- **Arabic-first**: The app defaults to `ar` locale with RTL layout and the Cairo font family. English is also supported as a fallback locale.
- **Offline caching**: `shared_preferences` is used to cache student data locally for faster loads.
