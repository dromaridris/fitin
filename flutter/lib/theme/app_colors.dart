import 'package:flutter/material.dart';

/// Brand palette for FITIN by LARC (London Aesthetics & Rejuvenation Centre).
///
/// Values are sampled directly from the official LARC logo
/// (black background, gold monogram/wordmark, white sub-text)
/// so the app's visual identity matches the brand asset exactly.
class AppColors {
  AppColors._();

  // --- Core brand colors (sampled from the logo) ---
  static const Color black = Color(0xFF000000);
  static const Color gold = Color(0xFFCFB555); // primary gold, from logo
  static const Color goldLight = Color(0xFFE6D89A); // highlight / hover
  static const Color goldDark = Color(0xFFA6883D); // pressed / shadow
  static const Color white = Color(0xFFFFFFFF);

  // --- Surfaces ---
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF121212);
  static const Color surfaceElevated = Color(0xFF1C1C1C);
  static const Color surfaceBorder = Color(0xFF2A2A2A);

  // --- Text ---
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8B8B8);
  static const Color textMuted = Color(0xFF7A7A7A);
  static const Color textOnGold = Color(0xFF000000);

  // --- Semantic ---
  static const Color success = Color(0xFF4CAF7D);
  static const Color error = Color(0xFFE0554F);
  static const Color warning = Color(0xFFD9A441);

  // --- Gradients ---
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldLight, gold, goldDark],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF161616), Color(0xFF000000)],
  );
}
