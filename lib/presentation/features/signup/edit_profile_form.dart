import 'package:ec_student/models/database.dart';
import 'package:ec_student/models/user_model.dart';
import 'package:ec_student/presentation/common/confirm_dialog.dart';
import 'package:ec_student/screen/user_list_screen.dart';
import 'package:ec_student/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class EditProfileForm extends StatefulWidget {
  final TextEditingController _department;
  final TextEditingController _level;
  final TextEditingController _name;
  final UserModel user;

  const EditProfileForm({
    Key? key,
    required TextEditingController level,
    required TextEditingController department,
    required TextEditingController name,
    required this.user,
  })  : _department = department,
        _name = name,
        _level = level,
        super(key: key);

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();

  Future<void> updateAccount({
    required BuildContext context,
    required String email,
    required String password,
    required String level,
    required String department,
    required String name,
    required String userId,
    required String status,
  }) async {
    final db = Database();

    final collection = db.getUserCollection();
    EasyLoading.show(status: "กำลังโหลด...");

    try {
      await collection.doc(userId).set(
            UserModel(
              name: name,
              level: level,
              status: status,
              department: department,
              email: email,
              password: password,
            ),
          );

      if (context.mounted) {
        EasyLoading.showSuccess("แก้ไขข้อมูลสำเร็จ");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const UserScreen(),
          ),
        );
      }
    } catch (e) {
      EasyLoading.showSuccess("แก้ไขข้อมูลไม่สำเร็จ");
    }
  }
}

class _EditProfileFormState extends State<EditProfileForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: widget._name,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'ชื่อ-นามสกุล',
                  ),
                  validator: Validators.compose([
                    Validators.required("กรุณากรอกข้อมูล"),
                  ]),
                ),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: widget._department,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'สาขาวิชา',
                  ),
                  validator: Validators.compose([
                    Validators.required("กรุณากรอกข้อมูล"),
                  ]),
                ),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  scrollPadding: const EdgeInsets.only(bottom: 32.0),
                  controller: widget._level,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'ระดับชั้น',
                  ),
                  validator: Validators.compose([
                    Validators.required("กรุณากรอกข้อมูล"),
                  ]),
                ),
                const SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(42)),
                  onPressed: () => {
                    if (_formKey.currentState!.validate())
                      {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => ConfirmDialog(
                            content:
                                const Text("คุณต้องการแก้ไขข้อมูลหรือไม่?"),
                            title: "แก้ไขข้อมูลผู้ใช้",
                            onPressed: () => widget.updateAccount(
                              context: context,
                              email: widget.user.email,
                              department: widget._department.text,
                              level: widget._level.text,
                              name: widget._name.text,
                              password: widget.user.password,
                              userId: widget.user.userId ?? '',
                              status: widget.user.status,
                            ),
                          ),
                        ),
                      }
                  },
                  child: const Text(
                    "แก้ไขข้อมูล",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
