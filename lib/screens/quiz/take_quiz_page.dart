import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../provider/app_settings.dart';

import '../../controllers/quiz_controller.dart';

import '../../services/quiz_service.dart';

class TakeQuizPage extends StatefulWidget {

  final String quizId;

  const TakeQuizPage({
    super.key,
    required this.quizId,
  });

  @override
  State<TakeQuizPage> createState() => _TakeQuizPageState();
}

class _TakeQuizPageState extends State<TakeQuizPage> {
  final QuizService _quizService = QuizService();

  Map<int, String> selectedAnswers = {};

  int score = 0;

  Future<void> submitQuiz(List questions) async {

    score = 0;

    for (int i = 0; i < questions.length; i++) {

      final correctAnswer = questions[i]['correct_answer'];

      if (selectedAnswers[i] == correctAnswer) {
        score++;
      }
    }

    // Save quiz result into SQLite
    await _quizService.insertQuizResult({

      'quiz_id': widget.quizId,

      'user_id':
      FirebaseAuth.instance.currentUser?.uid ?? '',

      'score': score,

      'total_questions': questions.length,

      'percentage':
      (score / questions.length) * 100,

      'completed_at':
      DateTime.now().toIso8601String(),

      'synced': 0,

    });

    final settings = Provider.of<AppSettings>(
      context,
      listen: false,
    );

    if (!settings.ecoMode) {

      final quizController =
      QuizController();

      await quizController
          .syncQuizResultsToFirestore();

    }



    if (!mounted) return;

    showDialog(
      context: context,

      builder: (_) => AlertDialog(

        title: const Text(
          'Quiz Result',
        ),

        content: Text(
          'Your Score: '
              '$score / ${questions.length}',
        ),

        actions: [

          TextButton(
            onPressed: () {

              Navigator.pop(context);
              Navigator.pop(context);

            },

            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Take Quiz',
        ),
      ),

      body: FutureBuilder<DocumentSnapshot>(
        future:
        FirebaseFirestore.instance
            .collection('quizzes')
            .doc(widget.quizId)
            .get(),

        builder: (
            context,
            snapshot,
            ) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              !snapshot.data!.exists) {

            return const Center(
              child: Text(
                'Quiz not found',
              ),
            );
          }

          final quiz =
          snapshot.data!.data()
          as Map<String, dynamic>;

          final questions =
              quiz['questions'] ?? [];

          return SingleChildScrollView(
            padding:
            const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  quiz['title'] ?? '',
                  style:
                  const TextStyle(
                    fontSize: 24,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Text(
                  quiz['description']
                      ?? '',
                ),

                const SizedBox(
                  height: 30,
                ),

                ...List.generate(
                  questions.length,
                      (index) {

                    final question =
                    questions[index];

                    return Card(
                      margin:
                      const EdgeInsets.only(
                        bottom: 20,
                      ),

                      child: Padding(
                        padding:
                        const EdgeInsets.all(
                          16,
                        ),

                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                          children: [

                            Text(
                              'Question ${index + 1}',
                              style:
                              const TextStyle(
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            Text(
                              question['question']
                                  ?? '',
                            ),

                            const SizedBox(
                              height: 15,
                            ),

                            RadioListTile<String>(
                              value: 'A',
                              groupValue:
                              selectedAnswers[index],

                              title: Text(
                                question['option_a']
                                    ?? '',
                              ),

                              onChanged:
                                  (value) {

                                setState(() {

                                  selectedAnswers[
                                  index] =
                                  value!;
                                });
                              },
                            ),

                            RadioListTile<String>(
                              value: 'B',
                              groupValue:
                              selectedAnswers[index],

                              title: Text(
                                question['option_b']
                                    ?? '',
                              ),

                              onChanged:
                                  (value) {

                                setState(() {

                                  selectedAnswers[
                                  index] =
                                  value!;
                                });
                              },
                            ),

                            RadioListTile<String>(
                              value: 'C',
                              groupValue:
                              selectedAnswers[index],

                              title: Text(
                                question['option_c']
                                    ?? '',
                              ),

                              onChanged:
                                  (value) {

                                setState(() {

                                  selectedAnswers[
                                  index] =
                                  value!;
                                });
                              },
                            ),

                            RadioListTile<String>(
                              value: 'D',
                              groupValue:
                              selectedAnswers[index],

                              title: Text(
                                question['option_d']
                                    ?? '',
                              ),

                              onChanged:
                                  (value) {

                                setState(() {

                                  selectedAnswers[
                                  index] =
                                  value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    onPressed: () {

                      submitQuiz(
                        questions,
                      );
                    },

                    child: const Text(
                      'SUBMIT QUIZ',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}