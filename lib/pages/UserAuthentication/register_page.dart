import 'package:flutter/material.dart';
import 'package:uni_project/pages/UserAuthentication/components/my_text_field.dart';
import 'package:uni_project/pages/UserAuthentication/components/my_button.dart';
import 'package:uni_project/pages/UserAuthentication/components/square_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uni_project/pages/db/database.dart';

class RegisterPage extends StatefulWidget {
  final Function? loginButtonPressed;
  const RegisterPage({super.key, this.loginButtonPressed});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void signUserUp() async {
    final Database database = await DatabaseProvider().database;

    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      if (passwordController.text != confirmPasswordController.text) {
        Navigator.pop(context);
        showErrorMessage("Passwords do not match");
        return;
      } else {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        Navigator.pop(context);

        await database.insert(
          'users',
          {'firebase_uid': userCredential.user?.uid, 'current_level': -1},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Add all materials to the progress table for this specific user
        await DatabaseProvider()
            .initializeMaterialsProgress(userCredential.user!.uid);

      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      showErrorMessage("${e.code}: ${e.message}");
    }
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              'Error',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
          content: Text(
            'An error occurred: $message',
            style: const TextStyle(
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ),
          ],
          backgroundColor: const Color.fromARGB(255, 217, 238, 255),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 159, 215, 241),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 30),
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/avatar.jpg'),
                ),
                const SizedBox(height: 25),
                const Text(
                  'Welcome Student!, Please Register to continue.',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 22, 20, 20),
                  ),
                ),
                const SizedBox(height: 30),
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),
                const SizedBox(height: 20),
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),
                const SizedBox(height: 15),
                MyButton(
                  onTap: signUserUp,
                  text: 'Register',
                ),
                const SizedBox(height: 30),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or continue with',
                          style:
                              TextStyle(color: Color.fromARGB(255, 46, 46, 46)),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SquareTile(imagePath: 'assets/Google__G__logo.svg.png'),
                    SizedBox(width: 50),
                    SquareTile(
                        imagePath: 'assets/1690643640twitter-x-icon-png.webp')
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(
                        color: Color.fromARGB(255, 43, 42, 42),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (widget.loginButtonPressed != null) {
                          widget.loginButtonPressed!();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 7),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
