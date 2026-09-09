import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nexus_link/core/constants/app_colors.dart';
import 'package:nexus_link/core/constants/app_dimensions.dart';
import 'package:nexus_link/providers/level_provider.dart';
import 'package:nexus_link/providers/navigation_provider.dart';
import 'package:nexus_link/world/world_manager.dart';
import 'package:nexus_link/widgets/common/glass_panel.dart';
import 'package:nexus_link/widgets/common/gradient_background.dart';
import 'package:nexus_link/widgets/ui/premium_button.dart';

class WorldSelectScreen extends StatelessWidget {
  const WorldSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.read<NavigationProvider>();
    final levelProvider = context.watch<LevelProvider>();
    final worlds = WorldManager().allWorlds;

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
                      onPressed: nav.goToHome,
                      icon: const Icon(Icons.arrow_back_ios_new),
                    ),
                    Expanded(
                      child: Text(
                        'WORLD SELECT',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingL),
                Expanded(
                  child: ListView.builder(
                    itemCount: worlds.length,
                    itemBuilder: (context, index) {
                      final world = worlds[index];
                      final totalLevels = levelProvider
                          .getLevelsByWorld(world.id)
                          .length;
                      final completed = levelProvider.progress.completedLevels
                          .where(
                            (id) =>
                                levelProvider.getLevel(id)?.worldId == world.id,
                          )
                          .length;
                      final stars = levelProvider
                          .getLevelsByWorld(world.id)
                          .fold<int>(
                            0,
                            (sum, level) =>
                                sum + (levelProvider.getStars(level.id) ?? 0),
                          );
                      final unlocked =
                          world.id == 1 || completed > 0 || index == 0;

                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.spacingM,
                        ),
                        child: GlassPanel(
                          borderColor: unlocked
                              ? AppColors.primaryCyan.withValues(alpha: 0.3)
                              : AppColors.inactive.withValues(alpha: 0.2),
                          child: InkWell(
                            onTap: unlocked
                                ? () {
                                    nav.setWorld(world.id);
                                    nav.goToDifficultySelect();
                                  }
                                : null,
                            child: Row(
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    gradient: unlocked
                                        ? AppColors.accentGradient
                                        : null,
                                    color: unlocked
                                        ? null
                                        : AppColors.surfaceDark,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${world.id}',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppDimensions.spacingM),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        world.name.toUpperCase(),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleLarge,
                                      ),
                                      const SizedBox(
                                        height: AppDimensions.spacingXS,
                                      ),
                                      Text(
                                        unlocked
                                            ? '$completed/$totalLevels completed'
                                            : 'LOCKED',
                                        style: TextStyle(
                                          color: unlocked
                                              ? AppColors.textSecondary
                                              : AppColors.textMuted,
                                          fontSize: 12,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: AppDimensions.spacingXS,
                                      ),
                                      Text(
                                        unlocked
                                            ? 'Stars: ${'⭐' * (stars > 0 ? 1 : 0)}'
                                            : 'UNLOCKED AT WORLD 1',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                PremiumButton(
                                  text: unlocked ? 'EXPLORE' : 'LOCKED',
                                  onPressed: unlocked
                                      ? () {
                                          nav.setWorld(world.id);
                                          nav.goToDifficultySelect();
                                        }
                                      : null,
                                  isPrimary: unlocked,
                                  width: 120,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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
