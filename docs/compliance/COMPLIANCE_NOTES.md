# Compliance Notes — ClinicFlow

## ⚠️ Important Disclaimer

This codebase provides **technical scaffolding and extension points
only**. It does **NOT** constitute legal compliance with:

- HIPAA (Health Insurance Portability and Accountability Act)
- GDPR (General Data Protection Regulation)
- PDPL (Personal Data Protection Law — Saudi Arabia)
- Any other regional health data regulation

## What this codebase provides

| Extension Point | Purpose |
|---|---|
| `PhiRedactor` | Strips identifiers from logs before emission |
| `SecureLogger` | PHI-safe audit stubs |
| `SecureStorageService` | Encrypted token vault |
| `EncryptionService` | AES-256 integration point (stubs) |
| `JailbreakDetector` | Device integrity heuristic hooks |
| `SslPinning` | Certificate pinning stub |

## What organizations must provide

- Legal review and BAA / DPA agreements with all vendors
- Organizational security policies and role-based access controls
- Staff training programs
- Breach notification procedures (72-hour GDPR rule)
- Independent security audits and penetration testing
- Infrastructure hardening (servers, databases, networks)
- Patient consent management workflows
- Immutable, timestamped audit log infrastructure
- Data retention and right-to-erasure policies
- Ongoing risk assessments

## References

- [HHS HIPAA Security Rule](https://www.hhs.gov/hipaa)
- [GDPR Official Text](https://gdpr.eu)
- [Saudi PDPL — SDAIA](https://sdaia.gov.sa)
- [HL7 FHIR Security](https://www.hl7.org/fhir/security.html)
- [OpenEMR Security](https://www.open-emr.org/wiki/index.php/Security)
