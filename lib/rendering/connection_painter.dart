import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:nexus_link/core/constants/app_colors.dart';
import 'package:nexus_link/core/constants/app_dimensions.dart';

/// Custom painter that renders a 3D-styled glowing connection cable.
class ConnectionPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final bool isLocked;
  final bool isPreview;
  final bool isInvalid;
  final double animationProgress;  // 0.0–1.0
  final double glowPulse;          // 0.0–1.0

  ConnectionPainter({
    required this.start,
    required this.end,
    this.isLocked = false,
    this.isPreview = false,
    this.isInvalid = false,
    this.animationProgress = 1.0,
    this.glowPulse = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (start == end) return;

    final color = _getColor();
    final progress = animationProgress.clamp(0.0, 1.0);

    // Calculate animated end point.
    final animEnd = Offset(
      start.dx + (end.dx - start.dx) * progress,
      start.dy + (end.dy - start.dy) * progress,
    );

    // Layer 1: Wide outer glow.
    _drawGlow(canvas, start, animEnd, color);

    // Layer 2: Core cable.
    _drawCable(canvas, start, animEnd, color);

    // Layer 3: Bright center line.
    _drawCoreLine(canvas, start, animEnd, color);
  }

  void _drawGlow(Canvas canvas, Offset from, Offset to, Color color) {
    final glowWidth = AppDimensions.connectionGlowWidth + (glowPulse * 4.0);
    final glowOpacity = isPreview ? 0.15 : (0.2 + glowPulse * 0.1);

    final glowPaint = Paint()
      ..color = color.withValues(alpha: glowOpacity)
      ..strokeWidth = glowWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

    canvas.drawLine(from, to, glowPaint);
  }

  void _drawCable(Canvas canvas, Offset from, Offset to, Color color) {
    final width = isPreview
        ? AppDimensions.connectionPreviewWidth
        : AppDimensions.connectionWidth;

    final cablePaint = Paint()
      ..shader = ui.Gradient.linear(
        from,
        to,
        [
          Color.lerp(color, Colors.white, 0.2)!,
          color,
          Color.lerp(color, Colors.white, 0.2)!,
        ],
        [0.0, 0.5, 1.0],
      )
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(from, to, cablePaint);
  }

  void _drawCoreLine(Canvas canvas, Offset from, Offset to, Color color) {
    if (isPreview) return;

    final corePaint = Paint()
      ..color = Color.lerp(color, Colors.white, 0.6)!.withValues(alpha: 0.8)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(from, to, corePaint);
  }

  Color _getColor() {
    if (isInvalid) return AppColors.connectionInvalid;
    if (isPreview) return AppColors.connectionPreview;
    if (isLocked) return AppColors.connectionActive;
    return AppColors.connectionDefault;
  }

  @override
  bool shouldRepaint(ConnectionPainter oldDelegate) {
    return oldDelegate.start != start ||
        oldDelegate.end != end ||
        oldDelegate.isLocked != isLocked ||
        oldDelegate.isPreview != isPreview ||
        oldDelegate.isInvalid != isInvalid ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.glowPulse != glowPulse;
  }
}
