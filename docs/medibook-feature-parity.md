# MediBook → ClinicFlow Feature Parity Plan

## Objective

Bring the functional MediBook patient, doctor, and administrator workflows into ClinicFlow while keeping ClinicFlow's Firebase-first, clinic-scoped security model. This is a staged migration, not a blind copy of the MediBook repository: the two apps use different state management, routing, domain models, Firebase schemas, and backend contracts.

## Non-negotiable migration rules

- Keep ClinicFlow's existing Firebase project configuration and clinic-scoped collections. Do not silently switch Firebase projects or overwrite production data.
- Preserve the current role set: `ADMIN`, `RECEPTION`, `DOCTOR`, `ACCOUNTANT`, and `PATIENT`. Users cannot self-assign privileged roles or clinic membership.
- Every clinical and financial operation must be authorized server-side and scoped to the caller's clinic.
- Keep demo mode isolated from Firebase and production records.
- Never copy credentials, service-account files, real patient data, or signing material from MediBook.
- Do not expose clinical notes or patient records to reception/accounting users unless the explicit permission model grants access.
- Preserve audit history for privileged, clinical, and financial mutations.
- Do not mark a module complete because a route or placeholder screen exists. A module is complete only when domain, repository, Firebase/server implementation, UI states, localization, security rules, and tests are present.
- Keep deployment separate from code changes. No production Firebase deployment is part of this migration.

## Feature inventory and target order

| Area | MediBook capability to carry over | ClinicFlow target | Acceptance gate |
|---|---|---|---|
| Identity and access | Email/password, Google sign-in where configured, password reset, session restoration, role dashboards | Firebase Auth + trusted user profiles; secure staff invitations and guest linking | Auth emulator/integration tests; role escalation denied |
| Clinics and organizations | Clinic directory, organizations, clinic assignments | Public clinic discovery plus private clinic administration | Cross-clinic reads/writes denied |
| Patients | Registration, profile, patient directory, medical history | Patient profile and staff directory with least-privilege access | Patient ownership and staff scope tests |
| Doctors | Doctor profiles, specialties, clinic assignments, availability, leave/schedule | Doctor administration and schedule management | Assigned-doctor authorization and schedule validation |
| Services | Medical service catalog and pricing | Admin-managed clinic services | Clinic-scoped CRUD tests |
| Appointments | Booking, slots, rescheduling/cancellation, check-in, no-show, offline queue | Atomic slot booking plus full lifecycle | Concurrent booking and transition tests |
| Consultations | Encounter notes, diagnosis, telehealth session | Doctor-only consultation workspace | Assigned doctor only; append-only/versioned clinical history |
| Medical records | Longitudinal records, history and attachments | Patient record timeline | Patient/doctor access tests; no unauthorized edits |
| Prescriptions | Prescription creation and patient viewing | Doctor-authorized prescriptions | Prescriber authorization, immutable audit trail |
| Triage | Vitals and triage status | Reception/clinical triage flow | Required-field and role tests |
| Telehealth | Lobby, room, session lifecycle, Daily integration | Secure telehealth workflow | Token/session authorization; provider secrets server-side |
| Billing | Charges, receipts, payment history | Billing ledger and patient receipts | Idempotency, reconciliation, refunds, accountant permissions |
| Pharmacy and laboratory | Orders/work queues | Optional clinic operational modules | Explicit permissions and audited status changes |
| Queue | Waiting room and queue status | Reception/doctor queue | Clinic-scoped ordering and status tests |
| Notifications | In-app notifications and FCM | Notification center and push delivery | Token lifecycle, per-user isolation, retry tests |
| Reports and audit | Operational reports, audit history | Admin reports and searchable audit trail | Aggregation access control; audit records server-only |
| Settings | Locale, theme, clinic settings | Arabic/English, RTL, timezone and clinic settings | Persisted settings and RTL widget tests |
| Offline and resilience | Local cache, outbox, retries, conflict handling | Safe offline reads and queued non-sensitive operations | Conflict/retry tests; no unsafe offline clinical writes |
| Security and operations | PHI redaction, secure storage, monitoring, backups | Hardened production operations | Security review, restore drill, monitoring alerts |

## Implementation phases

### Phase A — Stabilize the existing ClinicFlow foundation
- Fix guest-account linking retry behavior and account recovery edge cases.
- Verify callable-function authorization and Firestore rules with emulator tests.
- Add deterministic tests for appointment concurrency and state transitions.
- Verify Flutter analyze, widget/unit tests, Functions build, and emulator rules in CI.
- Resolve the current CI failures before adding more modules.

### Phase B — Identity, administration, and clinic setup
- Trusted staff provisioning for doctors, receptionists, and accountants.
- Invitation/reset email delivery using a configured trusted mail provider.
- Admin CRUD for clinics, doctors, assignments, schedules, and services.
- Patient registration and profile linking.
- Pagination for all staff-facing lists.

### Phase C — Clinical workflows
- Patient directory with role-aware fields.
- Doctor schedule and availability/leave.
- Triage and waiting queue.
- Consultation history, medical records, and prescriptions.
- Doctor assignment checks enforced by callable functions and rules.

### Phase D — Telehealth and communications
- Secure server-issued telehealth room credentials.
- In-app notifications and FCM delivery.
- Notification preferences and device-token lifecycle.
- Arabic/English localization completion and RTL verification.

### Phase E — Finance and operational modules
- Billing ledger, payment history, receipts, reconciliation, and refunds.
- Pharmacy and laboratory workflows where enabled by the clinic.
- Reports, exports, and audit search.
- Idempotency and immutable financial/clinical event history.

### Phase F — Production hardening and release
- Offline cache/outbox only for explicitly safe operations.
- Monitoring, crash reporting, backup schedules, and restore drills.
- Security/privacy threat model and clinical/legal review.
- Android and iOS build/install smoke tests.
- End-to-end test matrix for all five roles.
- Release checklist and documented Firebase setup.

## Definition of done

ClinicFlow is not production-ready until all enabled features pass:
1. `flutter analyze` with no errors.
2. `flutter test` and relevant widget/BLoC-equivalent tests.
3. Cloud Functions TypeScript build and callable authorization tests.
4. Firestore Emulator rules tests, including cross-clinic and role-escalation denial.
5. Concurrent booking, duplicate payment, and status-transition tests.
6. Android build/install smoke test and iOS build/install smoke test.
7. Arabic and English UI verification, including RTL layouts.
8. A manual end-to-end test for patient, doctor, reception, accountant, and admin.
9. Production configuration validation, backup/restore verification, and independent security/privacy review.

A green CI run is necessary but not sufficient. No software can honestly be guaranteed "bug-free"; the release gate is evidence-based verification and a documented known-issues list.
