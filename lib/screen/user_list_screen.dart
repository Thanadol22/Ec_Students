import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ec_student/enum/user_status.dart';
import 'package:ec_student/layouts/main_layout.dart';
import 'package:ec_student/models/database.dart';
import 'package:ec_student/models/user_model.dart';
import 'package:ec_student/presentation/common/confirm_dialog.dart';
import 'package:ec_student/screen/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final Stream<QuerySnapshot> _documentStream =
      FirebaseFirestore.instance.collection('users').snapshots();

  List<UserModel> getList(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    final datas = List.generate(
      snapshot.data!.docs.length,
      (index) => UserModel(
        name: snapshot.data!.docs[index]["name"],
        level: snapshot.data!.docs[index]["level"],
        department: snapshot.data!.docs[index]["department"],
        email: snapshot.data!.docs[index]["email"],
        password: snapshot.data!.docs[index]["password"],
        status: snapshot.data!.docs[index]["status"],
        userId: snapshot.data!.docs[index].id,
      ),
    );
    return datas;
  }

  Widget _getUserListView(
    BuildContext context,
    AsyncSnapshot<QuerySnapshot> snapshot,
    String userId,
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

    List<UserModel> datas = getList(snapshot);

    return ListView.builder(
      itemCount: datas.length,
      itemBuilder: (context, index) {
        final item = datas[index];

        return Padding(
          padding: const EdgeInsets.all(8),
          child: Card(
            child: ListTile(
              title: Text(
                item.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              subtitle: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "แผนกวิชา: ${item.department}",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    "ระดับชั้น: ${item.level}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              trailing: Wrap(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(
                              user: datas[index],
                            ),
                          ));
                    },
                    icon: const Icon(Icons.edit),
                    color: Colors.blue.shade700,
                  ),
                  IconButton(
                    onPressed: (userId.isNotEmpty &&
                            userId != datas[index].userId)
                        ? () => showDialog(
                              context: context,
                              builder: (BuildContext context) => ConfirmDialog(
                                content: Text(
                                    "คุณต้องการลบผู้ใช้ \"${datas[index].name}\" หรือไม่?"),
                                title: "ลบข้อมูลผู้ใช้",
                                onPressed: () => _removeUser(
                                  context: context,
                                  user: datas[index],
                                ),
                              ),
                            )
                        : null,
                    icon: const Icon(Icons.remove_circle),
                    color: Colors.red.shade900,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<SharedPreferences>? _getStorage() async {
    return await SharedPreferences.getInstance();
  }

  Future<void> _removeUser({
    required BuildContext context,
    required UserModel user,
  }) async {
    final db = Database();
    final userCollection = db.getUserCollection();
    EasyLoading.show(status: "กำลังลบ...");
    await userCollection.doc(user.userId).delete();

    if (context.mounted) {
      EasyLoading.showSuccess("ลบข้อมูลสำเร็จ");
      Navigator.of(context).pop();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'จัดการข้อมูลผู้ใช้',
      canDrawing: false,
      child: FutureBuilder(
        future: _getStorage(),
        builder: (
          BuildContext context,
          AsyncSnapshot<SharedPreferences> storageSnapshot,
        ) {
          if (storageSnapshot.connectionState != ConnectionState.active &&
              storageSnapshot.connectionState != ConnectionState.done) {
            return Container();
          }
          if (!storageSnapshot.hasData ||
              storageSnapshot.data?.getString("role") !=
                  UserStatus.ADMIN.name) {
            return const Center(
              child: Text("ไม่มีสิทธิเข้าถึงเพจ"),
            );
          }
          return StreamBuilder(
            stream: _documentStream,
            builder: (
              BuildContext context,
              AsyncSnapshot<QuerySnapshot> snapshot,
            ) {
              return _getUserListView(
                context,
                snapshot,
                storageSnapshot.data?.getString("userId") ?? '',
              );
            },
          );
        },
      ),
    );
  }
}
