import 'dart:developer';
import 'dart:io';

import 'package:ec_student/enum/manual_status.dart';
import 'package:ec_student/enum/user_status.dart';
import 'package:ec_student/layouts/main_layout.dart';
import 'package:ec_student/models/document_model.dart';
import 'package:ec_student/presentation/features/detail/detail_content.dart';
import 'package:ec_student/screen/main_screen.dart';
import 'package:ec_student/service/borrow_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zxing2/qrcode.dart';
import 'package:image/image.dart' as img;

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  Barcode? result;
  QRViewController? controller;
  ManualsModel? manualState;
  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  Future<void> borrowed() async {
    final borrowService = BorrowService();
    if (manualState == null) {
      return;
    }
    final isSuccess =
        await borrowService.updateBorrowData(document: manualState!);

    if (!isSuccess && context.mounted) {
      EasyLoading.showError("ทำรายการไม่สำเร็จ");
      return;
    }

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainScreen(),
        ),
      );
      /* Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DetailScreen(document: manualState!),
        ),
      ); */
    }
  }

  Future<void> searchDetail({
    required BuildContext context,
    required String text,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final borrowService = BorrowService();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("รหัสคิวอาร์โค๊ด: $text"),
        ),
      );
    }

    final manualFind = await borrowService.findById(text);

    if (manualFind == null) {
      EasyLoading.showError("โหลดข้อมูลไม่สำเร็จ");
      return;
    }

    EasyLoading.showSuccess("โหลดข้อมูลสำเร็จ");
    if (context.mounted) {
      final manualModel = ManualsModel(
        id: manualFind.id,
        name: manualFind.name,
        image: manualFind.image,
        level: manualFind.level,
        projectName: manualFind.projectName,
        department: manualFind.department,
        history: manualFind.history,
        documentId: text,
      );

      setState(() {
        manualState = manualModel;
      });

      controller?.pauseCamera();

      final bool hasBorrowed =
          manualModel.history?.status == ManualStatus.WAS_BORROWED.name;

      final bool isAvailable =
          manualModel.history?.status == ManualStatus.AVAILABLE.name;

      final String borrowedLabel = hasBorrowed ? "คืน" : "ยืม";
      final userId = prefs.getString("userId");
      final role = prefs.getString("role");
      final canBorrow = hasBorrowed
          ? userId == manualModel.history?.userId ||
              role == UserStatus.ADMIN.name
          : isAvailable;

      if (canBorrow) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text('ยืนยันการ$borrowedLabel'),
            content: DetailContent(
              document: manualModel,
              hasBorrowed: hasBorrowed,
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context, 'ยกเลิก');
                  controller?.resumeCamera();
                },
                child: const Text('ยกเลิก'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, 'ตกลง');
                  borrowed();
                },
                child: const Text('ตกลง'),
              ),
            ],
          ),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("ไม่สามารถทำรายการได้"),
          content: const Text("คู่มือเล่มนี้มีผู้ใช้รายอื่นอยู่ระหว่างการยืม"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                controller?.resumeCamera();
                Navigator.pop(context, 'ตกลง');
              },
              child: const Text('ตกลง'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> pickQRImage({required BuildContext context}) async {
    FilePickerResult? resultPicked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: ['jpg', 'png', 'webp', 'gif', 'jpeg'],
    );

    if (resultPicked == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่ได้เลือกไฟล์')),
        );
      }
      return;
    }
    final path = resultPicked.files.single.path!;

    var image = img.decodePng(File(path).readAsBytesSync());
    if (image == null) {
      return;
    }

    LuminanceSource source = RGBLuminanceSource(
        image.width,
        image.height,
        image
            .convert(numChannels: 4)
            .getBytes(order: img.ChannelOrder.abgr)
            .buffer
            .asInt32List());
    var bitmap = BinaryBitmap(GlobalHistogramBinarizer(source));

    var reader = QRCodeReader();
    var resultScanned = reader.decode(bitmap);
    if (resultScanned.text.isNotEmpty) {
      EasyLoading.show(status: "กำลังโหลดข้อมูล...");
      if (context.mounted) {
        searchDetail(
          context: context,
          text: resultScanned.text,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: "สแกนคิวอาร์โค๊ด",
      canDrawing: false,
      isDisableAppBar: true,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: <Widget>[
                  _buildQrView(context),
                  IconButton(
                    onPressed: () {
                      controller?.stopCamera();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainScreen(),
                        ),
                      );
                    },
                    iconSize: 32,
                    icon: const Icon(Icons.close),
                    color: Colors.white,
                    alignment: Alignment.topRight,
                  ),
                ],
              ),
              Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  IconButton(
                    color: Colors.white,
                    iconSize: 64,
                    icon: const Icon(
                      Icons.image,
                    ),
                    onPressed: () {
                      pickQRImage(context: context);
                    },
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 300.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: (p0) => _onQRViewCreated(
        controller: p0,
        context: context,
      ),
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated({
    required BuildContext context,
    required QRViewController controller,
  }) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((scanData) {
      if (scanData.code == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not found')),
        );
        return;
      }
      controller.stopCamera();
      searchDetail(context: context, text: scanData.code!);
      setState(() {
        result = scanData;
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }
}
