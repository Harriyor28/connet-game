import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Backgrounds
  static const Color backgroundDark = Color(0xFF0A0E1A);
  static const Color backgroundMedium = Color(0xFF121832);
  static const Color backgroundLight = Color(0xFF1A2340);
  static const Color surfaceDark = Color(0xFF0D1224);

  // Primary - Neon Cyan
  static const Color primaryCyan = Color(0xFF00E5FF);
  static const Color primaryCyanLight = Color(0xFF6EFFFF);
  static const Color primaryCyanDark = Color(0xFF00B2CC);
  static const Color primaryCyanGlow = Color(0x6600E5FF);

  // Secondary - Magenta
  static const Color secondaryMagenta = Color(0xFFFF00E5);
  static const Color secondaryMagentaLight = Color(0xFFFF66F0);
  static const Color secondaryMagentaDark = Color(0xFFCC00B8);
  static const Color secondaryMagentaGlow = Color(0x66FF00E5);

  // Accent - Gold
  static const Color accentGold = Color(0xFFFFD700);
  static const Color accentGoldLight = Color(0xFFFFE44D);
  static const Color accentGoldDark = Color(0xFFCCAB00);

  // State Colors
  static const Color success = Color(0xFF00FF88);
  static const Color error = Color(0xFFFF3366);
  static const Color warning = Color(0xFFFFAA00);
  static const Color inactive = Color(0xFF2A3055);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B8D4);
  static const Color textMuted = Color(0xFF5A6388);

  // Node Colors
  static const Color nodeNormal = primaryCyan;
  static const Color nodeActive = Color(0xFF00FFAA);
  static const Color nodeConnected = secondaryMagenta;
  static const Color nodeInvalid = error;
  static const Color nodeBonus = accentGold;
  static const Color nodeLocked = Color(0xFF4A4A6A);

  // Connection Colors
  static const Color connectionDefault = primaryCyan;
  static const Color connectionActive = Color(0xFF00FFCC);
  static const Color connectionPreview = Color(0x8800E5FF);
  static const Color connectionInvalid = Color(0x88FF3366);

  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundDark, backgroundMedium, backgroundLight],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryCyan, primaryCyanLight],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryCyan, secondaryMagenta],
  );

  static const RadialGradient nodeGlowGradient = RadialGradient(
    colors: [primaryCyanGlow, Colors.transparent],
  );
}
