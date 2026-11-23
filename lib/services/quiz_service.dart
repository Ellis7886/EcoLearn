import 'package:sqflite/sqflite.dart';

import 'database_service.dart';

class QuizService {

  Future<List<Map<String, dynamic>>>
  getQuizzes() async {

    final db =
    await DatabaseService.instance.database;

    return await db.query('quizzes');
  }

  // Used by Take Quiz in Eco Mode (offline)
  Future<Map<String, dynamic>?> getQuizById(String id) async {
    final db = await DatabaseService.instance.database;

    final result = await db.query(
      'quizzes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    return result.isEmpty ? null : result.first;
  }

  Future<List<Map<String, dynamic>>>
  getQuestionsByQuiz(
      String quizId) async {

    final db =
    await DatabaseService.instance.database;

    return await db.query(
      'quiz_questions',
      where: 'quiz_id = ?',
      whereArgs: [quizId],
      orderBy: 'id ASC',
    );
  }

  // ==========================
  // Quiz Results
  // ==========================

  Future<void> insertQuizResult(
      Map<String, dynamic> result,
      ) async {
    final db =
    await DatabaseService.instance.database;

    await db.insert(
      'quiz_results',
      result,
      conflictAlgorithm:
      ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getQuizResults() async {

    final db = await DatabaseService.instance.database;

    return await db.query(
      'quiz_results',
      orderBy: 'completed_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getQuizResultsByQuiz(String quizId) async {

    final db =
    await DatabaseService.instance.database;

    return await db.query(
      'quiz_results',
      where: 'quiz_id = ?',
      whereArgs: [quizId],
      orderBy: 'completed_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getUnsyncedResults() async {
    final db =
    await DatabaseService.instance.database;

    return await db.query(
      'quiz_results',
      where: 'synced = ?',
      whereArgs: [0],
      orderBy: 'completed_at ASC',
    );
  }

  Future<void> markManyAsSynced(List<int> ids) async {
    if (ids.isEmpty) return;

    final db = await DatabaseService.instance.database;
    final placeholders = List.filled(ids.length, '?').join(',');

    await db.rawUpdate(
      'UPDATE quiz_results SET synced = 1 WHERE id IN ($placeholders)',
      ids,
    );
  }
}