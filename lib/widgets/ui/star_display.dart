import 'package:flutter/material.dart';
import 'package:nexus_link/core/constants/app_colors.dart';

/// Displays a row of star icons (1-3).
class StarDisplay extends StatelessWidget {
  final int starCount;
  final int totalStars;
  final double size;
  final bool animate;

  const StarDisplay({
    super.key,
    required this.starCount,
    this.totalStars = 3,
    this.size = 28,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalStars, (index) {
        final isFilled = index < starCount;
        final widget = Icon(
          isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
          color: isFilled ? AppColors.accentGold : AppColors.textMuted,
          size: size,
        );

        if (animate && isFilled) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 400 + index * 200),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: child,
                ),
              );
            },
            child: widget,
          );
        }
        return widget;
      }),
    );
  }
}
