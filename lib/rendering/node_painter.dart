import 'package:flutter/material.dart';
import 'package:nexus_link/core/constants/app_colors.dart';
import 'package:nexus_link/core/constants/app_dimensions.dart';
import 'package:nexus_link/models/node_model.dart';

/// Custom painter that renders a 3D-styled spherical node.
class NodePainter extends CustomPainter {
  final NodeState state;
  final NodeType type;
  final double pulseAnimation; // 0.0–1.0 for pulsing glow
  final double scaleAnimation; // 0.0–1.0 for scale bounce
  final double visualScale;

  NodePainter({
    required this.state,
    this.type = NodeType.normal,
    this.pulseAnimation = 0.0,
    this.scaleAnimation = 1.0,
    this.visualScale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = AppDimensions.nodeRadius * scaleAnimation * visualScale;
    final color = _getColor();

    // Layer 1: Outer glow
    _drawOuterGlow(canvas, center, baseRadius, color);

    // Layer 2: Drop shadow
    _drawDropShadow(canvas, center, baseRadius);

    // Layer 3: Main sphere with 3D gradient
    _drawSphere(canvas, center, baseRadius, color);

    // Layer 4: Specular highlight
    _drawSpecularHighlight(canvas, center, baseRadius);

    // Layer 5: Inner ring (border)
    _drawInnerRing(canvas, center, baseRadius, color);
  }

  void _drawOuterGlow(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
  ) {
    final glowRadius = radius + 16.0 + (pulseAnimation * 8.0);
    final glowOpacity = (0.3 + pulseAnimation * 0.2).clamp(0.0, 1.0);

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: glowOpacity),
          color.withValues(alpha: glowOpacity * 0.5),
          color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: glowRadius));

    canvas.drawCircle(center, glowRadius, glowPaint);
  }

  void _drawDropShadow(Canvas canvas, Offset center, double radius) {
    final shadowCenter = Offset(center.dx + 2, center.dy + 4);
    final shadowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.black.withValues(alpha: 0.4),
          Colors.black.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: shadowCenter, radius: radius + 4));

    canvas.drawCircle(shadowCenter, radius + 4, shadowPaint);
  }

  void _drawSphere(Canvas canvas, Offset center, double radius, Color color) {
    // 3D sphere effect: light from top-left
    final spherePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(-0.3, -0.3),
        radius: 1.2,
        colors: [
          Color.lerp(color, Colors.white, 0.4)!,
          color,
          Color.lerp(color, Colors.black, 0.5)!,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, spherePaint);
  }

  void _drawSpecularHighlight(Canvas canvas, Offset center, double radius) {
    final highlightCenter = Offset(
      center.dx - radius * 0.25,
      center.dy - radius * 0.25,
    );
    final highlightRadius = radius * 0.35;

    final highlightPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              Colors.white.withValues(alpha: 0.7),
              Colors.white.withValues(alpha: 0.0),
            ],
          ).createShader(
            Rect.fromCircle(center: highlightCenter, radius: highlightRadius),
          );

    canvas.drawCircle(highlightCenter, highlightRadius, highlightPaint);
  }

  void _drawInnerRing(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
  ) {
    final ringPaint = Paint()
      ..color = Color.lerp(color, Colors.white, 0.3)!.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppDimensions.nodeBorderWidth;

    canvas.drawCircle(
      center,
      radius - AppDimensions.nodeBorderWidth / 2,
      ringPaint,
    );
  }

  Color _getColor() {
    switch (state) {
      case NodeState.idle:
        return _getTypeColor();
      case NodeState.active:
        return AppColors.nodeActive;
      case NodeState.connected:
        return AppColors.nodeConnected;
      case NodeState.completed:
        return AppColors.success;
      case NodeState.locked:
        return AppColors.nodeLocked;
      case NodeState.invalid:
        return AppColors.nodeInvalid;
    }
  }

  Color _getTypeColor() {
    switch (type) {
      case NodeType.normal:
        return AppColors.nodeNormal;
      case NodeType.bonus:
        return AppColors.nodeBonus;
      case NodeType.energy:
        return AppColors.primaryCyanLight;
      case NodeType.locked:
        return AppColors.nodeLocked;
      default:
        return AppColors.nodeNormal;
    }
  }

  @override
  bool shouldRepaint(NodePainter oldDelegate) {
    return oldDelegate.state != state ||
        oldDelegate.type != type ||
        oldDelegate.pulseAnimation != pulseAnimation ||
        oldDelegate.scaleAnimation != scaleAnimation ||
        oldDelegate.visualScale != visualScale;
  }
}
