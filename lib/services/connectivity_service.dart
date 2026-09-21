import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../controllers/quiz_controller.dart';

class ConnectivityService {

  StreamSubscription<List<ConnectivityResult>>?
  _subscription;

  void start() {

    _subscription =
        Connectivity()
            .onConnectivityChanged
            .listen((results) async {

          final hasInternet =
              results.contains(
                ConnectivityResult.wifi,
              ) ||
                  results.contains(
                    ConnectivityResult.mobile,
                  );

          if (hasInternet) {

            await QuizController()
                .syncQuizResultsToFirestore();
          }
        });
  }

  void dispose() {
    _subscription?.cancel();
  }
}