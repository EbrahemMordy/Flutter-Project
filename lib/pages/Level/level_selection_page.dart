import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uni_project/pages/db/database.dart';
import 'package:uni_project/pages/Level/level_0_dashboard.dart';
import 'package:uni_project/pages/Level/level_1_dashboard.dart';

class LevelSelection extends StatefulWidget {
  const LevelSelection({super.key});

  @override
  State<LevelSelection> createState() => _LevelSelectionState();
}

class _LevelSelectionState extends State<LevelSelection> {
  Future<int> getUserLevel(String firebaseUid) async {
    print('Getting user level');
    print('FirebaseUid: $firebaseUid');

    final Database db = await DatabaseProvider().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'firebase_uid = ?',
      whereArgs: [firebaseUid],
    );
    print('User level: ${maps.first['current_level']}');
    if (maps.isNotEmpty) {
      return maps.first['current_level'];
    } else {
      return -2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: getUserLevel(FirebaseAuth.instance.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // If the future is not yet resolved
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        if (snapshot.data == -2) {
          return const Scaffold(
            body: Center(
              child: Text('User not found in the database, please sign up!'),
            ),
          );
        }

        // Navigate to the appropriate level page based on the user's level
        switch (snapshot.data) {
          case 0:
            return const Level0Dashboard();
          case 1:
            return const Level1Dashboard();
          default:
            return const LevelSelectionWidget();
        }
      },
    );
  }
}

class LevelSelectionWidget extends StatelessWidget {
  const LevelSelectionWidget({
    super.key,
  });

  // Function to set the user's level to 0 or 1 in the database
  void setUserLevel(int level) async {
    final Database db = await DatabaseProvider().database;
    await db.update(
      'users',
      {'current_level': level},
      where: 'firebase_uid = ?',
      whereArgs: [FirebaseAuth.instance.currentUser!.uid],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Level'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // Navigate to the login page after signing out
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/hand-drawn-young-man-illustrator-flat-style-design-set-stocks-people-creative-illustration-vector.jpg',
                // fit: BoxFit.cover,
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Image.asset(
                  'assets/logoPng.png',
                  width: 600,
                  height: 300,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(60),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Level 0 (Newcomers)',
                        style: TextStyle(fontSize: 20),
                      ),
                      onPressed: () {
                        setUserLevel(0);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Level0Dashboard(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Level 1',
                        style: TextStyle(fontSize: 20),
                      ),
                      onPressed: () {
                        setUserLevel(1);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Level1Dashboard(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
