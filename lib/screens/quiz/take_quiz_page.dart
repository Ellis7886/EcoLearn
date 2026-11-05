import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:provider/provider.dart';

import '../../provider/app_settings.dart';
import '../../services/performance_logger.dart';
import '../../services/quiz_service.dart';
import '../../services/sync_service.dart';

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

  // CHANGED: the quiz is loaded ONCE. Before, the Firestore
  // query was inside build(), so it ran again on every answer
  // tap.
  Future<Map<String, dynamic>?>? _quizFuture;
  bool? _ecoMode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_quizFuture != null) return;

    _ecoMode = Provider.of<AppSettings>(
      context,
      listen: false,
    ).ecoMode;

    _quizFuture = _loadQuiz(_ecoMode!);
  }

  /// Returns {title, description, questions} or null.
  Future<Map<String, dynamic>?> _loadQuiz(bool ecoMode) async {
    final session = await PerformanceLogger.start();

    Map<String, dynamic>? quiz;
    String source;

    if (ecoMode) {
      // NEW: Eco Mode reads the quiz from SQLite (works offline)
      source = 'SQLite';

      final row = await _quizService.getQuizById(widget.quizId);

      if (row != null) {
        final questions =
        await _quizService.getQuestionsByQuiz(widget.quizId);

        quiz = {
          'title': row['title'],
          'description': row['description'],
          'questions': questions,
        };
      }
    } else {
      final doc = await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.quizId)
          .get();

      source = doc.metadata.isFromCache
          ? 'Firestore (cache)'
          : 'Firestore (server)';

      if (doc.exists) {
        final data = doc.data()!;
        quiz = {
          'title': data['title'],
          'description': data['description'],
          'questions': List<Map<String, dynamic>>.from(
            ((data['questions'] as List?) ?? [])
                .map((q) => Map<String, dynamic>.from(q as Map)),
          ),
        };
      }
    }

    await PerformanceLogger.finish(
      session,
      mode: ecoMode ? 'Eco' : 'Normal',
      operation: 'Open Quiz',
      dataSource: source,
      recordCount: (quiz?['questions'] as List?)?.length ?? 0,
    );

    return quiz;
  }

  Future<void> submitQuiz(List questions) async {
    score = 0;

    for (int i = 0; i < questions.length; i++) {
      final correctAnswer = questions[i]['correct_answer'];

      if (selectedAnswers[i] == correctAnswer) {
        score++;
      }
    }

    // Save quiz result into SQLite (uploaded later by SyncService)
    await _quizService.insertQuizResult({
      'quiz_id': widget.quizId,
      'user_id': FirebaseAuth.instance.currentUser?.uid ?? '',
      'score': score,
      'total_questions': questions.length,
      'percentage': questions.isEmpty
          ? 0
          : (score / questions.length) * 100,
      'completed_at': DateTime.now().toIso8601String(),
      // FIXED: the mode is saved, so results can be compared
      // per mode (before, Firestore always got 'Unknown').
      'mode': (_ecoMode ?? false) ? 'Eco' : 'Normal',
      'synced': 0,
    });

    // NEW: try to upload straight away (SyncService applies
    // the Eco Mode Wi-Fi rule and skips when offline).
    SyncService.instance.syncData();

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

      body: FutureBuilder<Map<String, dynamic>?>(
        future: _quizFuture,
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

          if (snapshot.data == null) {
            return const Center(
              child: Text(
                'Quiz not found. Pull to refresh on the Quiz page '
                    'while online to download it.',
                textAlign: TextAlign.center,
              ),
            );
          }

          final quiz = snapshot.data!;

          final List questions =
              (quiz['questions'] as List?) ?? [];

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