# ClinicFlow

Production-grade Medical Appointment & Telehealth Flutter Application.

## Architecture

Clean Architecture — feature-first, strict dependency direction.
See `docs/architecture/architecture.md`.

## Setup

```bash
# 1. Clone the repository
git clone <repo-url>

# 2. Install dependencies
flutter pub get

# 3. Copy environment file
cp .env .env.local
# Edit .env.local with your backend URLs

# 4. Run code generation (Hive adapters)
dart run build_runner build --delete-conflicting-outputs

# 5. Run the app
flutter run
```

## Project Structure

```
lib/
├── main.dart              # Entry point
├── bootstrap.dart         # Initialization chain
├── app/                   # App-level: router, theme, l10n
├── core/                  # Cross-cutting: network, security, storage
└── features/              # Business features (Clean Architecture)
    ├── authentication/
    ├── dashboard/
    ├── appointments/
    ├── doctors/
    ├── medical_records/
    ├── prescriptions/
    ├── billing/
    ├── profile/
    └── settings/
```

## Security

PHI-safe logging, encrypted secure storage, SSL pinning hooks,
biometric auth, jailbreak detection. See `docs/compliance/`.

> ⚠️ This codebase does NOT claim HIPAA/GDPR/PDPL compliance.
> Legal, operational, and infrastructure compliance requires additional
> organizational controls. See `docs/compliance/COMPLIANCE_NOTES.md`.

## Backend Integration

Supports REST, Odoo JSON-RPC, and FHIR R4 via pluggable repository
implementations. See `docs/architecture/architecture.md`.

## Tests

```bash
flutter test
flutter test --coverage
```

## CI/CD

GitHub Actions workflows in `.github/workflows/`:
- `ci.yml` — analyze, format, test on push/PR
- `android.yml` — AAB release build on version tag
- `ios.yml` — iOS release build on version tag
