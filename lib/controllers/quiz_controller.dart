import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/quiz_service.dart';

class QuizController {

  final QuizService _quizService = QuizService();

  Future<void> syncQuizzes() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('quizzes')
        .get();

    await _quizService.clearQuizzes();
    await _quizService.clearQuestions();

    for (var doc in snapshot.docs) {

      final quiz = doc.data();

      await _quizService.insertQuiz({

        'id': doc.id,
        'lesson_id': quiz['lesson_id'],
        'title': quiz['title'],
        'description': quiz['description'],
      });

      final questions = quiz['questions'] ?? [];

      for (var question in questions) {

        await _quizService.insertQuestion({

          'quiz_id': doc.id,
          'question': question['question'],
          'option_a': question['option_a'],
          'option_b': question['option_b'],
          'option_c': question['option_c'],
          'option_d': question['option_d'],
          'correct_answer': question['correct_answer'],
        });
      }
    }
  }

  Future<double> getAverageQuizPercentage(
      String userId) async {

    final results =
    await _quizService.getQuizResultsByUser(userId);

    if (results.isEmpty) {
      return 0;
    }

    double total = 0;

    for (final result in results) {
      total +=
          (result['percentage'] as num).toDouble();
    }

    return total / results.length;
  }

  Future<void> syncQuizResultsToFirestore() async {
    final results =
    await _quizService.getUnsyncedResults();

    for (final result in results) {
      try {
        await FirebaseFirestore.instance
            .collection('quiz_results')
            .doc(result['id'].toString())
            .set({
          'quiz_id': result['quiz_id'],
          'user_id': result['user_id'],
          'score': result['score'],
          'total_questions': result['total_questions'],
          'percentage': result['percentage'],
          'completed_at': result['completed_at'],
        });

        await _quizService.markAsSynced(
          result['id'] as int,
        );

      } catch (e) {
        print(
          'Quiz result sync failed: $e',
        );
      }
    }
  }
}