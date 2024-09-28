import 'package:ec_student/enum/user_status.dart';
import 'package:ec_student/models/document_model.dart';
import 'package:ec_student/presentation/common/confirm_dialog.dart';
import 'package:ec_student/presentation/common/status_chip.dart';
import 'package:ec_student/screen/edit_manual_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListCardItem extends StatelessWidget {
  final void Function()? onTap;

  final ManualsModel document;
  final Function()? onDelete;
  final bool canManage;

  const ListCardItem({
    super.key,
    required this.document,
    this.onTap,
    this.onDelete,
    this.canManage = false,
  });

  List<Widget> _buildRemoveButton({
    required BuildContext context,
    required String role,
  }) {
    return [
      IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditManualScreen(manual: document),
            ),
          );
        },
        color: Colors.blue.shade700,
        icon: const Icon(
          Icons.edit,
        ),
      ),
      IconButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => ConfirmDialog(
              content: const Text(
                  "ข้อมูลโครงงาน และข้อมูลการยืมจะหายจากระบบ คุณต้องการดำเนินการต่อหรือไม่?"),
              title: "ลบข้อมูลโครงงาน ${document.projectName}!",
              onPressed: onDelete,
            ),
          );
        },
        color: Colors.red.shade900,
        icon: const Icon(
          Icons.remove_circle,
        ),
      )
    ];
  }

  Future<SharedPreferences>? _getStorage() async {
    return await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                constraints: const BoxConstraints(
                  maxWidth: 120,
                  maxHeight: 130,
                  minWidth: 100,
                  minHeight: 100,
                ),
                child: Image.network(
                  document.image,
                  errorBuilder: (context, error, stackTrace) =>
                      Image.asset('assets/images/350x350.png'),
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  FutureBuilder(
                    future: _getStorage(),
                    builder: (
                      BuildContext context,
                      AsyncSnapshot<SharedPreferences> snapshot,
                    ) {
                      final role = snapshot.data?.getString('role') ??
                          UserStatus.USER.name;

                      if (!snapshot.hasData ||
                          role == UserStatus.USER.name ||
                          !canManage) {
                        return StatusChip(
                          status: document.history?.status ?? '',
                          name: document.history?.user?.name,
                        );
                      }

                      return Row(
                        children: <Widget>[
                              (StatusChip(
                                status: document.history?.status ?? '',
                                name: document.history?.user?.name,
                              ))
                            ] +
                            _buildRemoveButton(
                              context: context,
                              role: role,
                            ),
                      );
                    },
                  ),
                  Text(
                    'หมายเลขรูปเล่ม: ${document.id.toString()}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  SizedBox(
                    width: 200,
                    child: Text(
                      document.projectName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    document.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    document.department,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    document.level,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
