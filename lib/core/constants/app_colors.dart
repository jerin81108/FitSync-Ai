import 'package:flutter/material.dart';

/// FitSync AI Design System Colors
/// Curated palette: Deep teal & indigo primary, warm coral accent, soft neutrals.
class AppColors {
  // Brand Primaries
  static const Color deepTeal = Color(0xFF0F4C5C);
  static const Color deepTealLight = Color(0xFF1B6B80);
  static const Color indigo = Color(0xFF1A237E);
  static const Color indigoLight = Color(0xFF283593);

  // Accent Colors
  static const Color warmCoral = Color(0xFFFF6F59);
  static const Color warmCoralLight = Color(0xFFFF8B7A);
  static const Color mintAccent = Color(0xFF2EC4B6);
  static const Color softPeach = Color(0xFFFFE5D9);
  static const Color amberWarning = Color(0xFFFFB703);
  static const Color successGreen = Color(0xFF38B000);

  // Readiness Score Band Colors
  static const Color bandRest = Color(0xFF8E9AAF); // Calm Slate Gray
  static const Color bandLight = Color(0xFF2EC4B6); // Mint
  static const Color bandModerate = Color(0xFF3A86FF); // Electric Blue
  static const Color bandOptimal = Color(0xFF0F4C5C); // Deep Teal
  static const Color bandPeak = Color(0xFFFF6F59); // Warm Coral / Fire

  // Light Mode Surfaces
  static const Color lightBackground = Color(0xFFF7F9FB);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardBorder = Color(0xFFE9ECEF);
  static const Color lightTextPrimary = Color(0xFF121820);
  static const Color lightTextSecondary = Color(0xFF6C757D);
  static const Color lightTextMuted = Color(0xFF9E9E9E);

  // Dark Mode Surfaces
  static const Color darkBackground = Color(0xFF0B1017);
  static const Color darkCard = Color(0xFF131C26);
  static const Color darkCardBorder = Color(0xFF222F3E);
  static const Color darkTextPrimary = Color(0xFFF8F9FA);
  static const Color darkTextSecondary = Color(0xFFADB5BD);
  static const Color darkTextMuted = Color(0xFF6C757D);

  // Load Colors for Week Strip
  static const Color loadLight = Color(0xFF2EC4B6);
  static const Color loadMedium = Color(0xFFFFB703);
  static const Color loadHeavy = Color(0xFFFF6F59);
  static const Color loadExam = Color(0xFF8338EC); // Purple for Exam days

  /// Dynamic Readiness Color by score (0-100)
  static Color getReadinessColor(int score) {
    if (score < 40) return bandRest;
    if (score < 60) return bandLight;
    if (score < 80) return bandModerate;
    if (score <= 92) return bandOptimal;
    return bandPeak;
  }
}
