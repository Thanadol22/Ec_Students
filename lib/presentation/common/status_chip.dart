import 'package:ec_student/enum/manual_status.dart';
import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String status;
  final String? name;
  final bool shouldWrapText;
  const StatusChip(
      {super.key,
      required this.status,
      this.name,
      this.shouldWrapText = false});

  Color _getChipBackground(String status) {
    if (status == ManualStatus.AVAILABLE.name) {
      return Colors.blue.shade700;
    }

    if (status == ManualStatus.BORROW_REQUESTED.name) {
      return Colors.yellow.shade300;
    }

    if (status == ManualStatus.REMOVE_REQUESTED.name) {
      return Colors.blueAccent;
    }

    return Colors.red.shade800;
  }

  String _getLabel(String status, String? name) {
    if (status == ManualStatus.BORROW_REQUESTED.name) {
      return name != null ? "ขอยืมโดย: $name" : "ขอยืม";
    }
    if (status == ManualStatus.REMOVE_REQUESTED.name) {
      return name != null ? "ขอคืนโดย: $name" : "ขอคืน";
    }
    if (status == ManualStatus.WAS_BORROWED.name) {
      return name != null ? "ยืมโดย: $name" : "ยืม";
    }
    return "พร้อมยืม";
  }

  Color? _getTextColor(String status) {
    if (status == ManualStatus.BORROW_REQUESTED.name) {
      return Colors.black87;
    }

    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      labelPadding: const EdgeInsets.only(
        left: 8,
        right: 8,
        top: 0,
        bottom: 0,
      ),
      backgroundColor: _getChipBackground(status),
      labelStyle: Theme.of(context).textTheme.bodySmall!.merge(
            TextStyle(
              color: _getTextColor(status),
            ),
          ),
      label: Container(
        constraints: const BoxConstraints(maxWidth: 100.0),
        child: Text(
          _getLabel(status, name),
          overflow: TextOverflow.fade,
        ),
      ),
    );
  }
}
