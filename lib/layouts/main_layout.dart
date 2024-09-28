import 'package:ec_student/enum/user_status.dart';
import 'package:ec_student/presentation/common/app_logo.dart';
import 'package:ec_student/screen/history_screen.dart';
import 'package:ec_student/screen/qr_scan_screen.dart';
import 'package:ec_student/screen/signin_screen.dart';
import 'package:ec_student/screen/user_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainLayout extends StatefulWidget {
  final Widget _child;
  final String _title;
  final Widget? _floatingActionButton;
  final Widget? _bottomNavigationBar;
  final bool _canDrawing;
  final Widget? _drawerTitle;
  final bool isDisableAppBar;
  final List<Widget>? actions;

  const MainLayout({
    Key? key,
    required Widget child,
    required String title,
    Widget? floatingActionButton,
    Widget? bottomNavigationBar,
    Widget? drawerTitle,
    bool? canDrawing,
    this.isDisableAppBar = false,
    this.actions,
  })  : _child = child,
        _title = title,
        _floatingActionButton = floatingActionButton,
        _canDrawing = canDrawing ?? true,
        _bottomNavigationBar = bottomNavigationBar,
        _drawerTitle = drawerTitle,
        super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  Future<bool?> _shouldGetPermission() async {
    final pref = await SharedPreferences.getInstance();
    final role = pref.getString("role")!;

    if (role.isEmpty) {
      return false;
    }

    return role == UserStatus.ADMIN.name ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: !widget.isDisableAppBar
            ? AppBar(
                title: Text(widget._title),
                actions: widget.actions,
              )
            : null,
        drawer: widget._canDrawing
            ? Drawer(
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: ListView(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        children: <Widget>[
                          const SizedBox(
                            height: 32,
                          ),
                          const AppLogo(
                            width: 100,
                            height: 100,
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            color: Theme.of(context).hoverColor,
                            child: widget._drawerTitle,
                          ),
                          TextButton(
                            onPressed: () => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HistoryScreen(),
                                ),
                              )
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                const Icon(
                                  Icons.edit,
                                  color: Colors.black54,
                                ),
                                const SizedBox(
                                  width: 16,
                                ),
                                Text(
                                  'ประวัติการยืมคืน',
                                  style: Theme.of(context).textTheme.titleSmall,
                                )
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const QRScanScreen(),
                                ),
                              )
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                const Icon(
                                  Icons.qr_code_2,
                                  color: Colors.black54,
                                ),
                                const SizedBox(
                                  width: 16,
                                ),
                                Text(
                                  'สแกน ยืม / คืน',
                                  style: Theme.of(context).textTheme.titleSmall,
                                )
                              ],
                            ),
                          ),
                          FutureBuilder(
                            future: _shouldGetPermission(),
                            builder: (
                              BuildContext context,
                              AsyncSnapshot<bool?> snapshot,
                            ) {
                              if (!snapshot.hasData) {
                                return Container();
                              }

                              if (!snapshot.data!) {
                                return Container();
                              }

                              return TextButton(
                                onPressed: () => {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const UserScreen(),
                                    ),
                                  )
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    const Icon(
                                      Icons.people,
                                      color: Colors.black54,
                                    ),
                                    const SizedBox(
                                      width: 16,
                                    ),
                                    Text(
                                      'จัดการข้อมูลผู้ใช้',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    )
                                  ],
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        key: widget.key,
                        padding: const EdgeInsets.only(
                          left: 8,
                          right: 8,
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            final SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.remove('userId');
                            if (context.mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SigninScreen(),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            maximumSize: const Size.fromHeight(50),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.logout),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                'ออกจากระบบ',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : null,
        body: widget._child,
        floatingActionButton: widget._floatingActionButton,
        bottomNavigationBar: widget._bottomNavigationBar,
      ),
    );
  }
}
