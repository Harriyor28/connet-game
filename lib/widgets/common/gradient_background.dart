import 'package:flutter/material.dart';
import 'package:nexus_link/world/world_definition.dart';

/// Premium gradient background with subtle grid pattern.
class GradientBackground extends StatelessWidget {
  final Widget child;
  final WorldTheme theme;

  const GradientBackground({
    super.key,
    required this.child,
    this.theme = WorldTheme.neonLab,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [theme.backgroundTop, theme.backgroundBottom],
        ),
      ),
      child: Stack(
        children: [
          // Subtle grid overlay
          Positioned.fill(
            child: CustomPaint(painter: _GridPainter(color: theme.accent)),
          ),
          child,
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;

  const _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.035)
      ..strokeWidth = 0.5;

    const spacing = 40.0;

    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => oldDelegate.color != color;
}
