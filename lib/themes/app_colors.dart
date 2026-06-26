import 'package:flutter/material.dart';

class AppColors {

  static Color background(bool darkTheme) {
    return darkTheme
        ? const Color(0xFF121212)
        : const Color(0xFFF5F5F5);
  }

  static Color card(bool darkTheme) {
    return darkTheme
        ? const Color(0xFF1E1E1E)
        : Colors.white;
  }

  static Color text(bool darkTheme) {
    return darkTheme
        ? Colors.white
        : const Color(0xFF212121);
  }

  static Color subText(bool darkTheme) {
    return darkTheme
        ? Colors.white70
        : const Color(0xFF323232);
  }

  // Main EcoLearn Green
  static const Color primary = Color(0xFF689F38);

  // Light green background for icons
  static Color primaryLight(bool darkTheme) {
    return darkTheme
        ? const Color(0xFF2E4A1F)
        : const Color(0xFFE8F5E9);
  }

  // Border color
  static Color border(bool darkTheme) {
    return darkTheme
        ? const Color(0xFF333333)
        : const Color(0xFFE0E0E0);
  }
}