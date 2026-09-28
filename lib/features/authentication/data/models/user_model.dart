import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.role,
    super.phone,
    super.avatarUrl,
    super.isVerified,
    super.isBiometricEnabled,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        email: json['email'] as String,
        fullName: json['full_name'] as String,
        role: _parseRole(json['role'] as String?),
        phone: json['phone'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        isVerified: json['is_verified'] as bool? ?? false,
        createdAt: DateTime.parse(
          json['created_at'] as String? ??
              DateTime.now().toIso8601String(),
        ),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        'role': role.name,
        'phone': phone,
        'avatar_url': avatarUrl,
        'is_verified': isVerified,
        'created_at': createdAt.toIso8601String(),
      };

  static UserRole _parseRole(String? role) {
    switch (role) {
      case 'doctor':
        return UserRole.doctor;
      case 'admin':
        return UserRole.admin;
      case 'staff':
        return UserRole.staff;
      default:
        return UserRole.patient;
    }
  }
}
