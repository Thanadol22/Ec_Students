import 'package:ec_student/enum/manual_status.dart';
import 'package:ec_student/layouts/main_layout.dart';
import 'package:ec_student/models/database.dart';
import 'package:ec_student/models/document_model.dart';
import 'package:ec_student/models/history_model.dart';
import 'package:ec_student/screen/main_screen.dart';
import 'package:ec_student/storage_service.dart';
import 'package:ec_student/utils/validator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class CreateManual extends StatefulWidget {
  const CreateManual({super.key});

  @override
  State<CreateManual> createState() => _CreateManual();
}

class _CreateManual extends State<CreateManual> {
  late TextEditingController _id;
  late TextEditingController _projectName;
  late TextEditingController _name;
  late TextEditingController _level;
  late TextEditingController _department;
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
    _projectName = TextEditingController();
    _name = TextEditingController();
    _id = TextEditingController();
    _level = TextEditingController();
    _department = TextEditingController();
    _imagePath = '';
  }

  @override
  void dispose() {
    _projectName.dispose();
    _id.dispose();
    _name.dispose();
    _level.dispose();
    _department.dispose();
    super.dispose();
  }

  Future<void> _createProject({
    required BuildContext context,
    required String department,
    required String id,
    required String image,
    required String name,
    required String level,
    required String projectName,
    required String status,
  }) async {
    final db = Database();
    final documentId = int.parse(id);

    final manualData = ManualsModel(
        id: documentId,
        name: name,
        image: image,
        level: level,
        projectName: projectName,
        department: department,
        history: HistoryModel(
          status: ManualStatus.AVAILABLE.name,
          user: null,
          userId: null,
        ));

    final manualCollection = db.getManualCollection();
    final existingDocuments = await manualCollection
        .where("id", isEqualTo: documentId)
        .get()
        .then((snapshot) => snapshot.docs);

    if (existingDocuments.isNotEmpty) {
      final snackBar = SnackBar(
        content: const Text('หมายเลขรูปเล่มซ้ำ!'),
        action: SnackBarAction(
          label: 'แย่จัง!',
          onPressed: () {
            // Some code to undo the change.
            ScaffoldMessenger.of(context).clearSnackBars();
          },
        ),
      );
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    final value = await manualCollection.add(manualData);
    if (value.id.isNotEmpty) {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MainScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      canDrawing: false,
      title: 'เพิ่มข้อมูลโครงงาน',
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _id,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'หมายเลขรูปเล่ม',
                  ),
                  validator: Validators.compose([
                    Validators.required("กรุณากรอกข้อมูล"),
                    Validators.pattern(RegExp(r'[0-9]+'), "กรุณากรอกตัวเลข"),
                  ]),
                ),
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
                        _createProject(
                          context: context,
                          image: _imagePath,
                          level: _level.text,
                          name: _name.text,
                          projectName: _projectName.text,
                          status: "User",
                          department: _department.text,
                          id: _id.text,
                        ),
                      }
                  },
                  child: const Text(
                    "เพิ่มข้อมูล",
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
