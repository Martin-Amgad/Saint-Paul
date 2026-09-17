# Saint Paul — Church Student Follow-Up App

<p align="center">
  <img src="https://github.com/user-attachments/assets/8e52a05c-2322-4dde-b9d5-1a97c809758c" alt="Saint Paul Logo" width="300"/>
</p>

> A Flutter mobile app for tracking and engaging church youth students across churches and church families — built for teachers and students, powered by Firebase in real time.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Screenshots](#screenshots)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Data Models](#data-models)
- [Caching Strategy](#caching-strategy)
- [Auth and Role Notes](#auth-and-role-notes)
- [Routing](#routing)
- [Run Locally](#run-locally)
- [Notes](#notes)

---

## Overview

**Saint Paul** is a Flutter application for managing church youth groups. Teachers can manage students, assign missions, organize groups, track attendance through a "Tayo" point system, and follow weekly miss checks. Students can view missions, check their progress, earn badges, and see group and church-family rankings — all with real-time updates from Cloud Firestore.

The app is Arabic-first with full RTL support using the Cairo font family. Data is scoped by church, church family, and study level so the same application can support multiple communities.

> **Note:** Available study levels are configured per church family. Add or update them in the shared school-year configuration as the ministry grows.

---

## Features

### 👨‍🏫 Teacher Side
- View and manage all students (add, edit, delete)
- Filter students by church family, study level, and responsible teacher
- Import students in bulk from an Excel file and download the import template
- Track student attendance and behavior via the **Tayo** point system
- Review Tayo history and manage weekly miss checks
- Create, edit, and assign **missions** to students by study level
- Organize students into **groups**, manage group details, and track group points
- View birthday reminders and student contact info
- See a leaderboard of top students in real time
- Create church-family badge definitions from teacher home (name + Cloudinary image)
- Assign and remove badges per student from the student edit screen
- Edit teacher assignments and manage the church's teaching structure
- Change the church admin PIN from the teacher home screen

### 🎯 Student Side
- Browse available and completed missions
- Submit mission solutions and track enrollment
- View personal profile, Tayo score, and earned **badges**
- See group membership and group leaderboard
- Real-time score and ranking updates
- View badge progress with earned vs. locked badges
- Update profile avatar via camera or gallery
- Receive Firebase Cloud Messaging notifications and local foreground notifications

### 🔐 Auth
- Email/password login and registration via Firebase Auth
- Forgot password support (email reset is available)
- Register a new church and select an existing church family during registration
- Role-based routing (teacher, student, and church admin) after sign-in

### ⚙️ App Control (Remote Flags)
- Force app update via Firestore config flag — blocks the app and opens the APK download link via `url_launcher`
- Put app in maintenance mode via Firestore config flag — blocks the app with a maintenance message
- Both states are checked on every app launch from the splash screen before any routing occurs
- Store church-specific defaults for Tayo categories, group points, badges, and the admin PIN

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

| Under Maintenance | Update App |
|-----------------|-----------------|
| <img src="https://github.com/user-attachments/assets/db5ac92a-3945-430d-af5f-ab413137a3f7" width="180"/> | <img src="https://github.com/user-attachments/assets/d9a97d36-9731-4818-b903-5c96a2f7ce01" width="180"/> |
--

### Student Screens

| Home | Missions | Mission Details | Group Details |
|------|----------|-----------------|---------------|
| <img src="https://github.com/user-attachments/assets/5a9e0705-4d9c-4180-b2cf-13172375c1d2" width="180"/> | <img src="https://github.com/user-attachments/assets/e9a08f53-62bf-4c41-8b42-fa13a9471408" width="180"/> | <img src="https://github.com/user-attachments/assets/4bdc9a32-73cb-44da-b326-8f767567cec8" width="180"/> | <img src="https://github.com/user-attachments/assets/785119ab-8968-4572-ae66-dfa8f0905b9b" width="180"/> |

| Profile | Badges |
|---------|--------|
| <img src="https://github.com/user-attachments/assets/661be14c-9fc0-454b-a783-5c38519c03b1" width="180"/> | <img src="https://github.com/user-attachments/assets/937669a7-8ad5-4727-b85f-e65bae6c8872" width="180"/> |

### Newer Flows

| New Church Registration | Excel Student Import | Miss Check |
|-------------------------|----------------------|------------|
|<img src="https://github.com/user-attachments/assets/e044429b-1048-4434-a2a0-15b8629e07fd" width="180"/> |<img  src="https://github.com/user-attachments/assets/215580ed-5bf3-4d4c-bdc4-c2dfdf478f35" width="180"/> |<img src="https://github.com/user-attachments/assets/635df602-57a7-4dec-ae20-e4156f542940"  width="180"/> |

| Tayo History | Group Points | Group Points History
|--------------|--------------|--------------| 
|<img  src="https://github.com/user-attachments/assets/04af28cb-34e5-43a5-a674-d869c352c9de" width="180"/> |<img src="https://github.com/user-attachments/assets/4f71758f-d3b8-4cfd-b5dc-daaf5beeb5bc" width="180"/> |<img  src="https://github.com/user-attachments/assets/eccdb47f-fa20-4f93-9cba-6be63ff31d34" width="180"/> |


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
| Image Storage | Cloudinary (student avatars + badge images) |
| Notifications | Firebase Cloud Messaging, `flutter_local_notifications`, `timezone` |
| Files and Import | `excel`, `file_picker` |
| Links and HTTP | `url_launcher`, `http` |
| Utilities | `intl`, `gap`, `super_tooltip`, `package_info_plus` |
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

Each feature module owns its presentation layer (screens + Cubit), its data layer (repository), and its models. Shared Firebase access, local storage, notifications, models, routes, and utilities live in `lib/core/`. Firebase Messaging is initialized during app startup and foreground messages are displayed through local notifications.

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
│   │   ├── church_model.dart
│   │   ├── mission_model.dart
│   │   └── group_model.dart
│   ├── routes/
│   │   └── routes.dart        # GoRouter route definitions
│   ├── services/
│   │   ├── firebase/           # Firestore, Auth, and notification services
│   │   └── local/              # SharedPreferences and local notifications
│   └── utils/
│       └── theme.dart         # App theme
│
├── components/                # Reusable UI widgets
│
└── feature/
    ├── auth/                  # Login, register, forgot password
    ├── home/                  # Teacher home, student home, Tayo details
    ├── history/               # Tayo history
    ├── missions/              # Mission list, creation, details
    ├── groups/                # Group management
    ├── Notifications/         # FCM token and notification handling
    ├── profile/               # Student profile, badges, student management
    ├── main/                  # Bottom nav bar (role-aware)
    ├── splash/                # Splash screen
    └── welcome/               # Welcome / onboarding screen
```

---

## Data Models

### StudentModel
Tracks everything about a student: contact info, study level, responsible teacher, group membership, Tayo attendance scores, accepted/submitted missions, and earned badges.

- `myBadges` — `Map<String, String>` mapping badge name to Cloudinary image URL. Replaces the older `missionBadges` list — the map structure allows storing the image URL alongside the badge key, eliminating the need for a separate badge lookup at display time.
- `tayo` — `Map<String, dynamic>` where each key is a category name and each value is `{count: int, takenAt: int?}` (timestamp stored as milliseconds).
- `submittedMissions` — `Map<String, dynamic>` keyed by mission ID.
- `acceptedMissions` — `List<String>` of enrolled mission IDs.

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
Represents a student group with a teacher-managed membership list, church, family, Tayo totals, and group points.

### ChurchModel
Represents a church's shared configuration, including its admin PIN, default Tayo categories, and group-point settings.

### TeacherModel and BadgeModel
Teachers are assigned to a church and family. Badges are scoped to a church family and store their display name and Cloudinary image URL.

---

## Caching Strategy

Student data and config are cached locally using `shared_preferences` to eliminate loading flashes and allow the app to work faster on repeat visits. The pattern used throughout is: **show local data instantly, sync with Firestore silently in the background**.

| Data | Cache Key | When Synced |
|------|-----------|-------------|
| Student profile | `userData` | Every profile screen open via `ProfileCubit.loadStudentData` |
| All badges (config) | `allBadges` | Every `BadgesScreen` open |
| App config flags | checked live | Every app launch from splash |
| User church and family | `user_church`, `user_family` | During authentication and profile initialization |

**Avatar updates** write back to local storage immediately after a successful Cloudinary upload, so the new image persists across app restarts without waiting for the next Firestore sync.

**Badge config** (`allBadges`) is compared against Firestore on the badges screen open using key-count comparison rather than JSON encoding, avoiding false mismatches from key ordering differences.

---

## Auth and Role Notes

- Authentication uses Firebase Auth email/password accounts with role-specific profile data.
- Student and teacher records are scoped to a church; teachers are additionally assigned to a church family.
- Teacher and church registration is protected by an admin PIN validated against Firestore.
- The church admin PIN can be changed at any time from the teacher home screen via a bottom sheet.
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
| `/RegisterNewChurch` | Register a new church |
| `/emailScreen`, `/otpScreen`, `/NewPasswordScreen`, `/confirmScreen` | Password recovery flow |
| `/mainScreen` | Main Nav (role-aware) |
| `/thereIsAnUpdateScreen` | Force Update |
| `/underMaintenanceScreen` | App Maintenance |
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
| `/groupPointsScreen` | Group points |
| `/tayoHistoryScreen` | Tayo history |
| `/editTeachersInfoScreen` | Edit teacher information |
| `/editTeacherStudents` | Teacher's students |
| `/missCheckStudentScreen` | Weekly miss check |
| `/StudentsExcelUploadScreen` | Bulk student import |

---

## Run Locally

Make sure you have a Firebase project with **Authentication** and **Cloud Firestore** enabled, then add your config files:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

Student avatar and badge image uploads use **Cloudinary**. You'll need a Cloudinary account and must configure your upload URL and unsigned upload preset in the app before image uploads will work.

Push notifications use Firebase Cloud Messaging. Configure Firebase Messaging for the target platform and ensure the Android notification resources and iOS notification capabilities are available before testing notifications on a device.

The force update screen opens the APK download link via `url_launcher` with `LaunchMode.externalApplication`. Update the download URL in `AppBlockedScreen` before releasing.

### Firestore Config Requirements

The app reads operational defaults from the church configuration in Firestore. The exact field paths are used by the Firebase provider and may be nested by church family:

- `tayo` — map of default Tayo categories with `{count: 0, takenAt: null}` per entry
- `badges` — flat map of badge name to Cloudinary image URL (`Map<String, String>`)
- `updateAvailable` — bool (force update screen when true)
- `appUnderMaintenance` — bool (maintenance screen when true)
- `adminPin` — string used to protect teacher registration

Example shape:

```json
{
  "tayo": {
    "حضور القداس": { "count": 0, "takenAt": null }
  },
  "badges": {
    "بطل الانتظام": "https://.../consistencyChampion.png",
    "ملك التايو": "https://.../tayoKing.png"
  },
  "updateAvailable": false,
  "appUnderMaintenance": false,
  "adminPin": "your-pin-here",
  "points": {}
}
```

Then install packages and run:

```bash
flutter pub get
flutter run
```

To build a release APK:

```bash
flutter build apk --release --split-per-abi
```

Output will be at `build/app/outputs/flutter-apk/`.

---

## Notes

- **Real-time leaderboard**: The home screen and Tayo-related lists use Firestore streams, so data updates appear without requiring a refresh.
- **Arabic-first**: The app defaults to `ar` locale with RTL layout and the Cairo font family. English is also supported as a fallback locale.
- **Offline caching**: `shared_preferences` caches student data and badge config locally for instant loads. See [Caching Strategy](#caching-strategy) for details.
- **Splash routing**: On every launch the splash screen checks `updateAvailable` and `appUnderMaintenance` from Firestore before routing. Both checks run in parallel with a minimum 2-second splash duration using `Future.wait`, so the update check never causes a premature navigation.
- **Badge system**: Badges are defined globally in `config/defaults.badges` by an admin and stored as a flat `Map<String, String>` (name → URL). Each student's earned badges are stored in `myBadges` on their document using the same structure, so no additional lookup is needed at display time.
- **Church and family scope**: Student, teacher, mission, group, badge, and leaderboard queries use the signed-in user's church and family context where applicable.
- **Bulk student import**: Teachers can use the Excel template and upload screen to create students in batches instead of entering each record manually.
- **Miss checks**: The miss-check screen records `lastMissCheck` on each student; due status is calculated from that timestamp and the church week.
- **Notifications**: FCM tokens are registered for authenticated users. Foreground messages are shown with `flutter_local_notifications`, while Firebase handles system display for background messages.
- **Release metadata**: The current application version is `0.2.0+3`, declared in `pubspec.yaml`.
