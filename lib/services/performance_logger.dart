import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PerformanceLogger {

  static Future<void> log({
    required String mode,
    required String operation,
    required int recordCount,
    required int loadTime,
  }) async {

    final dir = await getApplicationDocumentsDirectory();

    final file = File('${dir.path}/performance_log.csv');

    if (!await file.exists()) {

      await file.writeAsString(
        'timestamp,mode,operation,records,load_time_ms\n',
      );
    }

    final row =
        '${DateTime.now()},'
        '$mode,'
        '$operation,'
        '$recordCount,'
        '$loadTime\n';

    await file.writeAsString(
      row,
      mode: FileMode.append,
    );

    print('✅ CSV Updated');
    print('📄 ${file.path}');
    print('📝 $row');
  }
}