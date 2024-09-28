import 'package:ec_student/firebase_options.dart';
import 'package:ec_student/screen/main_screen.dart';
import 'package:ec_student/screen/signin_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SharedPreferences sharedPref = await SharedPreferences.getInstance();
  runApp(MainApp(sharedPref: sharedPref));
}

class MainApp extends StatefulWidget {
  final SharedPreferences sharedPref;
  const MainApp({
    Key? key,
    required this.sharedPref,
  }) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  String _userId = '';
  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(
      () {
        _userId = (prefs.getString('userId') ?? '');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EC Student',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontSize: 14,
            height: 1.4,
            color: Colors.black87,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            height: 1.5,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            height: 1.2,
          ),
        ),
      ),
      home: _userId.isNotEmpty ? const MainScreen() : const SigninScreen(),
      builder: EasyLoading.init(),
    );
  }
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false;
}
