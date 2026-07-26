import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/database_service.dart';

class ChapterController {

  Future<List<Map<String, dynamic>>> syncChapters(
      String lessonId) async {

    final db = await DatabaseService.instance.database;

    final snapshot = await FirebaseFirestore.instance
        .collection('chapters')
        .where(
      'lesson_id',
      isEqualTo: lessonId,
    )
        .get();

    await db.delete(
      'chapters',
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
    );

    for (var doc in snapshot.docs) {

      final data = doc.data();

      await db.insert(
        'chapters',
        {
          'id': doc.id,
          'lesson_id': data['lesson_id'],
          'title': data['title'],
          'description': data['description'],
        },
      );
    }

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