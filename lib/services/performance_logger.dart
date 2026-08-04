import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PerformanceLogger {

  static Future<void> log({
    required String mode,
    required String operation,
    required String dataSource,
    required int recordCount,
    required int loadTime,
  }) async {

    final dir = await getApplicationDocumentsDirectory();

    final file = File('${dir.path}/performance_log.csv');

    if (!await file.exists()) {

      await file.writeAsString(
        'timestamp,mode,operation,data_source,records,load_time_ms\n',
      );
    }

    final row =
        '${DateTime.now()},'
        '$mode,'
        '$operation,'
        '$dataSource,'
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