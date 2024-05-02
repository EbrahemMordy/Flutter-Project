import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uni_project/pages/home_page.dart';
import 'package:uni_project/pages/UserAuthentication/login_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // check if user is signed in
      builder: (context, snapshot) {
        // user is signed in
        if (snapshot.hasData) { // if user is signed in
          return const HomePage();
        }
        //  user is not signed in
        else { // if user is not signed in
          return const login_page();
        }
      },
    ));
  }
}
