// ignore_for_file: prefer_const_constructors

import 'package:ec_student/models/user_model.dart';
import 'package:ec_student/presentation/features/signup/edit_profile_form.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  const EditProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _department = TextEditingController();
  final TextEditingController _level = TextEditingController();
  final TextEditingController _name = TextEditingController();

  @override
  void initState() {
    super.initState();
    _department.text = widget.user.department;
    _name.text = widget.user.name;
    _level.text = widget.user.level;
  }

  @override
  void dispose() {
    _department.dispose();
    _level.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.user.name),
        ),
        body: SingleChildScrollView(
          child: EditProfileForm(
            user: widget.user,
            department: _department,
            level: _level,
            name: _name,
          ),
        ),
      ),
    );
  }
}
