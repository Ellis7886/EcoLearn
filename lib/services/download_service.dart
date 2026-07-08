import 'package:background_downloader/background_downloader.dart';

class DownloadService {

  Future<String> downloadFile(
      String url,
      String fileName,
      ) async {

    final task = DownloadTask(
      url: url,
      filename: fileName,
      directory: 'EcoLearn',
      updates: Updates.statusAndProgress,
    );

    await FileDownloader().enqueue(task);

    return task.taskId;
  }
}