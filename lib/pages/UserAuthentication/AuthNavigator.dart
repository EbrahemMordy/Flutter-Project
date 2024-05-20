import 'package:flutter/material.dart';
import 'package:uni_project/pages/UserAuthentication/login_page.dart';
import 'package:uni_project/pages/UserAuthentication/register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async'; // Import dart:async to get the StreamSubscription class

class AuthNavigator extends StatefulWidget {
  const AuthNavigator({super.key});

  @override
  State<AuthNavigator> createState() => _AuthNavigatorState();
}

class _AuthNavigatorState extends State<AuthNavigator> {
  bool isLoginPage = true;
  late StreamSubscription<User?> authSubscription;

  @override
  void initState() {
    super.initState();
    authSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      // Modify this line
      if (user == null && mounted) {
        // Check if the widget is still in the tree
        setState(() {
          isLoginPage = true; // Reset to login page when user is signed out
        });
      }
    });
  }

  @override
  void dispose() {
    authSubscription.cancel(); // Cancel the subscription when the widget is disposed
    super.dispose();
  }

  // function to toggle between login and register pages
  void togglePage() {
    setState(() {
      isLoginPage = !isLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoginPage
        ? LoginPage(regButtonPressed: togglePage)
        : RegisterPage(loginButtonPressed: togglePage);
  }
}
