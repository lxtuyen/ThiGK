import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:giua_ky/firebase_options.dart';
import 'package:giua_ky/presentation/screens/home/home_screen.dart';
import 'package:giua_ky/presentation/screens/login/login.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
