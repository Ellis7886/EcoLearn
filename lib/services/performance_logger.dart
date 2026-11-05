import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// One measurement in progress (see [PerformanceLogger.start]).
class PerfSession {
  final Stopwatch stopwatch;
  final int rxStart;
  final int txStart;

  PerfSession._(this.stopwatch, this.rxStart, this.txStart);
}

/// Writes one CSV row per measured operation:
///
/// timestamp, mode, operation, data_source, records,
/// load_time_ms, rx_bytes, tx_bytes, memory_rss_kb
///
/// - load_time_ms  : execution time of the operation
/// - rx/tx_bytes   : network bytes received/sent by THIS app
///                   during the operation (Android TrafficStats,
///                   -1 if not available)
/// - memory_rss_kb : app memory (resident set size) at the end
///
/// The file is saved in the app's external files folder so it
/// can be copied to the PC without root:
///
///   adb pull /sdcard/Android/data/com.ecolearn.ecolearn_app/files/performance_log_v2.csv
class PerformanceLogger {

  static const MethodChannel _channel =
  MethodChannel('ecolearn/metrics');

  static const String _fileName = 'performance_log_v2.csv';

  static const String _header =
      'timestamp,mode,operation,data_source,records,'
      'load_time_ms,rx_bytes,tx_bytes,memory_rss_kb\n';

  // Writes are queued so two rows never mix.
  static Future<void> _queue = Future.value();

  static File? _file;

  static Future<File> _getFile() async {
    if (_file != null) return _file!;

    Directory? dir;
    try {
      dir = await getExternalStorageDirectory();
    } catch (_) {
      dir = null;
    }
    dir ??= await getApplicationDocumentsDirectory();

    final file = File('${dir.path}/$_fileName');

    if (!await file.exists()) {
      await file.writeAsString(_header);
    }

    _file = file;
    return file;
  }

  static Future<List<int>> _trafficBytes() async {
    try {
      final result =
      await _channel.invokeMethod<List<dynamic>>('getTrafficBytes');

      if (result == null || result.length < 2) return [-1, -1];

      return [
        (result[0] as num).toInt(),
        (result[1] as num).toInt(),
      ];
    } catch (_) {
      return [-1, -1];
    }
  }

  /// Call before the operation starts.
  static Future<PerfSession> start() async {
    final traffic = await _trafficBytes();
    return PerfSession._(Stopwatch()..start(), traffic[0], traffic[1]);
  }

  /// Call when the operation has finished.
  static Future<void> finish(
      PerfSession session, {
        required String mode,
        required String operation,
        required String dataSource,
        int recordCount = 0,
      }) async {
    session.stopwatch.stop();

    final traffic = await _trafficBytes();

    final rx = (session.rxStart < 0 || traffic[0] < 0)
        ? -1
        : traffic[0] - session.rxStart;

    final tx = (session.txStart < 0 || traffic[1] < 0)
        ? -1
        : traffic[1] - session.txStart;

    await log(
      mode: mode,
      operation: operation,
      dataSource: dataSource,
      recordCount: recordCount,
      loadTime: session.stopwatch.elapsedMilliseconds,
      rxBytes: rx,
      txBytes: tx,
    );
  }

  /// Writes one row. Kept compatible with the old call style.
  static Future<void> log({
    required String mode,
    required String operation,
    required String dataSource,
    required int recordCount,
    required int loadTime,
    int rxBytes = -1,
    int txBytes = -1,
  }) {
    final memoryKb = ProcessInfo.currentRss ~/ 1024;

    final row =
        '${DateTime.now().toIso8601String()},'
        '$mode,'
        '$operation,'
        '$dataSource,'
        '$recordCount,'
        '$loadTime,'
        '$rxBytes,'
        '$txBytes,'
        '$memoryKb\n';

    _queue = _queue.then((_) async {
      try {
        final file = await _getFile();
        await file.writeAsString(row, mode: FileMode.append);
        debugPrint('PERF: $row');
      } catch (e) {
        debugPrint('PerformanceLogger failed: $e');
      }
    });

    return _queue;
  }
}
