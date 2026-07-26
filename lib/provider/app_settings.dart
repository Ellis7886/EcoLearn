import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {

  bool darkTheme = true;
  bool ecoMode = false;

  AppSettings() {
    loadSettings();
  }

  Future<void> loadSettings() async {

    final prefs = await SharedPreferences.getInstance();

    darkTheme = prefs.getBool('darkTheme') ?? true;

    ecoMode = prefs.getBool('ecoMode') ?? false;

    notifyListeners();
  }

  Future<void> toggleDarkTheme(bool value) async {

    darkTheme = value;

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