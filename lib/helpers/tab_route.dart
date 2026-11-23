import 'package:flutter/material.dart';

/// NEW: route used by the bottom navigation bar.
///
/// Normal Mode: fade + slide (300 ms). The new page comes in from
/// the side of the tapped tab, so it follows the order of the tabs:
///   - tab to the LEFT  (e.g. Lessons -> Home)   : page moves to the right
///   - tab to the RIGHT (e.g. Home -> Lessons)   : page moves to the left
///   - same tab (e.g. Chapters -> Lessons)       : fade only
///
/// Eco Mode: no animation at all (instant page change, zero duration),
/// so no animation frames are drawn.
Route<T> tabRoute<T>({
  required Widget page,
  required bool ecoMode,
  required int fromIndex,
  required int toIndex,
}) {
  if (ecoMode) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }

  // -0.25 = starts a quarter screen to the left, 0.25 = to the right
  final double startX = toIndex < fromIndex
      ? -0.25
      : toIndex > fromIndex
          ? 0.25
          : 0.0;

  return PageRouteBuilder<T>(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );

      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(startX, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
