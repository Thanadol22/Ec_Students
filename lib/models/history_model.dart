import 'package:ec_student/models/user_model.dart';

class HistoryModel {
  final UserModel? user;
  final String? status;
  final String? userId;

  const HistoryModel({
    this.user,
    this.status,
    this.userId,
  });

  HistoryModel.fromJson(Map<String, dynamic>? json)
      : this(
          status: json?["status"],
          userId: json?["userId"],
          user:
              json?["user"] != null ? UserModel.fromJson(json?["user"]) : null,
        );

  Map<String, dynamic>? toJson() {
    return {
      'user': user?.toJson(),
      'status': status,
      'userId': userId,
    };
  }
}
