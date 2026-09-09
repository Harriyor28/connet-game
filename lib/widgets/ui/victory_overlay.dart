import 'package:flutter/material.dart';
import 'package:nexus_link/core/constants/app_colors.dart';
import 'package:nexus_link/core/constants/app_dimensions.dart';
import 'package:nexus_link/core/constants/app_strings.dart';
import 'package:nexus_link/models/level_result.dart';
import 'package:nexus_link/widgets/common/glass_panel.dart';
import 'package:nexus_link/widgets/ui/premium_button.dart';
import 'package:nexus_link/widgets/ui/star_display.dart';

/// Victory overlay shown when a level is completed.
class VictoryOverlay extends StatefulWidget {
  final LevelResult? result;
  final VoidCallback? onNextLevel;
  final VoidCallback? onRetry;
  final VoidCallback? onMenu;

  const VictoryOverlay({
    super.key,
    this.result,
    this.onNextLevel,
    this.onRetry,
    this.onMenu,
  });

  @override
  State<VictoryOverlay> createState() => _VictoryOverlayState();
}

class _VictoryOverlayState extends State<VictoryOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: AppDimensions.animVictory),
      vsync: this,
    );

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _scaleIn = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.5, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeIn.value,
          child: Container(
            color: Colors.black.withValues(alpha: 0.6 * _fadeIn.value),
            child: Center(
              child: Transform.scale(
                scale: _scaleIn.value,
                child: child,
              ),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXL),
        child: GlassPanel(
          borderColor: AppColors.primaryCyan.withValues(alpha: 0.3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              ShaderMask(
                shaderCallback: (bounds) {
                  return const LinearGradient(
                    colors: [
                      AppColors.primaryCyan,
                      AppColors.secondaryMagenta,
                    ],
                  ).createShader(bounds);
                },
                child: Text(
                  _getTitle(result),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingL),

              // Stars
              if (result != null)
                StarDisplay(
                  starCount: result.stars,
                  size: 44,
                  animate: true,
                ),
              const SizedBox(height: AppDimensions.spacingL),

              // Score
              if (result != null) ...[
                Text(
                  '${AppStrings.score}: ${result.score}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primaryCyan,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingS),
                Text(
                  '${AppStrings.moves}: ${result.moves}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (result.isPerfect) ...[
                  const SizedBox(height: AppDimensions.spacingS),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.accentGold.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Text(
                      AppStrings.perfect,
                      style: TextStyle(
                        color: AppColors.accentGold,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                ],
              ],
              const SizedBox(height: AppDimensions.spacingXL),

              // Buttons
              PremiumButton(
                text: AppStrings.nextLevel,
                onPressed: widget.onNextLevel,
                isPrimary: true,
              ),
              const SizedBox(height: AppDimensions.spacingM),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: PremiumButton(
                      text: AppStrings.retry,
                      onPressed: widget.onRetry,
                      isPrimary: false,
                      icon: Icons.refresh,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingM),
                  Expanded(
                    child: PremiumButton(
                      text: 'Menu',
                      onPressed: widget.onMenu,
                      isPrimary: false,
                      icon: Icons.grid_view,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTitle(LevelResult? result) {
    if (result == null) return AppStrings.levelComplete;
    if (result.isPerfect) return AppStrings.perfect;
    if (result.stars >= 3) return AppStrings.excellent;
    return AppStrings.levelComplete;
  }
}
