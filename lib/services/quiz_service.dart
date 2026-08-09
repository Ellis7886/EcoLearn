import 'package:sqflite/sqflite.dart';

import 'database_service.dart';

class QuizService {

  Future<void> insertQuiz(
      Map<String, dynamic> quiz) async {

    final db = await DatabaseService.instance.database;

    await db.insert(
      'quizzes',
      quiz,
      conflictAlgorithm:
      ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>>
  getQuizzes() async {

    final db =
    await DatabaseService.instance.database;

    return await db.query('quizzes');
  }

  Future<void> clearQuizzes() async {

    final db =
    await DatabaseService.instance.database;

    await db.delete('quizzes');
  }

  // ==========================
  // Quiz Questions
  // ==========================

  Future<void> insertQuestion(
      Map<String, dynamic> question) async {

    final db =
    await DatabaseService.instance.database;

    await db.insert(
      'quiz_questions',
      question,
      conflictAlgorithm:
      ConflictAlgorithm.replace,
    );
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
    );
  }

  Future<void> clearQuestions() async {

    final db =
    await DatabaseService.instance.database;

    await db.delete(
      'quiz_questions',
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

  Future<List<Map<String, dynamic>>> getQuizResultsByUser(
      String userId) async {

    final db = await DatabaseService.instance.database;

    return await db.query(
      'quiz_results',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'completed_at DESC',
    );
  }

  Future<void> clearQuizResults() async {

    final db =
    await DatabaseService.instance.database;

    await db.delete(
      'quiz_results',
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

  Future<void> markAsSynced(int id) async {
    final db =
    await DatabaseService.instance.database;

    await db.update(
      'quiz_results',
      {
        'synced': 1,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}