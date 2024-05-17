import 'package:flutter/material.dart';

class Level0Dashboard extends StatefulWidget {
  const Level0Dashboard({super.key});

  @override
  State<Level0Dashboard> createState() => _Level0DashboardState();
}

class _Level0DashboardState extends State<Level0Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Level 0 Dashboard'),
        ),
        body: const Center(
          child: Text('Level 0 Dashboard'),
        ));
  }
}
