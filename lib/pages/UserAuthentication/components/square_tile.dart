import 'package:flutter/material.dart';

class SquareTile extends StatefulWidget {
  final String imagePath;
  final isDarkMode;
  const SquareTile({
    super.key,
    required this.imagePath,
    this.isDarkMode = false,
  });

  @override
  State<SquareTile> createState() => _SquareTileState();
}

class _SquareTileState extends State<SquareTile> {
  bool isDarkMode = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      height: 80,
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color.fromARGB(255, 6, 145, 170)
            : const Color.fromARGB(255, 4, 98, 114),
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Image.asset(widget.imagePath),
    );
  }
}
