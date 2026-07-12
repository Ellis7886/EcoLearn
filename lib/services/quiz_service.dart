import 'package:sqflite/sqflite.dart';

import 'database_service.dart';

class QuizService {

  Future<void> insertQuiz(
      Map<String, dynamic> quiz) async {

    final db =
    await DatabaseService.instance.database;

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
}