import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ec_student/models/document_model.dart';
import 'package:ec_student/models/user_model.dart';

class Database {
  final db = FirebaseFirestore.instance;

  CollectionReference<UserModel> getUserCollection() {
    final modelRef = db.collection("users").withConverter<UserModel>(
          fromFirestore: (snapshot, _) => UserModel.fromJson(snapshot.data()!),
          toFirestore: (model, _) => model.toJson(),
        );

    return modelRef;
  }

  CollectionReference<ManualsModel> getManualCollection() {
    final modelRef = db.collection("manuals").withConverter<ManualsModel>(
          fromFirestore: (snapshot, _) =>
              ManualsModel.fromJson(snapshot.data()!),
          toFirestore: (model, _) => model.toJson(),
        );

    return modelRef;
  }
}
