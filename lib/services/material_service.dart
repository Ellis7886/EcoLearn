
import 'database_service.dart';

class MaterialService {

  Future<List<Map<String, dynamic>>> getMaterials() async {

    final db =
    await DatabaseService.instance.database;

    return await db.query(
      'materials',
    );
  }

  // ========================================
  // 
  // Update local file + mode
  // ========================================

  Future updateLocalMaterial(
      String id,
      String localPath,
      String localMode) async {

    final db =
    await DatabaseService.instance.database;

    await db.update(
      'materials',
      {
        'local_path': localPath,
        'local_mode': localMode,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getMaterialsByChapter(
      String chapterId) async {

    final db =
    await DatabaseService.instance.database;

    return await db.query(
      'materials',
      where: 'chapter_id = ?',
      whereArgs: [chapterId],
    );
  }
}