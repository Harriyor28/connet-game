import 'package:flutter/material.dart';

/// Reusable glow effect painter for various UI elements.
class GlowEffectPainter extends CustomPainter {
  final Color color;
  final double intensity;  // 0.0–1.0
  final double radius;

  GlowEffectPainter({
    required this.color,
    this.intensity = 0.5,
    this.radius = 40.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: intensity),
          color.withValues(alpha: intensity * 0.5),
          color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(GlowEffectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.intensity != intensity ||
        oldDelegate.radius != radius;
  }
}

/// A widget that shows a pulsing glow effect.
class PulsingGlow extends StatefulWidget {
  final Color color;
  final double radius;
  final double minIntensity;
  final double maxIntensity;
  final Duration duration;

  const PulsingGlow({
    super.key,
    required this.color,
    this.radius = 40.0,
    this.minIntensity = 0.2,
    this.maxIntensity = 0.6,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<PulsingGlow> createState() => _PulsingGlowState();
}

class _PulsingGlowState extends State<PulsingGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: widget.minIntensity,
      end: widget.maxIntensity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: GlowEffectPainter(
            color: widget.color,
            intensity: _animation.value,
            radius: widget.radius,
          ),
        );
      },
    );
  }
}
