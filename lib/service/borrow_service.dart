import 'package:ec_student/enum/manual_status.dart';
import 'package:ec_student/enum/user_status.dart';
import 'package:ec_student/models/database.dart';
import 'package:ec_student/models/document_model.dart';
import 'package:ec_student/models/history_model.dart';
import 'package:ec_student/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BorrowService {
  final _db = Database();

  Future<bool> updateBorrowData({required ManualsModel document}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId")!;
    final documentId = document.documentId!;

    if (documentId.isEmpty && userId.isEmpty) {
      return false;
    }

    final userCollection = _db.getUserCollection();
    final manualCollection = _db.getManualCollection();
    final userDoc = await userCollection.doc(userId).get();
    if (userDoc.data() == null) {
      return false;
    }

    final wasBorrowed =
        document.history?.status == ManualStatus.WAS_BORROWED.name;
    final isAvialable = document.history?.status == ManualStatus.AVAILABLE.name;

    if (!wasBorrowed && !isAvialable) {
      return false;
    }

    final UserModel userModel = userDoc.data()!;

    final ManualsModel manualModel = ManualsModel(
      department: document.department,
      id: document.id,
      image: document.image,
      level: document.level,
      name: document.name,
      projectName: document.projectName,
      history: HistoryModel(
        status: wasBorrowed
            ? ManualStatus.REMOVE_REQUESTED.name
            : ManualStatus.BORROW_REQUESTED.name,
        user: wasBorrowed ? document.history?.user : userModel,
        userId: wasBorrowed ? document.history?.userId : userId,
      ),
    );
    try {
      await manualCollection.doc(documentId).set(manualModel);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<ManualsModel?> findById(String documentId) async {
    try {
      final manualStream = _db.getManualCollection();
      final manualFind = await manualStream.doc(documentId).get();
      if (!manualFind.exists) {
        return null;
      }

      return manualFind.data();
    } catch (e) {
      return null;
    }
  }

  Future<bool> approveBorrowRequest({
    required ManualsModel document,
    required ManualStatus requestStatus,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId")!;
    final role = prefs.getString("role")!;
    final documentId = document.documentId!;

    if ((documentId.isEmpty && userId.isEmpty) ||
        role != UserStatus.ADMIN.name) {
      return false;
    }

    final manualCollection = _db.getManualCollection();

    final isRequestedRemove =
        requestStatus.name == ManualStatus.REMOVE_REQUESTED.name;

    final ManualsModel manualModel = ManualsModel(
      department: document.department,
      id: document.id,
      image: document.image,
      level: document.level,
      name: document.name,
      projectName: document.projectName,
      history: HistoryModel(
        status: isRequestedRemove
            ? ManualStatus.AVAILABLE.name
            : ManualStatus.WAS_BORROWED.name,
        user: isRequestedRemove ? null : document.history?.user,
        userId: isRequestedRemove ? null : document.history?.userId,
      ),
    );
    try {
      await manualCollection.doc(documentId).set(manualModel);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> cancelRequested({
    required ManualsModel document,
    required ManualStatus requestStatus,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId")!;
    final role = prefs.getString("role")!;
    final documentId = document.documentId!;

    if ((documentId.isEmpty && userId.isEmpty) ||
        role != UserStatus.ADMIN.name) {
      return false;
    }

    final manualCollection = _db.getManualCollection();

    final isRequestRemove =
        requestStatus.name == ManualStatus.REMOVE_REQUESTED.name;

    final ManualsModel manualModel = ManualsModel(
      department: document.department,
      id: document.id,
      image: document.image,
      level: document.level,
      name: document.name,
      projectName: document.projectName,
      history: HistoryModel(
        status: isRequestRemove
            ? ManualStatus.WAS_BORROWED.name
            : ManualStatus.AVAILABLE.name,
        user: isRequestRemove ? document.history?.user : null,
        userId: isRequestRemove ? document.history?.userId : null,
      ),
    );
    try {
      await manualCollection.doc(documentId).set(manualModel);
      return true;
    } catch (e) {
      return false;
    }
  }
}
