import 'package:ec_student/models/account_model.dart';

class UserModel extends AccountModel {
  final String name;
  final String level;
  final String status;
  final String department;
  final String? userId;

  const UserModel({
    required this.name,
    required this.level,
    required this.status,
    required this.department,
    required super.email,
    required super.password,
    this.userId,
  });

  UserModel.fromJson(Map<String, dynamic>? json)
      : this(
          email: json?['email']! as String,
          department: json?['department']! as String,
          name: json?['name']! as String,
          level: json?['level']! as String,
          password: json?['password']! as String,
          status: json?['status']! as String,
        );

  @override
  Map<String, Object?> toJson() {
    return {
      'email': email,
      'name': name,
      'level': level,
      'status': status,
      'password': password,
      'department': department,
    };
  }
}
