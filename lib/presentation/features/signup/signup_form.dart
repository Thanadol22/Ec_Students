// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ec_student/enum/user_status.dart';
import 'package:ec_student/models/user_model.dart';
import 'package:ec_student/presentation/common/app_logo.dart';
import 'package:ec_student/presentation/common/signin_footer.dart';
import 'package:ec_student/screen/signin_screen.dart';
import 'package:ec_student/utils/validator.dart';
import 'package:flutter/material.dart';

class SignupForm extends StatefulWidget {
  final TextEditingController _password;
  final TextEditingController _email;
  final TextEditingController _department;
  final TextEditingController _level;
  final TextEditingController _name;
  final String _label;
  final VoidCallback voidCallback;

  const SignupForm({
    Key? key,
    required TextEditingController password,
    required TextEditingController email,
    required TextEditingController level,
    required TextEditingController department,
    required TextEditingController name,
    required String label,
    required VoidCallback onNavigate,
  })  : _password = password,
        _email = email,
        _label = label,
        _department = department,
        _name = name,
        _level = level,
        voidCallback = onNavigate,
        super(key: key);

  @override
  State<SignupForm> createState() => _SignupFormState();

  Future<void> createAccount({
    required BuildContext context,
    required String email,
    required String password,
    required String level,
    required String department,
    required String name,
  }) async {
    final db = FirebaseFirestore.instance;
    final user = UserModel(
      email: email,
      name: name,
      level: level,
      status: UserStatus.USER.name,
      password: password,
      department: department,
    );

    final collection = db.collection("users");
    final existUser = await collection
        .where("email", isEqualTo: email)
        .get()
        .then((snapshot) => snapshot.docs);
    if (existUser.isNotEmpty) {
      final snackBar = SnackBar(
        content: const Text('ชื่อผู้ใช้ซ้ำ!'),
        action: SnackBarAction(
          label: 'เคลียร์!',
          onPressed: () {
            // Some code to undo the change.
            ScaffoldMessenger.of(context).clearSnackBars();
          },
        ),
      );
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    final value = await collection.add(user.toJson());

    if (value.id.isNotEmpty) {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SigninScreen(),
          ),
        );
      }
    }
  }
}

class _SignupFormState extends State<SignupForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16),
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
                AppLogo(),
                Text(
                  widget._label,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: widget._email,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'อีเมล',
                  ),
                  validator: Validators.compose([
                    Validators.required("กรุณากรอกข้อมูล"),
                    Validators.email("อีเมลไม่ถูกต้อง")
                  ]),
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: widget._password,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'รหัสผ่าน',
                  ),
                  validator: Validators.compose([
                    Validators.required("กรุณากรอกข้อมูล"),
                  ]),
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: widget._name,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'ชื่อ-นามสกุล',
                  ),
                  validator: Validators.compose([
                    Validators.required("กรุณากรอกข้อมูล"),
                  ]),
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: widget._department,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'สาขาวิชา',
                  ),
                  validator: Validators.compose([
                    Validators.required("กรุณากรอกข้อมูล"),
                  ]),
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  scrollPadding: const EdgeInsets.only(bottom: 32.0),
                  controller: widget._level,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'ระดับชั้น',
                  ),
                  validator: Validators.compose([
                    Validators.required("กรุณากรอกข้อมูล"),
                  ]),
                ),
                SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(42)),
                  onPressed: () => {
                    if (_formKey.currentState!.validate())
                      {
                        widget.createAccount(
                          context: context,
                          email: widget._email.text,
                          department: widget._department.text,
                          level: widget._level.text,
                          name: widget._name.text,
                          password: widget._password.text,
                        )
                      }
                  },
                  child: Text(
                    widget._label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 16,
          ),
          SigninFooter(
            buttonLabel: 'ลงชื่อเข้าใช้',
            label: 'หากมีบัญชีแล้ว?',
            onNavigate: widget.voidCallback,
          ),
        ],
      ),
    );
  }
}
