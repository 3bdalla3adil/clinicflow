# ClinicFlow — Architecture

## Overview

ClinicFlow follows **Clean Architecture** with strict feature-first
organization. Every business domain owns its own `data/`, `domain/`,
and `presentation/` subtrees. No feature imports another feature's
implementation — only domain contracts.

## Dependency Direction

```
Presentation → Domain (contracts/use cases)
Domain ← Data (implements contracts)
Domain has zero Flutter imports
Data has zero Presentation imports
```

## Feature Modules

| Feature | Domain | Data | Presentation |
|---|---|---|---|
| authentication | ✅ | ✅ | ✅ |
| appointments | ✅ | ✅ | ✅ |
| dashboard | — | — | ✅ |
| doctors | ✅ | ✅ | ✅ |
| medical_records | ✅ | ✅ | ✅ |
| prescriptions | ✅ | ✅ | ✅ |
| billing | ✅ | ✅ | ✅ |
| profile | — | — | ✅ |
| settings | — | — | ✅ |

## State Management

- `flutter_bloc` with explicit Event/State classes
- `Equatable` on all events and states
- 4 canonical states: Loading, Loaded, Empty, Error
- `dartz` Either for all repository return types

## Backend Adapters (Pluggable)

Domain repositories are abstract contracts. Data layer implementations
can target REST, Odoo JSON-RPC, Firebase, or FHIR R4 endpoints without
any changes to Presentation or Domain layers.

### Odoo Integration

To connect to an Odoo healthcare backend:
1. Implement repository contracts using `OdooClient` (JSON-RPC)
2. Map Odoo models to Domain entities via mappers
3. Register the Odoo implementation in `dependency_injection.dart`

### FHIR R4 Integration

FHIR endpoint constants are in `ApiConstants.fhirUrl`. Map FHIR
resources (Patient, Encounter, MedicationRequest, Observation) to
Domain entities in the data layer.
