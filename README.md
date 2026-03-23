# Saint Paul — Church Student Follow-Up App

<p align="center">
  <img src="https://github.com/user-attachments/assets/8e52a05c-2322-4dde-b9d5-1a97c809758c" alt="Saint Paul Logo" width="100"/>
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
- [Routing](#routing)
- [Notes](#notes)

---

## Overview

**Saint Paul** is a dual-role Flutter application designed for church youth groups. Teachers can manage students, assign missions, organize groups, and track attendance via a "Tayo" point system. Students can view their missions, check their progress, earn badges, and see where they rank on the leaderboard — all with real-time updates from Cloud Firestore.

The app is Arabic-first with full RTL support using the Cairo font family.

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
- Forgot password flow (email → OTP → new password)
- Role-based routing (teacher vs. student) after sign-in

---

## Screenshots

### App Entry & Auth

| Splash | Welcome | Login | Register |
|--------|---------|-------|----------|
| ![]() | ![](docs/screens/welcome.png) | ![](docs/screens/login.png) | ![](docs/screens/register.png) |

### Teacher Screens

| Home | Student Detail | Birthdays | Missions |
|------|---------------|-----------|----------|
| ![](docs/screens/teacher_home.png) | ![](docs/screens/tayo_details.png) | ![](docs/screens/birthday.png) | ![](docs/screens/teacher_missions.png) |

| Create Mission | Groups | Create Group | Group Details |
|----------------|--------|--------------|---------------|
| ![](docs/screens/create_edit_mission.png) | ![](![WhatsApp Image 2026-03-23 at 3 32 13 AM](https://github.com/user-attachments/assets/1da4e93d-14dc-45f4-87b9-82bf35e2cc82)
) | ![](docs/screens/create_group.png) | ![](docs/screens/group_details_teacher.png) |

| Students List | Add Student |
|---------------|-------------|
| ![](docs/screens/students_showcase_edit.png) | ![](docs/screens/add_edit_student.png) |

### Student Screens

| Home | Missions | Mission Detail | Group |
|------|----------|----------------|-------|
| ![](docs/screens/student_home.png) | ![](docs/screens/student_missions.png) | ![](docs/screens/mission_details.png) | ![](docs/screens/group_details_student.png) |

| Profile | Badges |
|---------|--------|
| ![](docs/screens/student_profile.png) | ![](docs/screens/badges.png) |

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
│   ├── extensions/            # Dart extensions
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

**Tayo categories tracked per student:**
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

## Routing

All routes are defined in `lib/core/routes/routes.dart` using **GoRouter**. Role-based navigation (teacher vs. student) is handled after authentication via the `mainScreen` route, which receives the user's role as an `extra` parameter.

Key routes:

| Route | Screen |
|-------|--------|
| `/` | Splash |
| `/welcome` | Welcome |
| `/login` | Login |
| `/Register` | Register |
| `/mainScreen` | Main Nav (role-aware) |
| `/teacherMissionScreen` | Teacher Missions |
| `/createMissionScreen` | Create / Edit Mission |
| `/studentMissionScreen` | Student Missions |
| `/missionDetailsScreen` | Mission Details |
| `/groupShowcaseScreen` | Groups List |
| `/groupDetailsScreen` | Group Details |
| `/studentProfileScreen` | Student Profile |
| `/badgesScreen` | Badges |
| `/tayoDetailsScreen` | Tayo / Attendance Detail |

---

## Notes

- **Real-time leaderboard**: The home screen and Tayo-related lists use Firestore streams, so data updates appear without requiring a refresh.
- **Arabic-first**: The app defaults to `ar` locale with RTL layout and the Cairo font family. English is also supported as a fallback locale.
- **Offline caching**: `shared_preferences` is used to cache student data locally for faster loads.
- **Forgot password**: The OTP and new-password routes are currently commented out in the router — these screens exist but the flow is not fully wired up yet.
