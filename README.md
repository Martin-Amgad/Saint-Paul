# Saint Paul

Saint Paul is a Flutter app for teachers and students to manage missions, groups, profiles, and leaderboard progress.

## Quick Overview

- Roles: Teacher and Student
- Backend: Firebase Authentication + Cloud Firestore
- State management: Cubit (flutter_bloc)
- Routing: go_router
- Language support: Arabic (primary) and English

## Features

- Authentication (login, register, reset password)
- Real-time leaderboard by total tayo
- Mission management (create, edit, delete, accept, submit)
- Group management (create groups, assign students, group details)
- Student profile and badges

## Project Structure

lib/
  core/
  feature/
    auth/
    home/
    missions/
    groups/
    profile/
    main/
    splash/
    welcome/
  components/

## Setup

Prerequisites:

- Flutter SDK
- Firebase project with Auth and Firestore enabled
- Platform config files:
  - android/app/google-services.json
  - ios/Runner/GoogleService-Info.plist

Install:

flutter pub get

Optional (regenerate Firebase options):

flutterfire configure

## Common Commands

Run:

flutter run

Analyze:

flutter analyze

Test:

flutter test

Build APK:

flutter build apk

Build split APKs:

flutter build apk --split-per-abi

Build Android App Bundle:

flutter build appbundle

## Simple Architecture Diagram

mermaid
flowchart TD
  UI[Flutter UI] --> Cubit[Cubit]
  Cubit --> Repo[Repositories]
  Repo --> Firebase[FirebaseProvider]
  Firebase --> Auth[Firebase Auth]
  Firebase --> Store[Cloud Firestore]
  Store --> Stream[Realtime Streams]
  Stream --> UI

## Screenshots Placeholders

Add screenshots under docs/screens with these names:

App entry and auth:

![Splash](docs/screens/splash.png)
![Welcome](docs/screens/welcome.png)
![Login](docs/screens/login.png)
![Register](docs/screens/register.png)
![Email](docs/screens/email_forgot_password.png)
![OTP](docs/screens/otp.png)
![New Password](docs/screens/new_password.png)
![Password Changed](docs/screens/password_changed.png)

Teacher:

![Teacher Home](docs/screens/teacher_home.png)
![Tayo Details](docs/screens/tayo_details.png)
![Birthday](docs/screens/birthday.png)
![Teacher Missions](docs/screens/teacher_missions.png)
![Create Edit Mission](docs/screens/create_edit_mission.png)
![Groups Showcase](docs/screens/groups_showcase.png)
![Create Group](docs/screens/create_group.png)
![Group Details Teacher](docs/screens/group_details_teacher.png)
![Students Showcase Edit](docs/screens/students_showcase_edit.png)
![Add Edit Student](docs/screens/add_edit_student.png)

Student:

![Student Home](docs/screens/student_home.png)
![Student Missions](docs/screens/student_missions.png)
![Mission Details](docs/screens/mission_details.png)
![Group Details Student](docs/screens/group_details_student.png)
![Student Profile](docs/screens/student_profile.png)
![Badges](docs/screens/badges.png)

## Notes

- Leaderboards are stream-based, so updates appear in real time.
- Main routes are defined in lib/core/routes/routes.dart.
