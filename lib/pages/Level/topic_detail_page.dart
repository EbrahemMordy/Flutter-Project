import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uni_project/pages/db/database.dart';

class TopicDetailPage extends StatefulWidget {
  final String topic;
  final int topicId;

  const TopicDetailPage({required this.topic, required this.topicId, super.key});

  @override
  State<TopicDetailPage> createState() {
    return _TopicDetailPageState();
  }
}

class _TopicDetailPageState extends State<TopicDetailPage> {
  late Future<List<Map<String, dynamic>>> _materialsFuture;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _materialsFuture = fetchMaterials(widget.topicId);
  }

  Future<List<Map<String, dynamic>>> fetchMaterials(int topicId) async {
    return await DatabaseProvider()
        .getMaterialsWithProgress(topicId, auth.currentUser!.uid);
  }

  Future<void> _toggleMaterialCompletion(int materialId, bool isCompleted) async {
    try {
      final String currentUserId = auth.currentUser!.uid;
      print('Toggling material completion for material $materialId');
      final Map<String, dynamic> user =
          await DatabaseProvider().getUserByFirebaseUid(currentUserId);
      final int userId = user['user_id']; // Ensure this matches your database schema

      print('User ID: $userId');
      print("Current User ID: $currentUserId");

      // Update material progress
      await DatabaseProvider().updateMaterialProgress(userId, materialId, isCompleted);

      // Recalculate overall progress and topic progress
      await updateProgress();

      setState(() {
        _materialsFuture = fetchMaterials(widget.topicId);
      });
    } catch (e) {
      print('Error toggling material completion: $e');
      // Handle the error, e.g., show a Snackbar or Dialog
    }
  }

  Future<void> updateProgress() async {
    // Recalculate and update the progress in the parent widget or globally
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _materialsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final materials = snapshot.data ?? [];

            final resources = materials
                .where((material) => material['material_type'] == 'resource')
                .toList();
            final problems = materials
                .where((material) => material['material_type'] == 'problem')
                .toList();

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  const Text(
                    'Resources',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ...resources.map((material) => MaterialTile(
                        material: material,
                        icon: Icons.video_library,
                        onToggleCompletion: _toggleMaterialCompletion,
                      )),
                  const SizedBox(height: 20),
                  const Text(
                    'Problems',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ...problems.map((material) => MaterialTile(
                        material: material,
                        icon: Icons.assignment,
                        onToggleCompletion: _toggleMaterialCompletion,
                      )),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class MaterialTile extends StatelessWidget {
  final Map<String, dynamic> material;
  final IconData icon;
  final Future<void> Function(int materialId, bool isCompleted) onToggleCompletion;

  const MaterialTile({
    required this.material,
    required this.icon,
    required this.onToggleCompletion,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = material['material_progress'] == 100;

    return ListTile(
      leading: Icon(icon),
      title: Text(material['material_link']),
      trailing: Checkbox(
        value: isCompleted,
        onChanged: (bool? value) {
          if (value != null) {
            onToggleCompletion(material['material_id'], value);
          }
        },
      ),
      onTap: () {
        openLink(material['material_link']);
      },
    );
  }

  void openLink(material) {
    print('Opening link: $material');
  }
}
