import 'package:flutter_test/flutter_test.dart';
import 'package:clinicflow/data/models/models.dart';

void main() {
  group('role parsing', () {
    test('accepts uppercase server-managed role IDs', () {
      expect(UserRoleX.fromValue('ADMIN'), UserRole.admin);
      expect(UserRoleX.fromValue('RECEPTION'), UserRole.reception);
      expect(UserRoleX.fromValue('ACCOUNTANT'), UserRole.accountant);
    });

    test('defaults unknown roles to patient', () {
      expect(UserRoleX.fromValue('unexpected-role'), UserRole.patient);
    });
  });

  test('status labels are readable', () {
    expect(statusLabel(AppointmentStatus.inConsultation), 'In consultation');
  });
}
