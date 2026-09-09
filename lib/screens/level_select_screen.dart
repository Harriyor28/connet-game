import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nexus_link/core/constants/app_colors.dart';
import 'package:nexus_link/core/constants/app_dimensions.dart';
import 'package:nexus_link/core/constants/app_strings.dart';
import 'package:nexus_link/models/level_model.dart';
import 'package:nexus_link/providers/level_provider.dart';
import 'package:nexus_link/providers/navigation_provider.dart';
import 'package:nexus_link/widgets/common/gradient_background.dart';
import 'package:nexus_link/widgets/ui/level_card.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.read<NavigationProvider>();
    final levelProvider = context.watch<LevelProvider>();

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, nav),
              _buildDifficultyTabs(context, levelProvider),
              const SizedBox(height: AppDimensions.spacingM),
              Expanded(child: _buildLevelGrid(context, levelProvider, nav)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, NavigationProvider nav) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
            ),
            onPressed: () => nav.goToDifficultySelect(),
          ),
          Expanded(
            child: Text(
              '${AppStrings.levels} • ${_difficultyLabel(nav.selectedDifficulty)}',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildDifficultyTabs(
    BuildContext context,
    LevelProvider levelProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingM),
      child: Row(
        children: Difficulty.values.map((d) {
          final isSelected = d == levelProvider.selectedDifficulty;
          return Expanded(
            child: GestureDetector(
              onTap: () => levelProvider.setDifficulty(d),
              child: AnimatedContainer(
                duration: const Duration(
                  milliseconds: AppDimensions.animNormal,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryCyan.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryCyan
                        : AppColors.inactive,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Text(
                  _difficultyLabel(d),
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.primaryCyan
                        : AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLevelGrid(
    BuildContext context,
    LevelProvider levelProvider,
    NavigationProvider nav,
  ) {
    final levels = levelProvider.currentLevels;

    if (levels.isEmpty) {
      return Center(
        child: Text(
          'Coming Soon',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppColors.textMuted),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: levels.length,
      itemBuilder: (context, index) {
        final level = levels[index];
        final isUnlocked = levelProvider.isLevelUnlocked(level.id);
        final stars = levelProvider.getStars(level.id);

        return LevelCard(
          levelNumber: level.levelNumber,
          stars: stars,
          isUnlocked: isUnlocked,
          onTap: isUnlocked ? () => nav.goToGame(level.id) : null,
        );
      },
    );
  }

  String _difficultyLabel(Difficulty d) {
    switch (d) {
      case Difficulty.easy:
        return AppStrings.easy;
      case Difficulty.medium:
        return AppStrings.medium;
      case Difficulty.hard:
        return AppStrings.hard;
      case Difficulty.professional:
        return 'Pro';
    }
  }
}
