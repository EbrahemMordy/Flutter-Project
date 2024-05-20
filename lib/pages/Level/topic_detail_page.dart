import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uni_project/pages/db/database.dart';
import 'package:url_launcher/url_launcher.dart';

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
      final Map<String, dynamic> user =
          await DatabaseProvider().getUserByFirebaseUid(currentUserId);
      final int userId = user['user_id'];

      await DatabaseProvider().updateMaterialProgress(userId, materialId, isCompleted);

      // Refresh the materials list
      setState(() {
        _materialsFuture = fetchMaterials(widget.topicId);
      });
    } catch (e) {
      print('Error toggling material completion: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 15, 131, 226)),
          onPressed: () => Navigator.of(context).pop(),
        ),
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

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(material['material_name']),
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
      ),
    );
  }

  void openLink(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      await launchUrl(uri);
    } catch (e) {
      throw 'Could not launch $url';
    }
  }
}
