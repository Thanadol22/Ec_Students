import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:ec_student/layouts/main_layout.dart';
import 'package:ec_student/models/document_model.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GenerateQRScreen extends StatefulWidget {
  final ManualsModel document;
  const GenerateQRScreen({
    Key? key,
    required this.document,
  }) : super(key: key);

  @override
  State<GenerateQRScreen> createState() => _GenerateQRScreen();
}

class _GenerateQRScreen extends State<GenerateQRScreen> {
  Future<bool?> writeToFile(ByteData data, String path) async {
    final buffer = data.buffer;
    await File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));

    final success = await GallerySaver.saveImage(path);
    return success;
  }

  Future<bool?> createQrPicture(String qr) async {
    final qrValidationResult =
        QrValidator.validate(data: widget.document.documentId!);
    final qrCode = qrValidationResult.qrCode;

    final painter = QrPainter.withQr(
      qr: qrCode!,
      color: Colors.black,
      gapless: true,
      emptyColor: Colors.white,
    );

    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    String path = '$tempPath/$qr.png';
    final picData = await painter.toImageData(400, format: ImageByteFormat.png);
    return await writeToFile(picData!, path);
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: "QR Code - ${widget.document.name}",
      canDrawing: false,
      child: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 32,
            ),
            QrImage(
              data: widget.document.documentId!,
              version: QrVersions.auto,
              size: 300.0,
            ),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton(
              onPressed: () async {
                final bool? isSuccess =
                    await createQrPicture(widget.document.documentId!);
                if (isSuccess == true) {
                  final snackBar = SnackBar(
                    content: const Text('ดาวน์โหลดสำเร็จ'),
                    action: SnackBarAction(
                      label: 'ปิด',
                      onPressed: () {
                        // Some code to undo the change.
                        ScaffoldMessenger.of(context).clearSnackBars();
                      },
                    ),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                } else {
                  final snackBar = SnackBar(
                    content: const Text('ดาวน์โหลดไม่สำเร็จ'),
                    action: SnackBarAction(
                      label: 'ปิด',
                      onPressed: () {
                        // Some code to undo the change.
                        ScaffoldMessenger.of(context).clearSnackBars();
                      },
                    ),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                }
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.download),
                  Text("ดาวน์โหลด"),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
