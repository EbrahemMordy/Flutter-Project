import 'package:flutter/material.dart';

class Level1Dashboard extends StatefulWidget {
  const Level1Dashboard({super.key});

  @override
  State<Level1Dashboard> createState() => _Level1DashboardState();
}

class _Level1DashboardState extends State<Level1Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Level 1 Dashboard'),
        ),
        body: const Center(
          child: Text('Level 1 Dashboard'),
        ));
  }
}
