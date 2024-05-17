import 'package:flutter/material.dart';
import 'package:uni_project/pages/UserAuthentication/components/my_text_field.dart';
import 'package:uni_project/pages/UserAuthentication/components/my_button.dart';
import 'package:uni_project/pages/UserAuthentication/components/square_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uni_project/database.dart';

class RegisterPage extends StatefulWidget {
  final Function? loginButonPressed;
  const RegisterPage({super.key, this.loginButonPressed});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void signUserUp() async {
    // Show a loading dialog

    print("Register button pressed");

    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // create a new user
    try {
      // before creating a new user, check if the password is the same
      if (passwordController.text != confirmPasswordController.text) {
        Navigator.pop(context); // close the loading dialog
        showErrorMessage("Passwords do not match");
        return;
      } else {
        // create a new user
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        Navigator.pop(context);

        // Insert the new user's information into the SQLite database
        if (database != null) {
          await database!.insert(
            'users',
            {'firebase_uid': userCredential.user?.uid, 'current_level': -1},
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        } else {
          print("Database is null");
        }
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      showErrorMessage("${e.code}: ${e.message}");
    }
  }

  // generic error dialog
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

                // TODO: Add a logo here
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/avatar.jpg'),
                ),
                const SizedBox(height: 25),

                // TODO: welcome message
                const Text(
                  'Welcome Student!, Please Register to continue.',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 22, 20, 20),
                  ),
                ),

                // TODO: username input
                const SizedBox(height: 30),
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                // TODO: password input
                const SizedBox(height: 20),
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                // Confirm password
                const SizedBox(height: 20),
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),

                // TODO: login button
                const SizedBox(height: 15),
                MyButton(
                  onTap: signUserUp,
                  text: 'Register',
                ),

                // TODO: Continue with Google and X buttons
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
                // Buttons
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // google button
                    SquareTile(imagePath: 'assets/Google__G__logo.svg.png'),
                    SizedBox(width: 50),
                    // x button
                    SquareTile(
                        imagePath: 'assets/1690643640twitter-x-icon-png.webp')
                  ],
                ),

                // TODO: Login button
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
                        print("Login button pressed");
                        widget.loginButonPressed!();
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
