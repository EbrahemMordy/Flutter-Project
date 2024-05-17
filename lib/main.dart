import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:uni_project/pages/UserAuthentication/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uni_project/pages/home_page.dart';
import 'firebase_options.dart';
import 'pages/UserAuthentication/login_page.dart';
import 'pages/splash_screen.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uni_project/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize the database for the first time
  initializeDatabase();
  
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => const SplashScreen(),
      '/auth': (context) => const AuthPage(),
      '/login': (context) => const login_page(),
      '/home': (context) => const HomePage(),
    },
  ));
}

void initializeDatabase() async {
  database = await openDatabase(
    join(await getDatabasesPath(), 'my_database.db'),
    onCreate: (db, version) {
      // Create the tables if they don't exist
      db.execute(
          'CREATE TABLE IF NOT EXISTS levels (level_id INTEGER PRIMARY KEY AUTOINCREMENT, level_name TEXT NOT NULL)');
      db.execute(
          'CREATE TABLE IF NOT EXISTS users (user_id INTEGER PRIMARY KEY AUTOINCREMENT, firebase_uid TEXT NOT NULL UNIQUE, current_level INTEGER NOT NULL, FOREIGN KEY (current_level) REFERENCES levels(level_id))');
      db.execute(
          'CREATE TABLE IF NOT EXISTS topics (topic_id INTEGER PRIMARY KEY AUTOINCREMENT, level_id INTEGER NOT NULL, topic_name TEXT NOT NULL, progress INTEGER DEFAULT 0, FOREIGN KEY (level_id) REFERENCES levels(level_id))');
      db.execute(
          'CREATE TABLE IF NOT EXISTS materials (material_id INTEGER PRIMARY KEY AUTOINCREMENT, topic_id INTEGER NOT NULL, material_type TEXT NOT NULL, material_link TEXT NOT NULL, FOREIGN KEY (topic_id) REFERENCES topics(topic_id))');
      db.execute(
          'CREATE TABLE IF NOT EXISTS user_progress (progress_id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, topic_id INTEGER NOT NULL, completed BOOLEAN NOT NULL DEFAULT FALSE, FOREIGN KEY (user_id) REFERENCES users(user_id), FOREIGN KEY (topic_id) REFERENCES topics(topic_id))');
    },
    version: 1,
  );
}
