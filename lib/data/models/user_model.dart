import '../../core/constants/roles.dart';

class UserModel {
  final String id;
  final String fullName;
  final String phone;
  final String email;
  final String departmentId;
  final UserRole role;

  UserModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.departmentId,
    required this.role,
  });
}
