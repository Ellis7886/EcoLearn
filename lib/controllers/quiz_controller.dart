import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/quiz_service.dart';

class QuizController {

  Future<void> syncQuizzes() async {

    final snapshot = await FirebaseFirestore.instance
        .collection('quizzes')
        .get();

    final quizService = QuizService();

    await quizService.clearQuizzes();

    await quizService.clearQuestions();

    for (var doc in snapshot.docs) {

      final quiz =
      doc.data();

      await quizService.insertQuiz({

        'id': doc.id,

        'lesson_id': quiz['lesson_id'],

        'title': quiz['title'],

        'description': quiz['description'],
      });

      final questions = quiz['questions'] ?? [];

      print('Questions found:');
      print(questions);

      for (var question
      in questions) {

        await quizService.insertQuestion({

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
}