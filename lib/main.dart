import 'package:flutter/material.dart';
import 'package:uni_project/pages/UserAuthentication/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uni_project/pages/home_page.dart';
import 'firebase_options.dart';
import 'pages/UserAuthentication/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => const AuthPage(),
      '/login': (context) => const login_page(),
      '/home': (context) => const HomePage(),
    },
  ));
}
