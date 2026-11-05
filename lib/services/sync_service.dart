import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart'; // NEW

import '../controllers/quiz_controller.dart';

class SyncService {
  static final SyncService instance = SyncService._internal();

  SyncService._internal();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // NEW: stops two syncs running at the same time
  bool _isSyncing = false;

  // NEW: connectivity often fires several events in a row
  // (e.g. Wi-Fi connecting, then validated). Wait briefly so
  // we only sync once.
  Timer? _debounce;

  void start() {
    // Avoid creating a second listener if start() is called twice
    _connectivitySubscription?.cancel();

    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((results) {
          final hasConnection =
          results.any((r) => r != ConnectivityResult.none);

          if (hasConnection) {
            debugPrint('Internet connection detected.');

            _debounce?.cancel();
            _debounce = Timer(
              const Duration(seconds: 3),
                  () => syncData(),
            );
          }
        });

    // NEW: also try once at app start, because the listener
    // may not fire if the device is already online.
    syncData();
  }

  /// [force] = true skips the Eco Mode Wi-Fi rule.
  /// Use it for user actions such as pull-to-refresh.
  Future<void> syncData({bool force = false}) async {
    if (_isSyncing) {
      debugPrint('Sync already running – skipped.');
      return;
    }

    _isSyncing = true;

    try {
      final results = await Connectivity().checkConnectivity();

      if (results.every((r) => r == ConnectivityResult.none)) {
        debugPrint('No connection – sync skipped.');
        return;
      }

      // NEW: Eco Mode = sync only on Wi-Fi (demand shaping)
      final prefs = await SharedPreferences.getInstance();
      final ecoMode = prefs.getBool('ecoMode') ?? false;

      if (ecoMode &&
          !force &&
          !results.contains(ConnectivityResult.wifi)) {
        debugPrint('Eco Mode: sync deferred until Wi-Fi.');
        return;
      }

      await QuizController().syncQuizResultsToFirestore();

      debugPrint('Quiz results synchronization completed.');
    } catch (e) {
      debugPrint('Synchronization failed: $e');
    } finally {
      // Runs even after the early "return"s above
      _isSyncing = false;
    }
  }

  void dispose() {
    _debounce?.cancel();
    _connectivitySubscription?.cancel();
  }
}