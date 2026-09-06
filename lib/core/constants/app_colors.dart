import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryNavy = Color(0xFF1A237E);
  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color turquoise = Color(0xFF00BCD4);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F7FA);
  static const Color cardShadow = Color(0x1A000000);
  static const Color purple = Color(0xFF7C4DFF);
  static const Color orange = Color(0xFFFF9800);
  static const Color teal = Color(0xFF009688);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, turquoise],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient navyGradient = LinearGradient(
    colors: [primaryNavy, Color(0xFF283593)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
