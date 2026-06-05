import 'package:flutter/material.dart';

class AppColors {

  static Color background(bool darkTheme) {
    return darkTheme
        ? Colors.black
        : Colors.white;
  }

  static Color card(bool darkTheme) {
    return darkTheme
        ? const Color(0xFF2B2B2B)
        : const Color(0xFFF2F2F2);
  }

  static Color text(bool darkTheme) {
    return darkTheme
        ? Colors.white
        : Colors.black;
  }

  static Color subText(bool darkTheme) {
    return darkTheme
        ? Colors.white70
        : Colors.black54;
  }

  static const Color primary =
  Color(0xFF9BD028);
}