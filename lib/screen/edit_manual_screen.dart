import 'package:ec_student/layouts/main_layout.dart';
import 'package:ec_student/models/database.dart';
import 'package:ec_student/models/document_model.dart';
import 'package:ec_student/screen/main_screen.dart';
import 'package:ec_student/storage_service.dart';
import 'package:ec_student/utils/validator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class EditManualScreen extends StatefulWidget {
  final ManualsModel manual;
  const EditManualScreen({super.key, required this.manual});

  @override
  State<EditManualScreen> createState() => _EditManualScreenState();
}

class _EditManualScreenState extends State<EditManualScreen> {
  final TextEditingController _projectName = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _level = TextEditingController();
  final TextEditingController _department = TextEditingController();
  late String _imagePath;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Storage storage = Storage();

  // File? _image;
  // Implementing the image picker
  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: ['jpg', 'png', 'webp', 'gif'],
    );

    if (result == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่ได้เลือกไฟล์')),
        );
      }
      return;
    }
    final path = result.files.single.path!;
    final fileName = result.files.single.name;
    EasyLoading.show(status: 'กำลังอัพโหลด');
    storage.uploadFile(path, fileName).then((value) {
      const uri =
          'https://firebasestorage.googleapis.com/v0/b/ec-student-project.appspot.com/o';
      final pathName = Uri.encodeComponent('uploads/$fileName');
      setState(() {
        _imagePath = '$uri/$pathName?alt=media';
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('อัพโหลดไฟล์สำเร็จ'),
          ),
        );
      }
      EasyLoading.showSuccess('อัพโหลดสำเร็จ');
      return;
    });
  }

  @override
  void initState() {
    super.initState();

    _projectName.text = widget.manual.projectName;
    _department.text = widget.manual.department;
    _level.text = widget.manual.level;
    _name.text = widget.manual.name;

    _imagePath = '';
  }

  @override
  void dispose() {
    _projectName.dispose();
    _name.dispose();
    _level.dispose();
    _department.dispose();
    super.dispose();
  }

  Future<void> _updateManual({
    required BuildContext context,
    required String department,
    required String image,
    required String name,
    required String level,
    required String projectName,
    required int id,
    required ManualsModel manual,
  }) async {
    final db = Database();

    final manualData = ManualsModel(
      id: id,
      name: name,
      image: image,
      level: level,
      projectName: projectName,
      department: department,
      history: manual.history,
    );

    final manualCollection = db.getManualCollection();

    try {
      await manualCollection.doc(manual.documentId).set(manualData);
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MainScreen(),
          ),
        );
      }
    } catch (e) {
      EasyLoading.showError("แก้ไขข้อมูลไม่สำเร็จ");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      canDrawing: false,
      title: 'แก้ไขข้อมูลโครงงาน',
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: _projectName,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'ชื่อโครงงาน',
                  ),
                  validator: Validators.compose([
                    Validators.required("กรุณากรอกข้อมูล"),
                  ]),
                ),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'ผู้จัดทำ',
                  ),
                  validator: Validators.compose([
                    Validators.required("กรุณากรอกข้อมูล"),
                  ]),
                ),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: _level,
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
                TextFormField(
                  controller: _department,
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
                GestureDetector(
                  child: const Row(
                    children: [
                      Icon(Icons.upload_file),
                      Text('เลือกรูปภาพ'),
                    ],
                  ),
                  onTap: () => _pickImage(),
                ),
                const SizedBox(
                  height: 4,
                ),
                Flexible(
                  child: _imagePath.isEmpty
                      ? Text(
                          'ไม่ได้เลือกไฟล์',
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      : Text(
                          _imagePath,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                ),
                const SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(42),
                  ),
                  onPressed: () => {
                    if (_formKey.currentState!.validate())
                      {
                        _updateManual(
                          context: context,
                          image: _imagePath.isEmpty
                              ? widget.manual.image
                              : _imagePath,
                          level: _level.text,
                          name: _name.text,
                          projectName: _projectName.text,
                          department: _department.text,
                          id: widget.manual.id,
                          manual: widget.manual,
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
        ),
      ),
    );
  }
}
