import 'package:equatable/equatable.dart';

enum UserRole { patient, doctor, admin, staff }

class User extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? phone;
  final String? avatarUrl;
  final bool isVerified;
  final bool isBiometricEnabled;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.phone,
    this.avatarUrl,
    this.isVerified = false,
    this.isBiometricEnabled = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, role];
}
