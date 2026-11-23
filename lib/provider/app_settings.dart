import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {

  bool ecoMode = false;

  AppSettings() {
    loadSettings();
  }

  /// The theme shown on screen.
  ///
  /// The theme follows the mode and cannot be chosen by the user:
  ///   - Eco Mode    -> dark theme (dark pixels use less power
  ///                    on OLED screens)
  ///   - Normal Mode -> light theme
  /// Every screen reads `settings.darkTheme`, so this one getter
  /// switches the whole app.
  bool get darkTheme => ecoMode;

  Future<void> loadSettings() async {

    final prefs = await SharedPreferences.getInstance();

    ecoMode = prefs.getBool('ecoMode') ?? false;

    notifyListeners();
  }

  Future<void> toggleEcoMode(bool value) async {

    ecoMode = value;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      'ecoMode',
      value,
    );

    notifyListeners();
  }
}
