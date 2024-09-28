import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ec_student/enum/user_status.dart';
import 'package:ec_student/layouts/main_layout.dart';
import 'package:ec_student/models/database.dart';
import 'package:ec_student/models/document_model.dart';
import 'package:ec_student/models/history_model.dart';
import 'package:ec_student/presentation/common/list_card_item.dart';
import 'package:ec_student/screen/detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreen();
}

class _HistoryScreen extends State<HistoryScreen> {
  final Stream<QuerySnapshot> _historyStream =
      Database().getManualCollection().snapshots();

  _getListView(
    BuildContext context,
    AsyncSnapshot<QuerySnapshot> snapshot,
    AsyncSnapshot<SharedPreferences> storageSnapshot,
  ) {
    final role = storageSnapshot.data?.getString("role");
    final userId = storageSnapshot.data?.getString("userId");
    if (snapshot.hasError) {
      EasyLoading.showError('มีบางอย่างผิดพลาด');
      if (context.mounted) {
        return Center(
          child: Text(
            'มีบางอย่างผิดพลาด!',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        );
      }
    }

    if (snapshot.connectionState == ConnectionState.waiting) {
      EasyLoading.show(status: 'กำลังโหลด...');
      return Container();
    }

    EasyLoading.showSuccess('โหลดข้อมูลสำเร็จ');

    final List<ManualsModel> historyList = List.generate(
      snapshot.data!.docs.length,
      (index) => ManualsModel(
        id: snapshot.data!.docs[index].get('id'),
        name: snapshot.data!.docs[index].get('name'),
        image: snapshot.data!.docs[index].get('image'),
        level: snapshot.data!.docs[index].get('level'),
        projectName: snapshot.data!.docs[index].get('projectName'),
        department: snapshot.data!.docs[index].get('department'),
        documentId: snapshot.data!.docs[index].id,
        history: HistoryModel.fromJson(
          snapshot.data!.docs[index].get("history"),
        ),
      ),
    );

    if (role == UserStatus.USER.name) {
      final historyFiltered = historyList
          .where(
            (element) =>
                element.history?.user != null &&
                element.history?.userId == userId,
          )
          .toList();

      return ListView.builder(
        itemCount: historyFiltered.length,
        itemBuilder: (context, index) {
          return ListCardItem(
            document: historyFiltered[index],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(
                    document: historyFiltered[index],
                  ),
                ),
              );
            },
          );
        },
      );
    }

    final historyFiltered = historyList
        .where(
          (element) => element.history?.user != null,
        )
        .toList();

    return ListView.builder(
      itemCount: historyFiltered.length,
      itemBuilder: (context, index) {
        return ListCardItem(
          document: historyFiltered[index],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(
                  document: historyFiltered[index],
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

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'ประวัติการยืม / คืน',
      canDrawing: false,
      child: FutureBuilder(
        future: _getStorage(),
        builder: (
          BuildContext context,
          AsyncSnapshot<SharedPreferences> storageSnapshot,
        ) {
          if (!storageSnapshot.hasData) {
            return const CircularProgressIndicator();
          }
          return StreamBuilder<QuerySnapshot>(
            stream: _historyStream,
            builder: (
              BuildContext context,
              AsyncSnapshot<QuerySnapshot> snapshot,
            ) {
              return _getListView(
                context,
                snapshot,
                storageSnapshot,
              );
            },
          );
        },
      ),
    );
  }
}
