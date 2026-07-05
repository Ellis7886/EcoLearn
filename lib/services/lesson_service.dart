import 'package:sqflite/sqflite.dart';

import 'database_service.dart';

class LessonService {

  Future<void> insertLesson(
      Map<String, dynamic> lesson) async {

    final db = await DatabaseService.instance.database;

    await db.insert(
      'lessons',
      lesson,
      conflictAlgorithm:
      ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>>
  getLessons() async {

    final db = await DatabaseService.instance.database;

    return await db.query('lessons');
  }

  Future<void> clearLessons() async {

    final db = await DatabaseService.instance.database;

    await db.delete('lessons');
  }
}