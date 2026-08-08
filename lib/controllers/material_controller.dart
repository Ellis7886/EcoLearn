import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/material_service.dart';

class MaterialController {
  final MaterialService _materialService = MaterialService();

  /// Sync materials from Firestore to SQLite
  Future<List<Map<String, dynamic>>> syncMaterials(
      String chapterId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('materials')
        .where('chapter_id', isEqualTo: chapterId)
        .get();

    // Keep existing local_path and local_mode
    final existingMaterials =
    await _materialService.getMaterialsByChapter(chapterId);

    Map<String, String> localPaths = {};
    Map<String, String> localModes = {};

    for (final item in existingMaterials) {
      localPaths[item['id']] =
          item['local_path'] ?? '';

      localModes[item['id']] =
          item['local_mode'] ?? '';
    }

    // Delete old records
    await _materialService.deleteMaterialsByChapter(
      chapterId,
    );

    // Insert latest records
    for (var doc in snapshot.docs) {
      final material = doc.data();

      await _materialService.insertMaterial({
        'id': doc.id,
        'chapter_id': material['chapter_id'],
        'title': material['title'],
        'description': material['description'],
        'type': material['type'],
        'file_name': material['file_name'],
        'file_url': material['file_url'],
        'eco_file_path':
        material['eco_file_path'] ?? '',
        'local_path':
        localPaths[doc.id] ?? '',
        'local_mode':
        localModes[doc.id] ?? '',
      });
    }

    return await _materialService
        .getMaterialsByChapter(chapterId);
  }

  /// Load materials from SQLite only
  Future<List<Map<String, dynamic>>> getSQLiteMaterials(
      String chapterId) async {
    return await _materialService
        .getMaterialsByChapter(chapterId);
  }
}