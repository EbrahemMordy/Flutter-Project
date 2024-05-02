import "package:flutter/material.dart";
import 'package:uni_project/pages/UserAuthentication/login_page.dart';
import 'package:uni_project/pages/UserAuthentication/register_page.dart';

class AuthNavigator extends StatefulWidget {
  const AuthNavigator({super.key});

  @override
  State<AuthNavigator> createState() => _AuthNavigatorState();
}

class _AuthNavigatorState extends State<AuthNavigator> {
  bool isLoginPage = true;

  // function to toggle between login and register pages
  void togglePage() {
    setState(() {
      isLoginPage = !isLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoginPage) {
      return login_page(
        regButonPressed: togglePage,
      );
    } else {
      return RegisterPage(
        loginButonPressed: togglePage,
      );
    }
  }
}
