import 'package:flutter/material.dart';

class AppSettings extends ChangeNotifier {

  bool darkTheme = true;
  bool ecoMode = true;

  void toggleDarkTheme(bool value){
    darkTheme = value;
    notifyListeners();
  }

  void toggleEcoMode(bool value){
    ecoMode = value;
    notifyListeners();
  }
}