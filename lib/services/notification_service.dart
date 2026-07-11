import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {

  static final FlutterLocalNotificationsPlugin
  notifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await notifications.initialize(
      settings,
    );

    await notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> showProgress(int progress,) async {
    await notifications.show(
      1,
      'Downloading...',
      '$progress%',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'download_progress_channel',
          'Downloads',
          channelDescription: 'Download progress',
          showProgress: true,
          maxProgress: 100,
          progress: progress,
          ongoing: true,
          playSound: false,
          enableVibration: false,
          importance: Importance.low,
          priority: Priority.low,
        ),
      ),
    );
  }

  static Future<void> showCompleted(String fileName,) async {
    await notifications.show(
      1,
      'Download Complete',
      fileName,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'download_channel',
          'Downloads',
        ),
      ),
    );
  }

  static Future<void> cancelNotification() async {
    await notifications.cancel(1);
  }
}