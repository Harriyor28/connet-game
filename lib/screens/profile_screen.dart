import 'package:flutter/material.dart';
import 'package:nexus_link/core/constants/app_colors.dart';
import 'package:nexus_link/core/constants/app_dimensions.dart';
import 'package:nexus_link/managers/player_statistics.dart';
import 'package:nexus_link/widgets/common/glass_panel.dart';
import 'package:nexus_link/widgets/common/gradient_background.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const stats = PlayerStatistics(
      levelsCompleted: 48,
      totalStars: 123,
      bestScore: 8450,
      perfectLevels: 21,
      highestCombo: 12,
      fastestLevelSeconds: 18,
    );

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
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_ios_new),
                    ),
                    Expanded(
                      child: Text(
                        'PLAYER',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingL),
                GlassPanel(
                  child: Center(
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 42,
                          backgroundColor: AppColors.primaryCyan,
                          child: Icon(
                            Icons.person,
                            size: 48,
                            color: AppColors.backgroundDark,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingM),
                        Text(
                          'PLAYER',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingL),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppDimensions.spacingM,
                    mainAxisSpacing: AppDimensions.spacingM,
                    children: [
                      _statCard('Levels', '${stats.levelsCompleted}'),
                      _statCard('Stars', '${stats.totalStars}'),
                      _statCard('Best Score', '${stats.bestScore}'),
                      _statCard('Perfect', '${stats.perfectLevels}'),
                      _statCard('Best Combo', 'x${stats.highestCombo}'),
                      _statCard('Fastest', '${stats.fastestLevelSeconds}s'),
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

  Widget _statCard(String label, String value) {
    return GlassPanel(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
