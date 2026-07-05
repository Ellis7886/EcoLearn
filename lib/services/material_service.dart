import 'package:sqflite/sqflite.dart';

import 'database_service.dart';

class MaterialService {

  Future<void> insertMaterial(
      Map<String, dynamic> material) async {

    final db = await DatabaseService.instance.database;

    await db.insert(
      'materials',
      material,
      conflictAlgorithm:
      ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getMaterials() async {

    final db = await DatabaseService.instance.database;

    return await db.query('materials');
  }

  Future<Map<String, dynamic>?> getMaterialById(String id) async {

    final db = await DatabaseService.instance.database;

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

  Future<void> updateLocalPath(
      String id,
      String localPath) async {

    final db = await DatabaseService.instance.database;

    await db.update(
      'materials',
      {
        'local_path': localPath,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getMaterialsByLesson(String lessonId) async {

    final db = await DatabaseService.instance.database;

    return await db.query(
      'materials',
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
    );
  }

  Future<void> deleteMaterial(String id) async {
    final db = await DatabaseService.instance.database;

    await db.delete(
      'materials',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearMaterials() async {

    final db = await DatabaseService.instance.database;

    await db.delete(
      'materials',
    );
  }
}