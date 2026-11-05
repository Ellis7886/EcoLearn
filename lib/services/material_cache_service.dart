import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

import 'material_service.dart';

/// NEW: Eco Mode offline cache for learning materials.
///
/// The optimised file is downloaded ONCE from Firebase Storage,
/// stored in the app's private folder and its path is saved in
/// SQLite (materials.local_path). Next time it opens from the
/// phone with no network traffic, also when the phone is offline
/// (learning continuity).
class MaterialCacheService {

  final MaterialService _materialService = MaterialService();

  /// Returns the local file path if the file is already stored
  /// on the phone, otherwise null.
  Future<String?> getCachedPath(Map<String, dynamic> material) async {
    final localPath = (material['local_path'] ?? '').toString();

    if (localPath.isEmpty) return null;

    final file = File(localPath);
    if (await file.exists() && await file.length() > 0) {
      return localPath;
    }

    return null;
  }

  /// Returns the local path, downloading the optimised file
  /// first if needed.
  ///
  /// [downloaded] is set to true when a download happened
  /// (useful for the performance log).
  Future<({String path, bool downloaded})> getOrDownload(
      Map<String, dynamic> material,
      ) async {
    final cached = await getCachedPath(material);
    if (cached != null) {
      return (path: cached, downloaded: false);
    }

    final ecoPath = (material['eco_file_path'] ?? '').toString();
    if (ecoPath.isEmpty) {
      throw Exception('Optimised file is not available yet.');
    }

    final dir = await getApplicationSupportDirectory();
    final folder = Directory('${dir.path}/eco_materials');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    // Keep the original extension so the viewers know the type
    final fileName = ecoPath.split('/').last;
    final target = File('${folder.path}/${material['id']}_$fileName');
    final partial = File('${target.path}.part');

    // Download to a temporary file first so a broken download
    // is never treated as a complete file.
    await FirebaseStorage.instance.ref(ecoPath).writeToFile(partial);
    await partial.rename(target.path);

    await _materialService.updateLocalMaterial(
      material['id'].toString(),
      target.path,
      'Eco',
    );

    return (path: target.path, downloaded: true);
  }
}
