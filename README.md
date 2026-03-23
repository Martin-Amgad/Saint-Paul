# Saint Paul

Saint Paul is a Flutter app for church student follow-up, with dedicated experiences for teachers and students.

## What This App Does

- Teacher side: manage students, missions, groups, and rankings 🧑‍🏫
- Student side: follow missions, check profile, and track leaderboard progress 🎯
- Live updates from Firestore for leaderboard and related lists ⚡

## Quick Tech Snapshot

- Flutter + Dart
- Cubit (`flutter_bloc`)
- Firebase Authentication + Cloud Firestore
- `go_router` for navigation
- Arabic-first UI with localization support

## Project Structure

```text
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
```

## Setup (Project Only)

Make sure Firebase is connected for this project, and these files exist:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

Then run:

```bash
flutter pub get
```

Optional (if needed):

```bash
flutterfire configure
```

## Common Commands

```bash
flutter run
flutter analyze
flutter test
flutter build apk
flutter build apk --split-per-abi
flutter build appbundle
```

## Architecture (Simple)

```mermaid
flowchart TD
  UI[Flutter UI] --> Cubit[Cubit]
  Cubit --> Repo[Repositories]
  Repo --> Firebase[FirebaseProvider]
  Firebase --> Auth[Firebase Auth]
  Firebase --> Store[Cloud Firestore]
  Store --> Stream[Realtime Streams]
  Stream --> UI
```

## Screenshots Placeholders

Put screenshots in `docs/screens` using these names.

### App Entry and Auth

![Splash](docs/screens/splash.png)
![Welcome](docs/screens/welcome.png)
![Login](docs/screens/login.png)
![Register](docs/screens/register.png)
![Email](docs/screens/email_forgot_password.png)
![OTP](docs/screens/otp.png)
![New Password](docs/screens/new_password.png)
![Password Changed](docs/screens/password_changed.png)

### Teacher Screens

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

### Student Screens

![Student Home](docs/screens/student_home.png)
![Student Missions](docs/screens/student_missions.png)
![Mission Details](docs/screens/mission_details.png)
![Group Details Student](docs/screens/group_details_student.png)
![Student Profile](docs/screens/student_profile.png)
![Badges](docs/screens/badges.png)

## Notes

- Leaderboard-related screens use Firestore streams, so updates appear in near real-time.
- Main route map lives in `lib/core/routes/routes.dart`.
