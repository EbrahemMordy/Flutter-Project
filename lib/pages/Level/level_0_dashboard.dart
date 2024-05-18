import 'package:flutter/material.dart';
import 'package:uni_project/pages/Level/level_selection_page.dart';
import 'package:uni_project/pages/db/database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uni_project/pages/topic_detail_page.dart';

class Level0Dashboard extends StatefulWidget {
  const Level0Dashboard({super.key});

  @override
  State<Level0Dashboard> createState() => _Level0DashboardState();
}

class _Level0DashboardState extends State<Level0Dashboard> {
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  Future<double> calculateOverallProgress() async {
    final Database db = await DatabaseProvider().database;
    final String currentUserId = auth.currentUser!.uid;

    final List<Map<String, dynamic>> userResult = await db.query(
      'users',
      where: 'firebase_uid = ?',
      whereArgs: [currentUserId],
    );
    if (userResult.isEmpty) {
      throw Exception("User not found in the database");
    }

    int userId = userResult.first['user_id'] as int;

    return await DatabaseProvider().getLevelProgress(0, userId);
  }

  Future<Map<String, Map<String, dynamic>>> fetchTopicProgress() async {
    final Database db = await DatabaseProvider().database;
    final String currentUserId = auth.currentUser!.uid;

    final List<Map<String, dynamic>> userResult = await db.query(
      'users',
      where: 'firebase_uid = ?',
      whereArgs: [currentUserId],
    );
    if (userResult.isEmpty) {
      throw Exception("User not found in the database");
    }

    int userId = userResult.first['user_id'] as int;

    final List<Map<String, dynamic>> topics = await db.query(
      'topics',
      where: 'level_id = ?',
      whereArgs: [0], // level 1 for Newcomers
    );

    Map<String, Map<String, dynamic>> topicProgressMap = {};
    for (var topic in topics) {
      String topicName = topic['topic_name'] as String;
      int topicId = topic['topic_id'] as int;
      double progress =
          await DatabaseProvider().getTopicProgress(topicId, userId);
      topicProgressMap[topicName] = {'topicId': topicId, 'progress': progress};
    }
    return topicProgressMap;
  }

  Future<int?> getTopicIdByName(String topicName) async {
    final Database db = await DatabaseProvider().database;
    final List<Map<String, dynamic>> topicResult = await db.query(
      'topics',
      where: 'topic_name = ?',
      whereArgs: [topicName],
    );
    if (topicResult.isNotEmpty) {
      return topicResult.first['topic_id'] as int;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Newcomers Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.change_circle),
            onPressed: () {
              // Navigate to the level selection page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const LevelSelectionWidget()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<double>(
        future: calculateOverallProgress(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            double overallProgress = snapshot.data ?? 0.0;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Keep going, you are doing great!',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 150,
                          width: 150,
                          child: CircularProgressIndicator(
                            value: overallProgress / 100,
                            strokeWidth: 10,
                            backgroundColor: Colors.grey.shade300,
                            color: Colors.blue,
                          ),
                        ),
                        Text(
                          '${overallProgress.toInt()}%',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: FutureBuilder<Map<String, Map<String, dynamic>>>(
                      future: fetchTopicProgress(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else {
                          Map<String, Map<String, dynamic>> topicProgressMap =
                              snapshot.data ?? {};

                          return ListView.builder(
                            itemCount: topicProgressMap.length,
                            itemBuilder: (context, index) {
                              String topic =
                                  topicProgressMap.keys.elementAt(index);
                              double topicProgress =
                                  topicProgressMap[topic]?['progress'];

                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  title: Text(topic),
                                  trailing: SizedBox(
                                    width: 60,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          value: topicProgress / 100,
                                          strokeWidth: 6,
                                          backgroundColor: Colors.grey.shade300,
                                          color: Colors.blue,
                                        ),
                                        Text('${topicProgress.toInt()}%'),
                                      ],
                                    ),
                                  ),
                                  onTap: () async {
                                    int? topicId =
                                        topicProgressMap[topic]?['topicId'];
                                    if (topicId != null) {
                                      // Navigate to the topic detail page
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TopicDetailPage(
                                            topic: topic,
                                            topicId: topicId,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
