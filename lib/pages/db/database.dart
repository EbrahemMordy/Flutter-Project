import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseProvider {
  static final DatabaseProvider _instance = DatabaseProvider._internal();
  factory DatabaseProvider() => _instance;
  DatabaseProvider._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'my_database.db'),
      onCreate: _onCreate,
      version: 1,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS levels (
        level_id INTEGER PRIMARY KEY AUTOINCREMENT,
        level_name TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        user_id INTEGER PRIMARY KEY AUTOINCREMENT,
        firebase_uid TEXT NOT NULL UNIQUE,
        current_level INTEGER NOT NULL,
        FOREIGN KEY (current_level) REFERENCES levels(level_id)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS topics (
        topic_id INTEGER PRIMARY KEY AUTOINCREMENT,
        level_id INTEGER NOT NULL,
        topic_name TEXT NOT NULL,
        FOREIGN KEY (level_id) REFERENCES levels(level_id)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS materials (
        material_id INTEGER PRIMARY KEY AUTOINCREMENT,
        material_name TEXT NOT NULL,
        topic_id INTEGER NOT NULL,
        material_type TEXT NOT NULL,
        material_link TEXT NOT NULL,
        FOREIGN KEY (topic_id) REFERENCES topics(topic_id)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS progress (
        progress_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        topic_id INTEGER NOT NULL,
        material_id INTEGER,
        progress INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(user_id),
        FOREIGN KEY (topic_id) REFERENCES topics(topic_id),
        FOREIGN KEY (material_id) REFERENCES materials(material_id)
      )
    ''');

    await _insertLevelsTopicsAndMaterials(db);
  }

  Future<void> _insertLevelsTopicsAndMaterials(Database db) async {
    final List<Map<String, dynamic>> levels = [
      {'level_id': 0, 'level_name': 'Level 1'},
      {'level_id': 1, 'level_name': 'Level 2'},
    ];
    for (Map<String, dynamic> level in levels) {
      await db.insert(
        'levels',
        level,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    final List<Map<String, dynamic>> levelResults = await db.query('levels');
    Map<String, int> levelMap = {
      for (var level in levelResults)
        level['level_name'] as String: level['level_id'] as int
    };

    final List<String> levelOneTopics = [
      'Data Types & Conditions',
      'Loops',
      'Array',
      'Functions',
      'String',
      'Frequency array',
      'Basic Math'
    ];
    final List<String> levelTwoTopics = [
      'Cumulative sum',
      'STL',
      'Binary Search',
      'Two pointers',
      'Bitmasks',
      'Number Theory',
    ];

    for (String topic in levelOneTopics) {
      await db.insert(
        'topics',
        {'level_id': levelMap['Level 1'], 'topic_name': topic},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    for (String topic in levelTwoTopics) {
      await db.insert(
        'topics',
        {'level_id': levelMap['Level 2'], 'topic_name': topic},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    final List<Map<String, dynamic>> topicResults = await db.query('topics');
    for (var topic in topicResults) {
      print('Inserted topic: $topic');
    }

    final List<Map<String, dynamic>> levelZeroMaterials = [
      {
        'topic_name': 'Data Types & Conditions',
        'material_name': 'Resource 1',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Data Types & Conditions',
        'material_name': 'Resource 2',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Data Types & Conditions',
        'material_name': 'Resource 3',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Data Types & Conditions',
        'material_name': 'Problem 1',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Data Types & Conditions',
        'material_name': 'Problem 2',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Data Types & Conditions',
        'material_name': 'Problem 3',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },

      // Second Topic: Loops
      {
        'topic_name': 'Loops',
        'material_name': 'Resource 1',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Loops',
        'material_name': 'Resource 2',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Loops',
        'material_name': 'Resource 3',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Loops',
        'material_name': 'Problem 1',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Loops',
        'material_name': 'Problem 2',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Loops',
        'material_name': 'Problem 3',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },

      // 3: Array
      {
        'topic_name': 'Array',
        'material_name': 'Resource 1',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Array',
        'material_name': 'Resource 2',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Array',
        'material_name': 'Resource 3',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Array',
        'material_name': 'Problem 1',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Array',
        'material_name': 'Problem 2',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Array',
        'material_name': 'Problem 3',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },

      // 4: Functions
      {
        'topic_name': 'Functions',
        'material_name': 'Resource 1',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Functions',
        'material_name': 'Resource 2',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Functions',
        'material_name': 'Resource 3',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Functions',
        'material_name': 'Problem 1',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Functions',
        'material_name': 'Problem 2',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Functions',
        'material_name': 'Problem 3',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },

      // String
      {
        'topic_name': 'String',
        'material_name': 'Resource 1',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'String',
        'material_name': 'Resource 2',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'String',
        'material_name': 'Resource 3',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'String',
        'material_name': 'Problem 1',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'String',
        'material_name': 'Problem 2',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'String',
        'material_name': 'Problem 3',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },

      // Frequency array
      {
        'topic_name': 'Frequency array',
        'material_name': 'Resource 1',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Frequency array',
        'material_name': 'Resource 2',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Frequency array',
        'material_name': 'Resource 3',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Frequency array',
        'material_name': 'Problem 1',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Frequency array',
        'material_name': 'Problem 2',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Frequency array',
        'material_name': 'Problem 3',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },

      // Basic Math
      {
        'topic_name': 'Basic Math',
        'material_name': 'Resource 1',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Basic Math',
        'material_name': 'Resource 2',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Basic Math',
        'material_name': 'Resource 3',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Basic Math',
        'material_name': 'Problem 1',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Basic Math',
        'material_name': 'Problem 2',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Basic Math',
        'material_name': 'Problem 3',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },
    ];

    for (var material in levelZeroMaterials) {
      final topicResult = await db.query(
        'topics',
        columns: ['topic_id'],
        where: 'topic_name = ? AND level_id = ?',
        whereArgs: [material['topic_name'], levelMap['Level 1']],
      );
      if (topicResult.isNotEmpty) {
        final topicId = topicResult.first['topic_id'] as int;
        await db.insert(
          'materials',
          {
            'topic_id': topicId,
            'material_name': material['material_name'],
            'material_type': material['material_type'],
            'material_link': material['material_link'],
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
        print('Inserted material for topic_id $topicId: $material');
      } else {
        print('Topic not found for material: $material');
      }
    }

    final List<Map<String, dynamic>> levelOneMaterials = [
      // 1: Cumulative sum
      {
        'topic_name': 'Cumulative sum',
        'material_name': 'Resource 1',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Cumulative sum',
        'material_name': 'Resource 2',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Cumulative sum',
        'material_name': 'Resource 3',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Cumulative sum',
        'material_name': 'Problem 1',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Cumulative sum',
        'material_name': 'Problem 2',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Cumulative sum',
        'material_name': 'Problem 3',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },

      // STL
      {
        'topic_name': 'STL',
        'material_name': 'Resource 1',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'STL',
        'material_name': 'Resource 2',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'STL',
        'material_name': 'Resource 3',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'STL',
        'material_name': 'Problem 1',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'STL',
        'material_name': 'Problem 2',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'STL',
        'material_name': 'Problem 3',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },

      // Binary Search
      {
        'topic_name': 'Binary Search',
        'material_name': 'Resource 1',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Binary Search',
        'material_name': 'Resource 2',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Binary Search',
        'material_name': 'Resource 3',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Binary Search',
        'material_name': 'Problem 1',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Binary Search',
        'material_name': 'Problem 2',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Binary Search',
        'material_name': 'Problem 3',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },

      // Two pointers
      {
        'topic_name': 'Two pointers',
        'material_name': 'Resource 1',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Two pointers',
        'material_name': 'Resource 2',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Two pointers',
        'material_name': 'Resource 3',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Two pointers',
        'material_name': 'Problem 1',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Two pointers',
        'material_name': 'Problem 2',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Two pointers',
        'material_name': 'Problem 3',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },

      // Bitmasks
      {
        'topic_name': 'Bitmasks',
        'material_name': 'Resource 1',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Bitmasks',
        'material_name': 'Resource 2',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Bitmasks',
        'material_name': 'Resource 3',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Bitmasks',
        'material_name': 'Problem 1',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Bitmasks',
        'material_name': 'Problem 2',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Bitmasks',
        'material_name': 'Problem 3',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },

      // Number Theory
      {
        'topic_name': 'Number Theory',
        'material_name': 'Resource 1',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Number Theory',
        'material_name': 'Resource 2',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Number Theory',
        'material_name': 'Resource 3',
        'material_type': 'resource',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Number Theory',
        'material_name': 'Problem 1',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Number Theory',
        'material_name': 'Problem 2',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },
      {
        'topic_name': 'Number Theory',
        'material_name': 'Problem 3',
        'material_type': 'problem',
        'material_link': 'https://google.com'
      },
    ];

    for (var material in levelOneMaterials) {
      final topicResult = await db.query(
        'topics',
        columns: ['topic_id'],
        where: 'topic_name = ? AND level_id = ?',
        whereArgs: [material['topic_name'], levelMap['Level 2']],
      );
      if (topicResult.isNotEmpty) {
        final topicId = topicResult.first['topic_id'] as int;
        await db.insert(
          'materials',
          {
            'topic_id': topicId,
            'material_name': material['material_name'],
            'material_type': material['material_type'],
            'material_link': material['material_link'],
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
        print('Inserted material for topic_id $topicId: $material');
      } else {
        print('Topic not found for material: $material');
      }
    }

    final List<Map<String, dynamic>> materialResults = await db.query('materials');
    for (var material in materialResults) {
      print('Inserted material: $material');
    }
  }

  Future<List<Map<String, dynamic>>> getMaterials(int topicId) async {
    final db = await database;
    return await db.query(
      'materials',
      where: 'topic_id = ?',
      whereArgs: [topicId],
    );
  }

  Future<double> getLevelProgress(int levelId, int userId) async {
    final db = await database;

    List<Map<String, dynamic>> topics =
        await db.query('topics', where: 'level_id = ?', whereArgs: [levelId]);

    int topicsDone = 0;
    int topicsNum = topics.length;

    for (var topic in topics) {
      double topicProgress = await getTopicProgress(topic['topic_id'], userId);

      if (topicProgress == 100) topicsDone++;
    }

    if (topicsNum == 0) return 0.0;
    return (topicsDone / topicsNum) * 100;
  }

  Future<double> getTopicProgress(int topicId, int userId) async {
    final db = await database;

    final totalMaterialsResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM materials WHERE topic_id = ?',
      [topicId],
    );

    final completedMaterialsResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM progress WHERE topic_id = ? AND user_id = ? AND progress = 100',
      [topicId, userId],
    );

    int totalMaterials = totalMaterialsResult.first['total'] as int;
    int completedMaterials = completedMaterialsResult.first['total'] as int;

    if (totalMaterials == 0) return 0.0;
    return (completedMaterials / totalMaterials) * 100;
  }

  Future<Map<String, dynamic>> getUserByFirebaseUid(String firebaseUid) async {
    final db = await database;
    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'firebase_uid = ?',
      whereArgs: [firebaseUid],
    );
    if (users.isNotEmpty) {
      print('User found: ${users.first}');
      return users.first;
    } else {
      print('User not found for firebase UID: $firebaseUid');
      throw Exception('User not found');
    }
  }

  Future<List<Map<String, dynamic>>> getMaterialProgress(
      int userId, int materialId) async {
    final db = await database;
    return await db.query(
      'progress',
      where: 'user_id = ? AND material_id = ?',
      whereArgs: [userId, materialId],
    );
  }

  Future<List<Map<String, dynamic>>> getMaterialsWithProgress(
      int topicId, String firebaseUid) async {
    final db = await database;
    final userResult = await db.query(
      'users',
      where: 'firebase_uid = ?',
      whereArgs: [firebaseUid],
    );
    if (userResult.isEmpty) {
      throw Exception('User not found');
    }
    final userId = userResult.first['user_id'] as int;

    final result = await db.rawQuery('''
      SELECT m.*, 
             p.progress as material_progress 
        FROM materials m 
             LEFT JOIN progress p 
               ON m.material_id = p.material_id 
              AND p.user_id = ? 
       WHERE m.topic_id = ?
    ''', [userId, topicId]);

    return result;
  }

  Future<void> updateMaterialProgress(
      int userId, int materialId, bool isCompleted) async {
    final db = await database;

    List<Map<String, dynamic>> materialProgress =
        await getMaterialProgress(userId, materialId);
    final topicIdResult = await db.query(
      'materials',
      columns: ['topic_id'],
      where: 'material_id = ?',
      whereArgs: [materialId],
    );
    print('Material Progress before update: $materialProgress');

    final topicId = topicIdResult.first['topic_id'] as int;

    if (isCompleted) {
      if (materialProgress.isEmpty) {
        // Insert if it doesn't exist
        if (topicIdResult.isNotEmpty) {
          await db.insert(
            'progress',
            {
              'user_id': userId,
              'topic_id': topicId,
              'material_id': materialId,
              'progress': 100,
            },
          );
        }
      } else {
        // Update if it exists
        await db.update(
          'progress',
          {'progress': 100},
          where: 'user_id = ? AND material_id = ?',
          whereArgs: [userId, materialId],
        );
      }
    } else {
      if (materialProgress.isNotEmpty) {
        // Remove if it exists and mark as not done
        await db.delete(
          'progress',
          where: 'user_id = ? AND material_id = ?',
          whereArgs: [userId, materialId],
        );
      }
    }

    materialProgress = await getMaterialProgress(userId, materialId);

    print('Material Progress after update: $materialProgress');
  }

  Future<void> initializeMaterialsProgress(String firebaseUid) async {
    final db = await database;
    final userResult = await db.query(
      'users',
      where: 'firebase_uid = ?',
      whereArgs: [firebaseUid],
    );
    if (userResult.isEmpty) {
      throw Exception('User not found');
    }
    final userId = userResult.first['user_id'] as int;

    final materials = await db.query('materials');

    // Initialize progress for all materials
    // This will help us to calculate the overall progress for each topic and each level
    for (var material in materials) {
      await db.insert(
        'progress',
        {
          'user_id': userId,
          'topic_id': material['topic_id'],
          'material_id': material['material_id'],
          'progress': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }
}
