import 'dart:io';

import 'package:dio/dio.dart';

class FileService {

  Future<String> downloadFile(
      String url,
      String fileName) async {

    try {

      print('START DOWNLOAD');
      print('URL: $url');

      final directory =
      Directory('/storage/emulated/0/EcoLearn');

      if (!await directory.exists()) {

        await directory.create(
          recursive: true,
        );
      }

      final savePath =
          '${directory.path}/$fileName';

      print('SAVE PATH: $savePath');

      await Dio().download(
        url,
        savePath,
      );

      print('DOWNLOAD COMPLETE');
      print('FILE SAVED TO: $savePath');

      return savePath;

    } catch (e) {

      print('DOWNLOAD FAILED');
      print(e);

      rethrow;
    }
  }
}