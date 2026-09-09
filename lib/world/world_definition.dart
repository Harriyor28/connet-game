import 'package:flutter/material.dart';

/// Central visual and environment configuration for a puzzle world.
class WorldDefinition {
  final int id;
  final String name;
  final String environmentId;
  final String themeId;
  final WorldTheme theme;
  final String? unlockRequirement;
  final List<String> assetKeys;

  const WorldDefinition({
    required this.id,
    required this.name,
    required this.environmentId,
    required this.themeId,
    required this.theme,
    this.unlockRequirement,
    this.assetKeys = const [],
  });
}

/// Palette and effect settings consumed by the procedural environment.
class WorldTheme {
  final Color backgroundTop;
  final Color backgroundBottom;
  final Color boardTop;
  final Color boardBottom;
  final Color accent;
  final Color secondaryAccent;
  final Color particle;
  final double ambientParticleOpacity;

  const WorldTheme({
    required this.backgroundTop,
    required this.backgroundBottom,
    required this.boardTop,
    required this.boardBottom,
    required this.accent,
    required this.secondaryAccent,
    required this.particle,
    this.ambientParticleOpacity = 0.16,
  });

  static const neonLab = WorldTheme(
    backgroundTop: Color(0xff07101d),
    backgroundBottom: Color(0xff18283b),
    boardTop: Color(0xff193449),
    boardBottom: Color(0xff07111d),
    accent: Color(0xff4de8ff),
    secondaryAccent: Color(0xffff67d9),
    particle: Color(0xff9cf6ff),
    ambientParticleOpacity: 0.18,
  );

  static const placeholder = WorldTheme(
    backgroundTop: Color(0xff111827),
    backgroundBottom: Color(0xff273449),
    boardTop: Color(0xff31435a),
    boardBottom: Color(0xff111827),
    accent: Color(0xffa7c7ff),
    secondaryAccent: Color(0xffd1d5db),
    particle: Color(0xffdbeafe),
    ambientParticleOpacity: 0.10,
  );
}
