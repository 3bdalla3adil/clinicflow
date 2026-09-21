# ClinicFlow demo accounts

These are public demo identities for development/UI testing only. They must never be used for real patient data.

| Role | Email | Password |
|---|---|---|
| Admin | admin@demo.clinicflow.app | ClinicFlow@Admin2026 |
| Reception | reception@demo.clinicflow.app | ClinicFlow@Reception2026 |
| Doctor | doctor@demo.clinicflow.app | ClinicFlow@Doctor2026 |
| Accountant | accountant@demo.clinicflow.app | ClinicFlow@Accountant2026 |
| Patient | patient@demo.clinicflow.app | ClinicFlow@Patient2026 |

When Firebase is configured, create these identities in Firebase Authentication and create matching /users/{uid} documents with role and clinicId. The repository intentionally falls back to these demo accounts only when Firebase is not initialized.
