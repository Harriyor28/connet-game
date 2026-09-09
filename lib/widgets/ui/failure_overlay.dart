import 'package:flutter/material.dart';
import 'package:nexus_link/core/constants/app_colors.dart';
import 'package:nexus_link/core/constants/app_dimensions.dart';
import 'package:nexus_link/models/level_result.dart';
import 'package:nexus_link/widgets/common/glass_panel.dart';
import 'package:nexus_link/widgets/ui/premium_button.dart';

/// Retryable result panel for a failed level.
class FailureOverlay extends StatefulWidget {
  final LevelResult? result;
  final VoidCallback? onRetry;
  final VoidCallback? onMenu;

  const FailureOverlay({
    super.key,
    this.result,
    this.onRetry,
    this.onMenu,
  });

  @override
  State<FailureOverlay> createState() => _FailureOverlayState();
}

class _FailureOverlayState extends State<FailureOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppDimensions.animVictory),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    return FadeTransition(
      opacity: _controller,
      child: Container(
        color: Colors.black.withValues(alpha: 0.68),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingXL),
            child: GlassPanel(
              borderColor: AppColors.error.withValues(alpha: 0.45),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.error, size: 48),
                  const SizedBox(height: AppDimensions.spacingM),
                  const Text(
                    'LEVEL FAILED',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                  Text(
                    _reason(result?.failureReason),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spacingL),
                  PremiumButton(
                    text: 'RETRY',
                    icon: Icons.refresh,
                    onPressed: widget.onRetry,
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  PremiumButton(
                    text: 'LEVELS',
                    icon: Icons.grid_view,
                    isPrimary: false,
                    onPressed: widget.onMenu,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _reason(FailureReason? reason) {
    switch (reason) {
      case FailureReason.tooManyMistakes:
        return 'Too many mistakes.';
      case FailureReason.outOfMoves:
        return 'Move limit reached.';
      case FailureReason.timeExpired:
        return 'Time expired.';
      case null:
        return 'Puzzle incomplete.';
    }
  }
}