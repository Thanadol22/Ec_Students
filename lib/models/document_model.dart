import 'package:ec_student/models/history_model.dart';

class ManualsModel {
  final String? documentId;
  final int id;
  final String name;
  final String image;
  final String level;
  final String projectName;
  final String department;
  final HistoryModel? history;

  const ManualsModel({
    required this.id,
    required this.name,
    required this.image,
    required this.level,
    required this.projectName,
    required this.department,
    this.documentId,
    this.history,
  });

  ManualsModel.fromJson(Map<String, dynamic>? json)
      : this(
          id: json?['id'],
          name: json?['name'],
          department: json?['department'],
          image: json?['image'],
          level: json?['level'],
          projectName: json?['projectName'],
          history: HistoryModel.fromJson(json?["history"]),
        );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'level': level,
      'projectName': projectName,
      'department': department,
      'history': history?.toJson(),
    };
  }
}
