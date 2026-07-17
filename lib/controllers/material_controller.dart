import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/material_service.dart';

class MaterialController {

  Future<void> syncMaterials() async {

    final snapshot = await FirebaseFirestore.instance
        .collection('content')
        .where('type', isEqualTo: 'material')
        .get();

    final materialService = MaterialService();

    for (var doc in snapshot.docs) {

      final material = doc.data();
      final existingMaterial = await materialService.getMaterialById(doc.id,);

      await materialService.insertMaterial({
        'id': doc.id,
        'lesson_id': material['lesson_id'],
        'title': material['title'],
        'file_name': material['file_name'],
        'chapter': material['chapter'],
        'file_type': material['file_type'],
        'firebase_url': material['file_url'],
        'local_path': existingMaterial?['local_path'] ?? '',
      });
    }
  }
}