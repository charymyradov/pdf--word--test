import 'package:flutter/material.dart';

class AppColors {
  // Primary Blues - Eye-friendly palette
  static const Color primaryNavy = Color(0xFF1E3A5F);
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color lightBlue = Color(0xFFDBEAFE);
  static const Color softBlue = Color(0xFF93C5FD);
  
  // Accent Colors
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color skyBlue = Color(0xFF7DD3FC);
  
  // Status Colors - Softer tones
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  
  // Neutral Colors
  static const Color grey = Color(0xFF6B7280);
  static const Color lightGrey = Color(0xFFF3F4F6);
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8FAFC);
  static const Color cardShadow = Color(0x0A000000);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1E3A5F);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);

  // Gradients - Smooth blue transitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, accentBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient navyGradient = LinearGradient(
    colors: [primaryNavy, Color(0xFF2D5A87)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFEBF5FF), Color(0xFFDBEAFE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softGradient = LinearGradient(
    colors: [Color(0xFFF0F9FF), Color(0xFFE0F2FE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
