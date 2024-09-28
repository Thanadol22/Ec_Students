import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ec_student/models/database.dart';
import 'package:ec_student/models/document_model.dart';
import 'package:ec_student/models/history_model.dart';
import 'package:ec_student/presentation/common/list_card_item.dart';
import 'package:ec_student/screen/detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class SearchScreen extends StatefulWidget {
  final String? keyword;
  const SearchScreen({
    Key? key,
    this.keyword,
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreen();
}

class _SearchScreen extends State<SearchScreen> {
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

    List<ManualsModel> datas = getList(snapshot).where((field) {
      var keyword = widget.keyword?.toLowerCase() ?? '';
      return field.name.toLowerCase().contains(keyword) ||
          field.projectName.toLowerCase().contains(keyword) ||
          field.level.toLowerCase().contains(keyword) ||
          field.department.toLowerCase().contains(keyword);
    }).toList();

    if (datas.isEmpty) {
      return Center(
        child: Text(
          'ไม่พบข้อมูล',
          style: Theme.of(context).textTheme.displaySmall,
        ),
      );
    }

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
                builder: (context) => DetailScreen(document: datas[index]),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _documentStream,
      builder: (
        BuildContext context,
        AsyncSnapshot<QuerySnapshot> snapshot,
      ) {
        return _getListView(context, snapshot);
      },
    );
  }
}
