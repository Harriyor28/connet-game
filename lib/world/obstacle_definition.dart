import 'dart:math' as math;
import 'package:flutter/material.dart';

enum ObstacleType {
  staticBlocker,
  movingBlocker,
  rotatingBlocker,
  energyBarrier,
}

/// Normalized obstacle definition used by both rendering and collision checks.
class ObstacleDefinition {
  final String id;
  final ObstacleType type;
  final Rect bounds;
  final bool isBlocking;
  final Duration movementPeriod;
  final double rotationRadians;

  const ObstacleDefinition({
    required this.id,
    required this.type,
    required this.bounds,
    this.isBlocking = true,
    this.movementPeriod = const Duration(seconds: 3),
    this.rotationRadians = 0,
  });

  factory ObstacleDefinition.fromJson(Map<String, dynamic> json) {
    final rawBounds = json['bounds'] as List<dynamic>?;
    final bounds = rawBounds != null && rawBounds.length == 4
        ? Rect.fromLTRB(
            (rawBounds[0] as num).toDouble(),
            (rawBounds[1] as num).toDouble(),
            (rawBounds[2] as num).toDouble(),
            (rawBounds[3] as num).toDouble(),
          )
        : const Rect.fromLTRB(.42, .35, .58, .65);
    final type = ObstacleType.values.firstWhere(
      (value) => value.name == json['type'],
      orElse: () => ObstacleType.staticBlocker,
    );
    return ObstacleDefinition(
      id: json['id'] as String? ?? 'obstacle_static',
      type: type,
      bounds: bounds,
      isBlocking: json['isBlocking'] as bool? ?? true,
    );
  }

  factory ObstacleDefinition.staticBlocker({
    Rect bounds = const Rect.fromLTRB(.42, .35, .58, .65),
  }) => ObstacleDefinition(
    id: 'obstacle_static',
    type: ObstacleType.staticBlocker,
    bounds: bounds,
  );

  factory ObstacleDefinition.movingBlocker({
    Rect bounds = const Rect.fromLTRB(.35, .45, .65, .55),
  }) => ObstacleDefinition(
    id: 'obstacle_moving',
    type: ObstacleType.movingBlocker,
    bounds: bounds,
  );

  factory ObstacleDefinition.rotatingBlocker({
    Rect bounds = const Rect.fromLTRB(.40, .40, .60, .60),
  }) => ObstacleDefinition(
    id: 'obstacle_rotating',
    type: ObstacleType.rotatingBlocker,
    bounds: bounds,
  );

  factory ObstacleDefinition.energyBarrier({
    Rect bounds = const Rect.fromLTRB(.48, .20, .52, .80),
  }) => ObstacleDefinition(
    id: 'obstacle_energy_barrier',
    type: ObstacleType.energyBarrier,
    bounds: bounds,
  );

  Rect boundsAt(Duration elapsed) {
    if (type != ObstacleType.movingBlocker) return bounds;
    final phase =
        (elapsed.inMilliseconds % movementPeriod.inMilliseconds) /
        movementPeriod.inMilliseconds;
    final offset = math.sin(phase * math.pi * 2) * 0.12;
    return bounds.shift(Offset(offset, 0));
  }

  /// Segment-vs-rectangle collision in normalized board coordinates.
  bool blocksSegment(
    Offset start,
    Offset end, {
    Duration elapsed = Duration.zero,
  }) {
    if (!isBlocking) return false;
    final rect = boundsAt(elapsed);
    final delta = end - start;
    const steps = 64;
    for (var i = 0; i <= steps; i++) {
      final point = start + delta * (i / steps);
      if (rect.contains(point)) return true;
    }
    return false;
  }
}
