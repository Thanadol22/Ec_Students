import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ec_student/models/document_model.dart';
import 'package:ec_student/models/history_model.dart';
import 'package:ec_student/screen/detail_screen.dart';
import 'package:ec_student/screen/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class MySearchDelegate extends SearchDelegate {
  AsyncSnapshot<QuerySnapshot> snapshot;

  MySearchDelegate({
    required this.snapshot,
  });

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(
        Icons.arrow_back,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        onPressed: () {
          if (query.isNotEmpty) {
            query = '';
          } else {
            close(context, null);
          }
        },
        icon: const Icon(
          Icons.clear,
        ),
      )
    ];
  }

  @override
  Widget buildResults(BuildContext context) {
    return SearchScreen(
      keyword: query,
    );
  }

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

  @override
  Widget buildSuggestions(BuildContext context) {
    if (snapshot.hasError) {
      EasyLoading.showError('มีบางอย่างผิดพลาด');
      return Center(
        child: Text(
          'มีบางอย่างผิดพลาด!',
          style: Theme.of(context).textTheme.displaySmall,
        ),
      );
    }

    List<ManualsModel> suggestions = getList(snapshot).where((field) {
      final result = field.projectName.toLowerCase();
      final input = query.toLowerCase();

      return result.contains(input);
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (BuildContext context, int index) {
        final suggestion = suggestions[index];
        return ListTile(
          title: Text(suggestion.projectName),
          onTap: () {
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(document: suggestion),
                ),
              );
            }
          },
        );
      },
    );
  }
}
