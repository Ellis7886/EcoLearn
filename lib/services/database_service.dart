import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {

  static final DatabaseService instance =
  DatabaseService._init();

  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {

    if (_database != null) {
      return _database!;
    }

    _database = await _initDB();

    return _database!;
  }

  Future<Database> _initDB() async {

    final dbPath = await getDatabasesPath();

    final path = join(
      dbPath,
      'ecolearn.db',
    );

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(
      Database db,
      int version) async {

    await db.execute('''
      CREATE TABLE lessons(
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        course_code TEXT,
        progress REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE materials(
        id TEXT PRIMARY KEY,
        lesson_id TEXT,
        title TEXT,
        file_name TEXT,
        chapter TEXT,
        file_type TEXT,
        firebase_url TEXT,
        local_path TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE quizzes(
        id TEXT PRIMARY KEY,
        lesson_id TEXT,
        title TEXT,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE quiz_questions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        quiz_id TEXT,
        question TEXT,
        option_a TEXT,
        option_b TEXT,
        option_c TEXT,
        option_d TEXT,
        correct_answer TEXT
      )
    ''');
  }
}