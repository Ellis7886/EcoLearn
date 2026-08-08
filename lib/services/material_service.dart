import 'package:sqflite/sqflite.dart';

import 'database_service.dart';

class MaterialService {

  Future insertMaterial(
      Map<String, dynamic> material) async {

    final db =
    await DatabaseService.instance.database;

    await db.insert(
      'materials',
      material,
      conflictAlgorithm:
      ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getMaterials() async {

    final db =
    await DatabaseService.instance.database;

    return await db.query(
      'materials',
    );
  }

  Future<Map<String, dynamic>?> getMaterialById(
      String id) async {

    final db =
    await DatabaseService.instance.database;

    final result = await db.query(
      'materials',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  // ========================================
  // Existing method
  // ========================================

  Future updateLocalPath(
      String id,
      String localPath) async {

    final db =
    await DatabaseService.instance.database;

    await db.update(
      'materials',
      {
        'local_path': localPath,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========================================
  // NEW:
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

  Future deleteMaterial(
      String id) async {

    final db =
    await DatabaseService.instance.database;

    await db.delete(
      'materials',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future deleteMaterialsByChapter(
      String chapterId) async {

    final db =
    await DatabaseService.instance.database;

    await db.delete(
      'materials',
      where: 'chapter_id = ?',
      whereArgs: [chapterId],
    );
  }

  Future clearMaterials() async {

    final db =
    await DatabaseService.instance.database;

    await db.delete(
      'materials',
    );
  }
}