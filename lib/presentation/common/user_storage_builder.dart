import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserStorageBuilder extends StatefulWidget {
  final Function(
      BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) builder;
  const UserStorageBuilder({Key? key, required this.builder}) : super(key: key);

  @override
  State<UserStorageBuilder> createState() => _UserStorage();
}

class _UserStorage extends State<UserStorageBuilder> {
  Future<SharedPreferences>? _getStorage() async {
    return await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getStorage(),
      builder: (context, snapshot) {
        return widget.builder(context, snapshot);
      },
    );
  }
}
