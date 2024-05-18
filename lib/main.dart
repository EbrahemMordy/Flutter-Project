import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sqflite/sqflite.dart';
import 'firebase_options.dart';
import 'pages/splash_screen.dart';
import 'package:uni_project/pages/db/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize the database for the first time
  await DatabaseProvider().database;

  // test select query
  testUsersTable();
  testTopicsTable();
  testMaterialsTable();
  testProgressTable();

  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => const SplashScreen(),
    },
  ));
}

void testProgressTable() async {
  final Database db = await DatabaseProvider().database;
  db.query('progress').then((value) {
    print('Progress:');
    for (var progress in value) {
      print(progress);
    }
  });
}

void testUsersTable() async {
  final Database db = await DatabaseProvider().database;
  final List<Map<String, dynamic>> users = await db.query('users');
  print('Users:');
  for (var user in users) {
    print(user);
  }
}

void testTopicsTable() async {
  final Database db = await DatabaseProvider().database;
  final List<Map<String, dynamic>> topics = await db.query('topics');
  print('Topics:');
  for (var topic in topics) {
    print(topic);
  }
}

void testMaterialsTable() async {
  final Database db = await DatabaseProvider().database;
  final List<Map<String, dynamic>> materials = await db.query('materials');
  print('Materials:');
  for (var material in materials) {
    print(material);
  }
}
