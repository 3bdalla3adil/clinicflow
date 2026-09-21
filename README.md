# ClinicFlow

ClinicFlow is a Flutter/Firebase clinic-management foundation for Android and iOS. It is intentionally marked as an **MVP/development application** until security, privacy, legal, clinical, and operational controls are independently assessed. It must not be described as HIPAA compliant without a completed assessment.

## Included

The scaffold includes Material 3 theming, Riverpod state management, go_router navigation, patient login/demo mode, doctor/service discovery, appointment booking, appointment listing, profile UI, repository abstractions, Firestore security rules, indexes, and a testable demo repository. The demo repository lets the UI run without credentials; replace it with `FirebaseClinicRepository` after configuring Firebase.

## Firebase setup

Install Flutter and configure the existing Firebase project `clinic-app-v4` with FlutterFire CLI. Generate `lib/firebase_options.dart` locally and keep it out of source control when appropriate. Enable Email/Password Authentication, Firestore, FCM, Crashlytics, and Storage as required. Deploy rules and indexes with `firebase deploy --only firestore`.

Critical booking validation must be moved to a callable Cloud Function using a Firestore transaction before production use. Never calculate availability from a complete client-side appointment dump, and never place service-account credentials in the app.

## Run

```bash
flutter pub get
flutter run
flutter test
```

## Production gaps to complete

Implement Firebase-backed repositories, custom claims or server-controlled role documents, callable appointment creation, consultation and payment screens, notification handlers, Arabic ARB generation/RTL verification, pagination, audit-log Cloud Functions, staging/production Firebase options, Android/iOS signing, and a formal healthcare privacy/security review.
