# ClinicFlow

ClinicFlow is a Flutter + Firebase clinic-management MVP for Android and iOS. It uses a single application with clinic-scoped role-based workspaces. It is a development foundation, not a claim of HIPAA compliance or clinical certification.

## Current capabilities

- Firebase email/password sign-in and isolated local demo mode.
- Patient appointment booking and appointment history.
- Anonymous guest entry with clinic selection; guests can book first and add their name/contact details later from My Profile.
- Role-aware dashboard and staff appointment workspace.
- Reception check-in, doctor consultation workflow and clinical notes, and payment recording.
- Server-side role and clinic validation for booking, appointment status changes, consultations, payments, and audit events.
- Transaction-based appointment-slot reservation to prevent concurrent double booking.
- Firestore rules that block direct client writes to appointment workflow records and keep role/clinic assignment server-controlled.
- Riverpod state management, repository abstractions, Material 3 UI, and English/Arabic localization resources.

Roles supported by the data model: `ADMIN`, `RECEPTION`, `DOCTOR`, `ACCOUNTANT`, and `PATIENT`. Each authenticated user must have a server-provisioned `users/{uid}` document containing `clinicId` and `roleId` (or `role`). Clinic staff and service data live under `clinics/{clinicId}/doctors` and `clinics/{clinicId}/services`.

## Configure Firebase

1. Install Flutter, Node.js 20, and the Firebase CLI.
2. Configure the existing Firebase project `clinic-app-v4` with FlutterFire CLI. Generate `lib/firebase_options.dart` locally if the project setup uses generated FlutterFire options; do not commit private service-account credentials.
3. Enable Email/Password Authentication and Firestore.
4. Enable **Anonymous** as well as Email/Password Authentication. Provision staff and registered users' `users/{uid}` profiles using a trusted administrative process. Guest patient profiles are created by the callable function. Do not let clients choose their own role or clinic.
5. Seed each clinic with doctor and service documents.
6. Deploy Firestore rules, indexes, and callable functions from the repository root:

   ```bash
   firebase use clinic-app-v4
   cd functions && npm install --no-audit --no-fund && npm run build && cd ..
   firebase deploy --only firestore,functions
   ```

The guest flow lists available clinics, creates a Firebase anonymous session, and provisions a minimum patient profile on the server. Guests can book before completing their contact details. From My Profile, they can link an email/password credential to preserve the same Firebase UID and patient history. Password reset is available from the sign-in screen. Enable Anonymous Authentication in Firebase Console. The callable booking function validates clinic scope and profile ownership and reserves a slot in a Firestore transaction. Clients should not be granted direct write access to appointments, slot locks, consultations, payments, or audit logs.

## Run and test

```bash
flutter pub get
flutter run
flutter analyze
flutter test
cd functions && npm install --no-audit --no-fund && npm run build
```

Use **Try Demo** to explore the UI without Firebase credentials. Demo records are local/in-memory and are not real clinic data.

## Build artifacts without spending Actions minutes on every push

The `.github/workflows/clinicflow.yml` workflow runs analysis, tests, and a Cloud Functions TypeScript build for pushes and pull requests. Android APK and unsigned iOS IPA builds are intentionally manual: open **Actions → Build ClinicFlow → Run workflow** and select a platform. Artifacts are retained for three days. The unsigned iOS IPA is for testing workflows such as sideloading; it is not App Store-ready and may require device-specific signing to install.

## Production-readiness checklist

Before handling real patient information, complete the remaining MediBook parity modules and every release gate in [the migration plan](docs/medibook-feature-parity.md): secure staff invitation/provisioning, patient and clinic administration, doctor schedules, triage/queue, medical records, prescriptions, telehealth, notifications, payment history/reconciliation/refunds, full Arabic/RTL, pagination, monitoring, backups, and independent security/clinical/legal review. Existing appointment, consultation-note, and payment-recording workflows are only a starting subset—not full billing or clinical-record management. Do not use the public demo identities or demo data for real patient records.
