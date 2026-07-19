import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Base
  static const Color background = Color(0xFF090B12);
  static const Color surface = Color(0xFF171923);
  static const Color surfaceLight = Color(0xFF232638);

  // Brand
  static const Color primary = Color(0xFF8B5CF6);
  static const Color primaryDark = Color(0xFF5B21B6);
  static const Color primaryLight = Color(0xFFC4B5FD);

  // Text
  static const Color textPrimary = Color(0xFFF5F3FF);
  static const Color textSecondary = Color(0xFFB8B5C7);
  static const Color textMuted = Color(0xFF7E7A91);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Borders
  static const Color border = Color(0xFF303344);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFA855F7), Color(0xFF6D28D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF070910), Color(0xFF1A1035), Color(0xFF090B12)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
