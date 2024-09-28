// ignore_for_file: prefer_const_constructors

import 'package:ec_student/presentation/features/signup/signup_form.dart';
import 'package:ec_student/screen/signin_screen.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late TextEditingController _username;
  late TextEditingController _password;
  late TextEditingController _department;
  late TextEditingController _level;
  late TextEditingController _name;

  @override
  void initState() {
    super.initState();
    _password = TextEditingController();
    _username = TextEditingController();
    _department = TextEditingController();
    _name = TextEditingController();
    _level = TextEditingController();
  }

  @override
  void dispose() {
    _password.dispose();
    _username.dispose();
    _department.dispose();
    _level.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: SignupForm(
            password: _password,
            email: _username,
            department: _department,
            level: _level,
            name: _name,
            label: "ลงทะเบียน",
            onNavigate: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SigninScreen(),
                ),
              )
            },
          ),
        ),
      ),
    );
  }
}
