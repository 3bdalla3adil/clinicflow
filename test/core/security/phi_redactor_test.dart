import 'package:flutter_test/flutter_test.dart';
import 'package:clinicflow/core/security/phi_redactor.dart';

void main() {
  group('PhiRedactor', () {
    test('redacts email addresses', () {
      const input = 'Contact patient at john.doe@example.com';
      expect(PhiRedactor.redact(input), contains('[REDACTED]'));
      expect(PhiRedactor.redact(input), isNot(contains('@')));
    });

    test('redacts national ID format', () {
      const input = 'National ID: 1234567890';
      final result = PhiRedactor.redact(input);
      expect(result, contains('[REDACTED]'));
    });

    test('redacts dates of birth', () {
      const input = 'DOB: 1990-05-15';
      expect(PhiRedactor.redact(input), contains('[REDACTED]'));
    });

    test('redacts PHI field values in JSON-like strings', () {
      const input = '"email": "patient@test.com"';
      final result = PhiRedactor.redact(input);
      expect(result, contains('[REDACTED]'));
      expect(result, isNot(contains('patient@test.com')));
    });

    test('passes non-PHI strings unchanged', () {
      const input = 'Appointment confirmed for clinic visit.';
      expect(PhiRedactor.redact(input), equals(input));
    });
  });
}
