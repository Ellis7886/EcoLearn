import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/material_service.dart';

class MaterialController {

  Future<void> syncMaterials() async {

    final snapshot = await FirebaseFirestore.instance
        .collection('materials')
        .get();

    final materialService = MaterialService();

    for (var doc in snapshot.docs) {

      final material = doc.data();

      final existingMaterial =
      await materialService.getMaterialById(doc.id);

      await materialService.insertMaterial({
        'id': doc.id,
        'chapter_id': material['chapter_id'],
        'title': material['title'],
        'description': material['description'],
        'type': material['type'],
        'file_name': material['file_name'],
        'file_url': material['file_url'],
        'local_path': existingMaterial?['local_path'] ?? '',
      });
    }
  }
}