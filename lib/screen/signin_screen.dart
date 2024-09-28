// ignore_for_file: prefer_const_constructors

import 'package:ec_student/presentation/features/signin/signin_form.dart';
import 'package:ec_student/screen/signup_screen.dart';
import 'package:flutter/material.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  late TextEditingController _username;
  late TextEditingController _password;

  @override
  void initState() {
    super.initState();
    _password = TextEditingController();
    _username = TextEditingController();
  }

  @override
  void dispose() {
    _password.dispose();
    _username.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SigninForm(
          password: _password,
          email: _username,
          label: "ลงชื่อเข้าใช้",
          onNavigate: () => {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SignupScreen(),
              ),
            )
          },
        ),
      ),
    );
  }
}
