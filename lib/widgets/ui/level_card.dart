import 'package:flutter/material.dart';
import 'package:nexus_link/core/constants/app_colors.dart';
import 'package:nexus_link/core/constants/app_dimensions.dart';
import 'package:nexus_link/widgets/ui/star_display.dart';

/// A card representing a level in the level select grid.
class LevelCard extends StatelessWidget {
  final int levelNumber;
  final int? stars;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const LevelCard({
    super.key,
    required this.levelNumber,
    this.stars,
    this.isUnlocked = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: AppDimensions.animNormal),
        decoration: BoxDecoration(
          color: isUnlocked
              ? AppColors.backgroundMedium
              : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border: Border.all(
            color: isUnlocked
                ? (stars != null
                    ? AppColors.primaryCyan.withValues(alpha: 0.4)
                    : AppColors.primaryCyan.withValues(alpha: 0.2))
                : AppColors.inactive.withValues(alpha: 0.3),
            width: 1.0,
          ),
          boxShadow: isUnlocked && stars != null
              ? [
                  BoxShadow(
                    color: AppColors.primaryCyan.withValues(alpha: 0.1),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isUnlocked)
              Icon(
                Icons.lock_outline,
                color: AppColors.textMuted,
                size: 28,
              )
            else
              Text(
                '$levelNumber',
                style: TextStyle(
                  color: stars != null
                      ? AppColors.primaryCyan
                      : AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
            const SizedBox(height: 8),
            if (isUnlocked && stars != null)
              StarDisplay(starCount: stars!, size: 18),
            if (isUnlocked && stars == null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  3,
                  (i) => Icon(
                    Icons.star_outline_rounded,
                    color: AppColors.textMuted.withValues(alpha: 0.4),
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
