import 'package:ecolearn/screens/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'provider/app_settings.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseService.instance.database;

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppSettings(),
      child: const EcoLearnApp(),
    ),
  );
}

class EcoLearnApp extends StatelessWidget {
  const EcoLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, settings, child) {

        return MaterialApp(
          debugShowCheckedModeBanner: false,

          theme: ThemeData(
            brightness: settings.darkTheme ? Brightness.dark : Brightness.light,
          ),

          home: SplashPage(),
        );
      },
    );
  }
}