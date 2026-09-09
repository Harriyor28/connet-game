import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nexus_link/core/constants/app_colors.dart';
import 'package:nexus_link/core/constants/app_dimensions.dart';
import 'package:nexus_link/core/constants/app_strings.dart';
import 'package:nexus_link/models/level_model.dart';
import 'package:nexus_link/providers/level_provider.dart';
import 'package:nexus_link/providers/navigation_provider.dart';
import 'package:nexus_link/widgets/common/glass_panel.dart';
import 'package:nexus_link/widgets/common/gradient_background.dart';
import 'package:nexus_link/widgets/ui/premium_button.dart';

class DifficultySelectScreen extends StatelessWidget {
  const DifficultySelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.read<NavigationProvider>();
    final levelProvider = context.watch<LevelProvider>();

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingL),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: nav.goToWorldSelect,
                      icon: const Icon(Icons.arrow_back_ios_new),
                    ),
                    Expanded(
                      child: Text(
                        'DIFFICULTY',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingL),
                Expanded(
                  child: ListView(
                    children: Difficulty.values.map((difficulty) {
                      final levels = levelProvider.getLevels(difficulty);
                      final completed = levelProvider.getCompletedCount(
                        difficulty,
                      );
                      final stars = levelProvider.getStarsForDifficulty(
                        difficulty,
                      );
                      final firstLevel = levels.isEmpty ? null : levels.first;
                      final locked =
                          firstLevel == null ||
                          !levelProvider.isLevelUnlocked(firstLevel.id);

                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.spacingM,
                        ),
                        child: GlassPanel(
                          borderColor: locked
                              ? AppColors.inactive.withValues(alpha: 0.3)
                              : AppColors.primaryCyan.withValues(alpha: 0.3),
                          child: InkWell(
                            onTap: locked
                                ? null
                                : () {
                                    nav.setDifficulty(difficulty);
                                    nav.goToLevelSelect();
                                  },
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _label(difficulty),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.headlineMedium,
                                      ),
                                      const SizedBox(
                                        height: AppDimensions.spacingXS,
                                      ),
                                      Text(
                                        locked
                                            ? 'LOCKED'
                                            : _description(difficulty),
                                        style: TextStyle(
                                          color: locked
                                              ? AppColors.textMuted
                                              : AppColors.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: AppDimensions.spacingS,
                                      ),
                                      Text(
                                        locked
                                            ? 'Complete previous difficulty to unlock'
                                            : '$completed / ${levels.length}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      locked ? '🔒' : '⭐ $stars',
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(
                                      height: AppDimensions.spacingS,
                                    ),
                                    PremiumButton(
                                      text: locked ? 'LOCKED' : 'PLAY',
                                      onPressed: locked
                                          ? null
                                          : () {
                                              nav.setDifficulty(difficulty);
                                              nav.goToLevelSelect();
                                            },
                                      width: 110,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _label(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return AppStrings.easy;
      case Difficulty.medium:
        return AppStrings.medium;
      case Difficulty.hard:
        return AppStrings.hard;
      case Difficulty.professional:
        return AppStrings.professional;
    }
  }

  String _description(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Beginner friendly';
      case Difficulty.medium:
        return 'More challenging';
      case Difficulty.hard:
        return 'Advanced puzzles';
      case Difficulty.professional:
        return 'Expert level';
    }
  }
}
