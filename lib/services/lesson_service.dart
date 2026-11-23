
import 'database_service.dart';

class LessonService {

  Future<List<Map<String, dynamic>>> getLessons() async {
    final db = await DatabaseService.instance.database;

    return await db.query(
      'lessons',
      // Oldest first (ascending), same order as Normal Mode.
      // id is the tie-breaker, like Firestore's default.
      orderBy: 'created_at ASC, id ASC',
    );
  }
}