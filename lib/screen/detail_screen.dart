import 'package:ec_student/enum/manual_status.dart';
import 'package:ec_student/enum/user_status.dart';
import 'package:ec_student/layouts/main_layout.dart';
import 'package:ec_student/models/database.dart';
import 'package:ec_student/models/document_model.dart';
import 'package:ec_student/presentation/common/confirm_dialog.dart';
import 'package:ec_student/presentation/common/status_chip.dart';
import 'package:ec_student/presentation/common/user_storage_builder.dart';
import 'package:ec_student/presentation/features/detail/detail_content.dart';
import 'package:ec_student/screen/generate_qr_screen.dart';
import 'package:ec_student/service/borrow_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    super.key,
    required this.document,
  });

  final ManualsModel document;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final borrowService = BorrowService();
  final db = Database();

  Future<void> _createBorrowed({
    required BuildContext context,
    required ManualsModel document,
  }) async {
    EasyLoading.show(status: "กำลังโหลด");
    final bool isSuccess =
        await borrowService.updateBorrowData(document: document);
    if (!isSuccess) {
      EasyLoading.showError("ทำรายการไม่สำเร็จ");
      return;
    }

    EasyLoading.showSuccess("ทำรายการสำเร็จ");
    setState(() {});
  }

  Future<void> _approveBorrowed({
    required BuildContext context,
    required ManualsModel document,
  }) async {
    final history = document.history;

    final isRequestedRemove =
        history?.status == ManualStatus.REMOVE_REQUESTED.name;

    EasyLoading.show(status: "กำลังโหลด...");
    final isSuccess = await borrowService.approveBorrowRequest(
      document: document,
      requestStatus: isRequestedRemove
          ? ManualStatus.REMOVE_REQUESTED
          : ManualStatus.BORROW_REQUESTED,
    );
    if (!isSuccess) {
      EasyLoading.showError("ไม่สามารถดำเนินการได้");
      return;
    }

    EasyLoading.showSuccess("ดำเนินการสำเร็จ");
    setState(() {});
  }

  Future<void> _cancelRequested({
    required BuildContext context,
    required ManualsModel document,
  }) async {
    final history = document.history;

    final isRequestedRemove =
        history?.status == ManualStatus.REMOVE_REQUESTED.name;

    EasyLoading.show(status: "กำลังโหลด...");
    final isSuccess = await borrowService.cancelRequested(
      document: document,
      requestStatus: isRequestedRemove
          ? ManualStatus.REMOVE_REQUESTED
          : ManualStatus.BORROW_REQUESTED,
    );
    if (!isSuccess) {
      EasyLoading.showError("ไม่สามารถดำเนินการได้");
      return;
    }

    EasyLoading.showSuccess("ดำเนินการสำเร็จ");
    setState(() {});
  }

  Future<ManualsModel> _getManual() async {
    final manualCollection = db.getManualCollection();
    final manualDoc =
        await manualCollection.doc(widget.document.documentId).get();
    final manualData = manualDoc.data()!;

    return ManualsModel(
      id: manualData.id,
      name: manualData.name,
      image: manualData.image,
      level: manualData.level,
      projectName: manualData.projectName,
      department: manualData.department,
      documentId: manualDoc.id,
      history: manualData.history,
    );
  }

  Widget _buildBorrowedButton({
    required BuildContext context,
    bool canBorrow = false,
    required ManualsModel document,
  }) {
    final hasBorrowed =
        document.history?.status == ManualStatus.WAS_BORROWED.name;
    final String borrowedLabel = hasBorrowed ? "ขอคืน" : "ขอยืม";
    return ElevatedButton(
      onPressed: canBorrow
          ? () => showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: Text('ยืนยันการ$borrowedLabel'),
                  content: DetailContent(
                    document: document,
                    hasBorrowed: hasBorrowed,
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('ยกเลิก'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _createBorrowed(
                          context: context,
                          document: document,
                        );
                      },
                      child: const Text('ตกลง'),
                    ),
                  ],
                ),
              )
          : null,
      child: Text(borrowedLabel),
    );
  }

  Widget _buildGenerateQRButton({
    required BuildContext context,
    required ManualsModel document,
  }) {
    return Expanded(
      flex: 0,
      child: IconButton(
        color: Colors.blue.shade900,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GenerateQRScreen(
                document: document,
              ),
            ),
          );
        },
        icon: const Icon(Icons.qr_code),
      ),
    );
  }

  Widget _buildUserSection({
    required BuildContext context,
    required bool hasBorrowed,
    required ManualsModel document,
  }) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: double.infinity,
      ),
      padding: const EdgeInsets.all(8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              StatusChip(
                status: document.history?.status ?? '',
                name: document.history?.user?.name,
              ),
              Text(
                document.projectName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(
                height: 24,
              ),
              Text(
                "ผู้จัดทำ: ${widget.document.name}",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                "แผนกวิชา: ${widget.document.department}",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                "ระดับชั้น: ${widget.document.level}",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminSection({
    required BuildContext context,
    required ManualsModel document,
  }) {
    if (document.history?.user == null) {
      return Container();
    }

    final history = document.history;

    final isRequestedBorrowed =
        history?.status == ManualStatus.BORROW_REQUESTED.name;
    final isRequestedRemove =
        history?.status == ManualStatus.REMOVE_REQUESTED.name;

    if (!isRequestedBorrowed && !isRequestedRemove) {
      return Container();
    }
    return Container(
      constraints: const BoxConstraints(
        minWidth: double.infinity,
      ),
      padding: const EdgeInsets.all(8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      isRequestedBorrowed ? "คำขอยืม" : "คำขอคืน",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  Expanded(
                    flex: 0,
                    child: IconButton(
                      color: Colors.green.shade900,
                      onPressed: () => showDialog(
                        context: context,
                        builder: (BuildContext context) => ConfirmDialog(
                          content: const Text("ต้องการดำเนินการต่อหรือไม่?"),
                          title:
                              "อนุมัติ${isRequestedBorrowed ? "คำขอยืม" : "คำขอคืน"}",
                          onPressed: () {
                            Navigator.of(context).pop();
                            _approveBorrowed(
                              context: context,
                              document: document,
                            );
                          },
                        ),
                      ),
                      icon: const Icon(Icons.check_circle),
                    ),
                  ),
                  Expanded(
                    flex: 0,
                    child: IconButton(
                      color: Colors.red.shade800,
                      onPressed: () => showDialog(
                        context: context,
                        builder: (BuildContext context) => ConfirmDialog(
                          content: const Text("ต้องการดำเนินการต่อหรือไม่?"),
                          title:
                              "ยกเลิก${isRequestedBorrowed ? "คำขอยืม" : "คำขอคืน"}",
                          onPressed: () {
                            Navigator.of(context).pop();
                            _cancelRequested(
                              context: context,
                              document: document,
                            );
                          },
                        ),
                      ),
                      icon: const Icon(Icons.remove_circle),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 24,
              ),
              Text(
                "ผู้ยืม: ${history?.user?.name ?? "-"}",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                "แผนกวิชา: ${history?.user?.department ?? "-"}",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                "ระดับชั้น: ${history?.user?.level ?? "-"}",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: widget.document.projectName,
      canDrawing: false,
      bottomNavigationBar: FutureBuilder(
          future: _getManual(),
          builder: (context, manualSnapshot) {
            final document = manualSnapshot.data;
            if (manualSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if ((manualSnapshot.connectionState != ConnectionState.active &&
                    manualSnapshot.connectionState != ConnectionState.done) ||
                document == null) {
              return const Center(child: Text("ไม่พบข้อมูล"));
            }
            final hasBorrowed =
                document.history?.status == ManualStatus.WAS_BORROWED.name;
            final isAvailable =
                document.history?.status == ManualStatus.AVAILABLE.name;

            return DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade600,
                    spreadRadius: 0.002,
                    blurRadius: 4,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: UserStorageBuilder(
                builder: (context, snapshot) {
                  final role = snapshot.data?.getString("role");
                  var userId = snapshot.data?.getString("userId");
                  final canBorrow = hasBorrowed
                      ? userId == document.history?.userId ||
                          role == UserStatus.ADMIN.name
                      : isAvailable;
                  final isAdmin = role == UserStatus.ADMIN.name;
                  return Container(
                    padding: const EdgeInsets.all(8),
                    child: isAdmin
                        ? Row(
                            children: [
                              _buildGenerateQRButton(
                                context: context,
                                document: document,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 1,
                                child: _buildBorrowedButton(
                                  context: context,
                                  canBorrow: canBorrow,
                                  document: document,
                                ),
                              ),
                            ],
                          )
                        : _buildBorrowedButton(
                            context: context,
                            canBorrow: canBorrow,
                            document: document,
                          ),
                  );
                },
              ),
            );
          }),
      child: FutureBuilder(
        future: _getManual(),
        builder: (context, manualSnapshot) {
          final document = manualSnapshot.data;
          if ((manualSnapshot.connectionState != ConnectionState.active &&
                  manualSnapshot.connectionState != ConnectionState.done) ||
              document == null) {
            return Container();
          }
          final hasBorrowed =
              document.history?.status == ManualStatus.WAS_BORROWED.name;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                const SizedBox(
                  height: 16,
                ),
                Container(
                  constraints: const BoxConstraints(
                    minWidth: double.infinity,
                  ),
                  child: AspectRatio(
                    aspectRatio: 1 / 1,
                    child: Image.network(
                      document.image,
                      errorBuilder: (context, error, stackTrace) =>
                          Image.asset('assets/images/350x350.png'),
                    ),
                  ),
                ),
                _buildUserSection(
                  context: context,
                  hasBorrowed: hasBorrowed,
                  document: document,
                ),
                UserStorageBuilder(builder: (context, snapshots) {
                  if (snapshots.data?.getString("role") !=
                      UserStatus.ADMIN.name) {
                    return Container();
                  }
                  return _buildAdminSection(
                    context: context,
                    document: document,
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
