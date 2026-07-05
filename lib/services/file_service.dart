import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import 'package:media_store_plus/media_store_plus.dart';

class FileService {

  Future<String> downloadFile(
      String url,
      String fileName) async {

    try {

      print('1 - START DOWNLOAD');
      print('URL: $url');

      print('2 - MediaStore init');
      await MediaStore.ensureInitialized();

      print('3 - Set app folder');
      MediaStore.appFolder = "EcoLearn";

      print('4 - Get temp directory');
      final tempDir =
      await getTemporaryDirectory();

      print('5 - Build temp path');
      final tempPath =
          '${tempDir.path}/$fileName';

      print(tempPath);

      print('6 - Start Dio download');
      await Dio().download(
        url,
        tempPath,
      );

      print('7 - TEMP DOWNLOAD COMPLETE');

      final mediaStore = MediaStore();

      print('8 - Save to Downloads');

      final result =
      await mediaStore.saveFile(
        tempFilePath: tempPath,
        dirType: DirType.download,
        dirName: DirName.download,
      );

      print('9 - SaveFile returned');
      print(result);

      if (result == null) {
        throw Exception(
          'Failed to save file to Downloads',
        );
      }

      print('10 - Saved to Downloads');
      print(result.uri);

      print('11 - Get file path from URI');

      final savedPath =
      await mediaStore.getFilePathFromUri(
        uriString: result.uri.toString(),
      );

      print('12 - File path returned');
      print(savedPath);

      if (savedPath == null) {
        throw Exception(
          'Cannot get saved file path',
        );
      }

      print('13 - COMPLETE');

      return savedPath;

    } catch (e, stackTrace) {

      print('DOWNLOAD FAILED');
      print(e);
      print(stackTrace);

      rethrow;
    }
  }
}