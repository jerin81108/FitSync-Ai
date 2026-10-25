import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Clean, accessible typography for FitSync AI
/// Uses Outfit for modern geometric warmth, scalable text, and high contrast.
class AppTypography {
  static TextStyle displayLarge(BuildContext context, {Color? color}) => GoogleFonts.outfit(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: color,
  );

  static TextStyle displayMedium(BuildContext context, {Color? color}) => GoogleFonts.outfit(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: color,
  );

  static TextStyle titleLarge(BuildContext context, {Color? color}) => GoogleFonts.outfit(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: color,
  );

  static TextStyle titleMedium(BuildContext context, {Color? color}) => GoogleFonts.outfit(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle bodyLarge(BuildContext context, {Color? color}) => GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: color,
  );

  static TextStyle bodyMedium(BuildContext context, {Color? color}) => GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.35,
    color: color,
  );

  static TextStyle labelLarge(BuildContext context, {Color? color}) => GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: color,
  );

  static TextStyle labelSmall(BuildContext context, {Color? color}) => GoogleFonts.outfit(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: color,
  );
}
