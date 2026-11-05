import 'package:ecolearn/screens/splash_page.dart';
import 'package:flutter/foundation.dart'; // NEW: for kDebugMode
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'provider/app_settings.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'services/sync_service.dart';
// CHANGED: connectivity_service.dart import removed (it duplicated SyncService)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseService.instance.database;

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.initialize();

  // CHANGED: only ONE sync listener now.
  // ConnectivityService was also uploading quiz results on every
  // connectivity change, which doubled the network work.
  SyncService.instance.start();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppSettings(),
      child: const EcoLearnApp(),
    ),
  );
}

// NEW: page transition with no animation (used in Eco Mode)
class _NoTransition extends PageTransitionsBuilder {
  const _NoTransition();

  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    return child;
  }
}

class EcoLearnApp extends StatelessWidget {
  const EcoLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, settings, child) {
        // NEW: Eco Mode always uses dark theme (saves power on OLED screens)
        final useDark = settings.darkTheme || settings.ecoMode;

        return MaterialApp(
          debugShowCheckedModeBanner: false,

          // CHANGED: touch logger only runs in debug builds.
          // You still get coordinates for your test script while
          // developing, but release builds (used for measurement)
          // have no extra overhead.
          builder: (context, child) {
            if (!kDebugMode) return child!;
            return Listener(
              onPointerDown: (event) {
                debugPrint(
                  'TOUCH X=${event.position.dx} '
                      'Y=${event.position.dy}',
                );
              },
              child: child!,
            );
          },

          theme: ThemeData(
            brightness: useDark ? Brightness.dark : Brightness.light,

            // NEW: no page-transition animations in Eco Mode
            pageTransitionsTheme: settings.ecoMode
                ? const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: _NoTransition(),
                TargetPlatform.iOS: _NoTransition(),
              },
            )
                : const PageTransitionsTheme(),
          ),

          home: SplashPage(),
        );
      },
    );
  }
}