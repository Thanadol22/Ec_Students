import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ec_student/enum/user_status.dart';
import 'package:ec_student/layouts/main_layout.dart';
import 'package:ec_student/models/database.dart';
import 'package:ec_student/models/document_model.dart';
import 'package:ec_student/models/history_model.dart';
import 'package:ec_student/models/user_model.dart';
import 'package:ec_student/presentation/common/list_card_item.dart';
import 'package:ec_student/presentation/common/my_search_deligate.dart';
import 'package:ec_student/screen/detail_screen.dart';
import 'package:ec_student/screen/create_manual.dart';
import 'package:ec_student/screen/qr_scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen> {
  final Stream<QuerySnapshot> _documentStream =
      FirebaseFirestore.instance.collection('manuals').snapshots();

  List<ManualsModel> getList(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    final datas = List.generate(
      snapshot.data!.docs.length,
      (index) => ManualsModel(
        id: snapshot.data!.docs[index]["id"],
        name: snapshot.data!.docs[index]["name"],
        image: snapshot.data!.docs[index]["image"],
        level: snapshot.data!.docs[index]["level"],
        projectName: snapshot.data!.docs[index]["projectName"],
        department: snapshot.data!.docs[index]["department"],
        documentId: snapshot.data!.docs[index].id,
        history: HistoryModel.fromJson(
          snapshot.data!.docs[index].get("history"),
        ),
      ),
    );
    return datas;
  }

  Widget _getListView(
    BuildContext context,
    AsyncSnapshot<QuerySnapshot> snapshot,
  ) {
    if (snapshot.hasError) {
      return Center(
        child: Text(
          'มีบางอย่างผิดพลาด!',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      );
    }

    if (snapshot.connectionState == ConnectionState.waiting) {
      return Container();
    }

    EasyLoading.showSuccess('โหลดข้อมูลสำเร็จ');

    List<ManualsModel> datas = getList(snapshot);

    return ListView.builder(
      itemCount: datas.length,
      itemBuilder: (context, index) {
        return ListCardItem(
          document: datas[index],
          canManage: true,
          onDelete: () => _removeManual(
            context: context,
            manual: datas[index],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(
                  document: datas[index],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<SharedPreferences>? _getStorage() async {
    return await SharedPreferences.getInstance();
  }

  Future<UserModel?> _getUser() async {
    final db = Database();
    final pref = await SharedPreferences.getInstance();
    final userId = pref.getString("userId")!;

    if (userId.isEmpty) {
      return null;
    }

    final userCollection = db.getUserCollection();

    final result = await userCollection.doc(userId).get();

    return result.data();
  }

  Future<void> _removeManual({
    required BuildContext context,
    required ManualsModel manual,
  }) async {
    final db = Database();
    final userCollection = db.getManualCollection();
    EasyLoading.show(status: "กำลังลบ...");

    try {
      await userCollection.doc(manual.documentId).delete();

      if (context.mounted) {
        EasyLoading.showSuccess("ลบข้อมูลสำเร็จ");
        Navigator.of(context).pop();
      }

      setState(() {});
    } catch (e) {
      EasyLoading.showError("ลบข้อมูลไม่สำเร็จ");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Ec Student Project',
      drawerTitle: FutureBuilder(
        future: _getUser(),
        builder: (
          BuildContext context,
          AsyncSnapshot<UserModel?> userSnapshot,
        ) {
          if (!userSnapshot.hasData || userSnapshot.data == null) {
            return Container();
          }

          final userData = userSnapshot.data!;
          return Column(
            children: [
              Text(
                userData.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                "แผนก: ${userData.department}",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                "ระดับชั้น: ${userData.level}",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          );
        },
      ),
      actions: [
        StreamBuilder(
          stream: _documentStream,
          builder: (
            BuildContext context,
            AsyncSnapshot<QuerySnapshot> snapshot,
          ) {
            return IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: MySearchDelegate(snapshot: snapshot),
                );
              },
              icon: const Icon(Icons.search),
            );
          },
        ),
      ],
      floatingActionButton: FutureBuilder(
        future: _getStorage(),
        builder: (
          BuildContext context,
          AsyncSnapshot<SharedPreferences> storageSnapshot,
        ) {
          if (!storageSnapshot.hasData) {
            return const Center(
              child: RefreshProgressIndicator(),
            );
          }
          if (storageSnapshot.data?.getString("role") ==
              UserStatus.ADMIN.name) {
            return FloatingActionButton(
              onPressed: () {},
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateManual(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
              ),
            );
          } else {
            return FloatingActionButton(
              onPressed: () {},
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QRScanScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.qr_code_scanner),
              ),
            );
          }
        },
      ),
      child: StreamBuilder(
        stream: _documentStream,
        builder: (
          BuildContext context,
          AsyncSnapshot<QuerySnapshot> snapshot,
        ) {
          return _getListView(context, snapshot);
        },
      ),
    );
  }
}
