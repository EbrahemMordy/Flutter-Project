import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MyTextField extends StatefulWidget {
  final controller;
  final hintText;
  final obscureText;

  const MyTextField({
    super.key,
    this.controller,
    this.hintText,
    this.obscureText = false,
  });

  @override
  State<MyTextField> createState() => TextFieldState();
}

class TextFieldState extends State<MyTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.obscureText,
        decoration: InputDecoration(
          hintText: widget.hintText,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 6, 145, 170)),
          ),
          // fillColor: Colors.grey[100],
          fillColor: const Color.fromARGB(255, 192, 223, 235),
          filled: true,
        ),
      ),
    );
  }
}
