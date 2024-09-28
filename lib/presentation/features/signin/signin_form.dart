// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ec_student/presentation/common/app_logo.dart';
import 'package:ec_student/presentation/common/signin_footer.dart';
import 'package:ec_student/screen/main_screen.dart';
import 'package:ec_student/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SigninForm extends StatefulWidget {
  final VoidCallback voidCallback;
  final TextEditingController _password;
  final TextEditingController _email;
  final String _label;

  const SigninForm(
      {Key? key,
      required TextEditingController password,
      required TextEditingController email,
      required VoidCallback onNavigate,
      required String label})
      : _password = password,
        _email = email,
        _label = label,
        voidCallback = onNavigate,
        super(key: key);

  @override
  State<SigninForm> createState() => _SigninFormState();

  Future<void> _authenticate({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    final db = FirebaseFirestore.instance;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final collection = db.collection("users");
    final existUser = await collection
        .where("email", isEqualTo: email)
        .where("password", isEqualTo: password)
        .get()
        .then((snapshot) => snapshot.docs);

    if (existUser.isNotEmpty) {
      prefs.setString('userId', existUser.first.id);
      prefs.setString("role", existUser.first["status"]);
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainScreen(),
          ),
        );
      }
      return;
    }

    final snackBar = SnackBar(
      content: const Text('อีเมลหรือรหัสผ่านไม่ถูกต้อง!'),
      action: SnackBarAction(
        label: 'เคลียร์!',
        onPressed: () {
          // Some code to undo the change.
          ScaffoldMessenger.of(context).clearSnackBars();
        },
      ),
    );
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

class _SigninFormState extends State<SigninForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 80,
                  ),
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
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.compose([
                      Validators.required("กรุณาใส่อีเมล"),
                      Validators.email("อีเมลไม่ถูกต้อง"),
                    ]),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'อีเมล',
                    ),
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
                      Validators.required("กรุณาใส่รหัสผ่าน"),
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
                          widget._authenticate(
                            context: context,
                            email: widget._email.text,
                            password: widget._password.text,
                          ),
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
              SizedBox(
                height: 32,
              ),
              SigninFooter(
                buttonLabel: 'ลงทะเบียน',
                label: 'หากยังไม่มีบัญชี?',
                onNavigate: widget.voidCallback,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
