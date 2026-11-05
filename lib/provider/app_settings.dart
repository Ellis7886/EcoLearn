import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {

  // The theme the user picked with the "Dark Theme" switch.
  bool _darkThemePreference = true;

  bool ecoMode = false;

  AppSettings() {
    loadSettings();
  }

  /// The theme the user chose (used to restore it when
  /// Eco Mode is turned off).
  bool get darkThemePreference => _darkThemePreference;

  /// The theme actually shown on screen.
  ///
  /// CHANGED: Eco Mode always uses the dark theme (dark pixels
  /// use less power on OLED screens). Every screen reads
  /// `settings.darkTheme`, so this one getter makes the whole
  /// app dark in Eco Mode - before, only MaterialApp switched
  /// and the screens stayed light.
  bool get darkTheme => _darkThemePreference || ecoMode;

  Future<void> loadSettings() async {

    final prefs = await SharedPreferences.getInstance();

    _darkThemePreference = prefs.getBool('darkTheme') ?? true;

    ecoMode = prefs.getBool('ecoMode') ?? false;

    notifyListeners();
  }

  Future<void> toggleDarkTheme(bool value) async {

    _darkThemePreference = value;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      'darkTheme',
      value,
    );

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
