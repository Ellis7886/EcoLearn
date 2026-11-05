import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();

  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ecolearn.db');

    return await openDatabase(
      path,
      version: 14, // CHANGED: was 13
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  // ==================================================
  // FRESH INSTALL – must contain EVERYTHING
  // ==================================================
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE lessons(
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        course_code TEXT,
        progress REAL,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE chapters(
        id TEXT PRIMARY KEY,
        lesson_id TEXT,
        title TEXT,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE materials(
        id TEXT PRIMARY KEY,
        chapter_id TEXT,
        title TEXT,
        description TEXT,
        type TEXT,
        file_name TEXT,
        file_url TEXT,
        eco_file_path TEXT,
        eco_url TEXT,          -- NEW: cached download URL
        local_path TEXT,
        local_mode TEXT
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

    await db.execute('''
      CREATE TABLE quiz_results(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        quiz_id TEXT,
        user_id TEXT,
        score INTEGER,
        total_questions INTEGER,
        percentage REAL,
        completed_at TEXT,
        mode TEXT,             -- NEW: 'Eco' or 'Normal'
        synced INTEGER DEFAULT 0
      )
    ''');

    await _createV14Tables(db); // NEW
  }

  // ==================================================
  // UPGRADE EXISTING INSTALL
  // ==================================================
  Future<void> _upgradeDB(
      Database db,
      int oldVersion,
      int newVersion,
      ) async {
    if (oldVersion < 10) {
      await _addColumnIfMissing(db, 'materials', 'local_mode', 'TEXT');
    }

    if (oldVersion < 11) {
      await _addColumnIfMissing(db, 'materials', 'eco_file_path', 'TEXT');
    }

    if (oldVersion < 13) {
      await _addColumnIfMissing(db, 'lessons', 'created_at', 'TEXT');
    }

    if (oldVersion < 14) {
      await _addColumnIfMissing(db, 'materials', 'eco_url', 'TEXT');
      await _addColumnIfMissing(db, 'quiz_results', 'mode', 'TEXT');
      await _createV14Tables(db);
    }
  }

  // ==================================================
  // NEW TABLES (shared by create + upgrade)
  // ==================================================
  Future<void> _createV14Tables(Database db) async {
    // Per-user learning progress (learning continuity)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS lesson_progress(
        user_id TEXT,
        material_id TEXT,
        lesson_id TEXT,
        completed_at TEXT,
        PRIMARY KEY(user_id, material_id)
      )
    ''');

    // Usability study event log
    await db.execute('''
      CREATE TABLE IF NOT EXISTS usability_log(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT,
        mode TEXT,
        task TEXT,
        event TEXT,
        timestamp TEXT
      )
    ''');
  }

  // ==================================================
  // HELPER: avoids "duplicate column" crash
  // ==================================================
  Future<void> _addColumnIfMissing(
      Database db,
      String table,
      String column,
      String type,
      ) async {
    final info = await db.rawQuery('PRAGMA table_info($table)');
    final exists = info.any((c) => c['name'] == column);

    if (!exists) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $type');
    }
  }
}