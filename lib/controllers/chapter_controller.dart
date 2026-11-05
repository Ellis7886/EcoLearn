import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';

import '../services/database_service.dart';

class ChapterController {

  /// Firestore -> SQLite for one lesson.
  /// CHANGED: one transaction + batch instead of one write per row.
  Future<List<Map<String, dynamic>>> syncChapters(
      String lessonId) async {

    final snapshot = await FirebaseFirestore.instance
        .collection('chapters')
        .where(
      'lesson_id',
      isEqualTo: lessonId,
    )
        .get();

    final db = await DatabaseService.instance.database;

    await db.transaction((txn) async {
      final batch = txn.batch();

      batch.delete(
        'chapters',
        where: 'lesson_id = ?',
        whereArgs: [lessonId],
      );

      for (final doc in snapshot.docs) {
        final data = doc.data();

        batch.insert(
          'chapters',
          {
            'id': doc.id,
            'lesson_id': data['lesson_id'],
            'title': data['title'],
            'description': data['description'],
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    });

    return getSQLiteChapters(lessonId);
  }

  Future<List<Map<String, dynamic>>> getSQLiteChapters(
      String lessonId) async {

    final db = await DatabaseService.instance.database;

    return await db.query(
      'chapters',
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
    );
  }
}
