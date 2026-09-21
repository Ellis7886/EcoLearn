import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../controllers/quiz_controller.dart';

class SyncService {

  static final SyncService instance =
  SyncService._internal();

  SyncService._internal();

  StreamSubscription<List<ConnectivityResult>>?
  _connectivitySubscription;

  void start() {

    _connectivitySubscription =
        Connectivity()
            .onConnectivityChanged
            .listen((results) {

          final hasConnection =
          results.any(
                (result) =>
            result != ConnectivityResult.none,
          );

          if (hasConnection) {

            debugPrint(
              'Internet connection detected.',
            );

            syncData();
          }
        });
  }

  Future<void> syncData() async {

    try {

      final quizController =
      QuizController();

      await quizController
          .syncQuizResultsToFirestore();

      debugPrint(
        'Quiz results synchronization completed.',
      );

    } catch (e) {

      debugPrint(
        'Synchronization failed: $e',
      );
    }
  }

  void dispose() {

    _connectivitySubscription?.cancel();
  }
}