# In-Class Activity 13: Firebase Authentication

A Flutter app that uses Firebase Authentication for email/password registration, sign-in, profile access, sign-out, and password updates.

## Features

- Registration and sign-in forms with email and password validation.
- Auth-state routing using `authStateChanges()`.
- Profile screen showing the signed-in email.
- Sign-out and password updates.
- Reauthentication and retry when password updates return `requires-recent-login`.
- Loading feedback, duplicate-submission prevention, and helpful error messages.

Cloud Firestore is not used. Firebase Authentication manages credentials. Auth-state routing gates the profile UI; any future database access also needs server-enforced security rules.

## Requirements

- Flutter with Dart compatible with the `^3.13.2` constraint in `pubspec.yaml`.
- Android SDK and an Android device or emulator for the required APK.
- Internet access and a Firebase project with Email/Password authentication enabled.
- Firebase CLI and FlutterFire CLI when configuring a different Firebase project.

## Firebase configuration

The checked-in configuration references Firebase project `inclass13-79331`. Its owner must enable Email/Password in Firebase Console under Authentication > Sign-in method.

To configure your own project:

1. Create or select a project in [Firebase Console](https://console.firebase.google.com/).
2. Open Authentication and enable the Email/Password provider.
3. Install the [Firebase CLI](https://firebase.google.com/docs/cli), then run from this project root:

```powershell
firebase login
dart pub global activate flutterfire_cli
flutter pub get
flutterfire configure
```

4. Select your project and include Android. The current Android application ID is `com.example.inclass13`.
5. Confirm that `lib/firebase_options.dart` and the Android Firebase configuration reference the intended project.

Firebase initializes before `runApp()` in `main.dart`. The main Android manifest includes internet permission for release builds. No Firestore database is needed for the required authentication features.

Do not commit account passwords, service-account credentials, or private signing keys.

## Run

```powershell
flutter pub get
flutter devices
flutter run -d <device-id>
```

Replace `<device-id>` with an ID from `flutter devices`. Register a test account before attempting to sign in with it. Forms require passwords of at least six characters; Firebase may enforce a stricter project policy.

## Project structure

| File | Purpose |
| --- | --- |
| `lib/main.dart` | Firebase initialization and auth-state screen selection |
| `lib/auth_service.dart` | Authentication operations, error messages, and password recovery |
| `lib/screens/authentication_screen.dart` | Registration/sign-in forms and feedback |
| `lib/screens/profile_screen.dart` | Email display, password updates, and sign-out |
| `lib/firebase_options.dart` | Generated platform-specific Firebase configuration |

## Checks and manual tests

Run static analysis:

```powershell
flutter analyze
```

| Test | Expected result |
| --- | --- |
| Register a new test account | Profile displays the email; the new account appears in Firebase Authentication Users |
| Sign out, then sign in | Logout returns to authentication; valid credentials reopen the profile |
| Submit blank/invalid email or a short password | Validation prevents submission and explains the problem |
| Sign in with an incorrect password | Helpful error feedback appears without raw exception details |
| Observe a request in progress | Loading feedback appears and duplicate submissions are disabled |
| Close and relaunch while signed in | The saved session restores the profile |
| Sign out, then restart or attempt to return to the profile | Protected profile content remains unavailable |
| Change the password | Success feedback appears; after logout, the new password works and the old one fails |
| Trigger a recent-login requirement | The service reauthenticates with the entered current password and retries |
| Attempt authentication without connectivity | Error feedback appears and another attempt is possible |

## Build the Android APK

```powershell
flutter build apk --release
```

Expected output for this project without flavors:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Install that exact APK on an Android device or emulator and repeat the authentication tests before submitting. The current release configuration uses the debug signing key; consult the [Flutter Android release guide](https://docs.flutter.dev/deployment/android) for production signing.

## References

- [Firebase Flutter setup](https://firebase.google.com/docs/flutter/setup)
- [Firebase email/password authentication](https://firebase.google.com/docs/auth/flutter/password-auth)
- [Manage users and reauthenticate](https://firebase.google.com/docs/auth/flutter/manage-users)
- [Flutter form validation](https://docs.flutter.dev/cookbook/forms/validation)
