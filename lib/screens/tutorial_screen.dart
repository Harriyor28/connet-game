import 'package:flutter/material.dart';
import 'package:nexus_link/core/constants/app_colors.dart';
import 'package:nexus_link/core/constants/app_dimensions.dart';
import 'package:nexus_link/widgets/common/gradient_background.dart';
import 'package:nexus_link/widgets/ui/premium_button.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingL),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundMedium.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                    border: Border.all(color: AppColors.primaryCyan.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.touch_app_rounded,
                        size: 60,
                        color: AppColors.primaryCyan,
                      ),
                      const SizedBox(height: AppDimensions.spacingL),
                      const Text(
                        'CONNECT THE NODES',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingM),
                      const Text(
                        'Drag from one node to another to create a connection.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXL),
                      PremiumButton(
                        text: 'CONTINUE',
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
