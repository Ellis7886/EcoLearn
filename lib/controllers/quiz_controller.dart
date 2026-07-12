import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/quiz_service.dart';

class QuizController {

  Future<void> syncQuizzes() async {

    final snapshot =
    await FirebaseFirestore.instance
        .collection('quizzes')
        .get();

    final quizService =
    QuizService();

    await quizService.clearQuizzes();

    for (var doc in snapshot.docs) {

      final quiz =
      doc.data();

      await quizService.insertQuiz({

        'id': doc.id,

        'lesson_id':
        quiz['lesson_id'],

        'title':
        quiz['title'],

        'description':
        quiz['description'],
      });
    }
  }
}