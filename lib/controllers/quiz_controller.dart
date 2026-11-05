import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../services/database_service.dart';
import '../services/quiz_service.dart';

class QuizController {
  final QuizService _quizService = QuizService();

  // ==================================================
  // Firestore -> SQLite (quizzes + questions)
  // CHANGED: one transaction + batch instead of
  // one database write per row
  // ==================================================
  Future<void> syncQuizzes() async {
    final snapshot =
    await FirebaseFirestore.instance.collection('quizzes').get();

    final db = await DatabaseService.instance.database;

    await db.transaction((txn) async {
      final batch = txn.batch();

      batch.delete('quizzes');
      batch.delete('quiz_questions');

      for (final doc in snapshot.docs) {
        final quiz = doc.data();

        batch.insert(
          'quizzes',
          {
            'id': doc.id,
            'lesson_id': quiz['lesson_id'],
            'title': quiz['title'],
            'description': quiz['description'],
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        final questions = (quiz['questions'] as List?) ?? [];

        for (final q in questions) {
          batch.insert('quiz_questions', {
            'quiz_id': doc.id,
            'question': q['question'],
            'option_a': q['option_a'],
            'option_b': q['option_b'],
            'option_c': q['option_c'],
            'option_d': q['option_d'],
            'correct_answer': q['correct_answer'],
          });
        }
      }

      await batch.commit(noResult: true);
    });
  }

  // (unchanged)
  Future<double> getAverageQuizPercentage(String userId) async {
    final results = await _quizService.getQuizResultsByUser(userId);
    if (results.isEmpty) return 0;

    double total = 0;
    for (final r in results) {
      total += (r['percentage'] as num).toDouble();
    }
    return total / results.length;
  }

  // ==================================================
  // SQLite -> Firestore (quiz results)
  // CHANGED: unique document ID, one batched upload,
  // includes mode
  // ==================================================
  Future<void> syncQuizResultsToFirestore() async {
    final results = await _quizService.getUnsyncedResults();

    if (results.isEmpty) {
      debugPrint('No unsynced quiz results.');
      return;
    }

    final firestore = FirebaseFirestore.instance;

    // Firestore allows max 500 writes per batch
    const chunkSize = 400;

    for (var i = 0; i < results.length; i += chunkSize) {
      final chunk = results.skip(i).take(chunkSize).toList();
      final batch = firestore.batch();

      for (final r in chunk) {
        // NEW: unique across users and devices.
        // Same result always gets the same ID, so a retry
        // overwrites itself instead of creating duplicates.
        final docId = '${r['user_id']}_${r['quiz_id']}_${r['completed_at']}'
            .replaceAll('/', '-'); // '/' is not allowed in IDs

        batch.set(
          firestore.collection('quiz_results').doc(docId),
          {
            'quiz_id': r['quiz_id'],
            'user_id': r['user_id'],
            'score': r['score'],
            'total_questions': r['total_questions'],
            'percentage': r['percentage'],
            'completed_at': r['completed_at'],
            'mode': r['mode'] ?? 'Unknown', // NEW
            'synced_at': FieldValue.serverTimestamp(), // NEW
          },
        );
      }

      try {
        await batch.commit(); // ONE network request

        final ids = chunk.map((r) => r['id'] as int).toList();
        await _quizService.markManyAsSynced(ids);

        debugPrint('Synced ${chunk.length} quiz results.');
      } catch (e) {
        // Batch is all-or-nothing: nothing was saved,
        // so all results stay unsynced and retry later.
        debugPrint('Quiz result batch sync failed: $e');
        rethrow; // lets SyncService log the failure
      }
    }
  }
}