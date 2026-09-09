import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nexus_link/core/analytics/analytics_context.dart';
import 'package:nexus_link/core/analytics/analytics_event.dart';
import 'package:nexus_link/core/analytics/analytics_service.dart';
import 'package:nexus_link/core/constants/app_colors.dart';
import 'package:nexus_link/core/constants/app_dimensions.dart';
import 'package:nexus_link/core/constants/app_strings.dart';
import 'package:nexus_link/providers/game_provider.dart';
import 'package:nexus_link/providers/level_provider.dart';
import 'package:nexus_link/providers/navigation_provider.dart';
import 'package:nexus_link/widgets/common/gradient_background.dart';
import 'package:nexus_link/widgets/game/puzzle_board.dart';
import 'package:nexus_link/widgets/ui/failure_overlay.dart';
import 'package:nexus_link/widgets/ui/victory_overlay.dart';
import 'package:nexus_link/world/world_manager.dart';

class GameScreen extends StatefulWidget {
  final String levelId;

  const GameScreen({super.key, required this.levelId});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  String? _recordedResultId;
  bool _loadError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLevel();
    });
  }

  void _loadLevel() {
    setState(() => _loadError = false);
    final levelProvider = context.read<LevelProvider>();
    final gameProvider = context.read<GameProvider>();
    final level = levelProvider.getLevel(widget.levelId);
    if (level != null) {
      WorldManager().loadWorld(level.worldId);
      gameProvider.loadLevel(level);
    } else {
      setState(() => _loadError = true);
      context.read<AnalyticsService>().recordError(
        StateError('Level not found: ${widget.levelId}'),
        StackTrace.current,
        category: ErrorCategory.levelLoading,
        context: AnalyticsContext(screen: 'game', levelId: widget.levelId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        theme: WorldManager().activeWorld.theme,
        child: SafeArea(
          child: Consumer<GameProvider>(
            builder: (context, game, _) {
              _persistCompletedResult(game);
              return Stack(
                children: [
                  Column(
                    children: [
                      _buildHUD(context, game),
                      Expanded(
                        child: game.state != null
                            ? PuzzleBoard(
                                theme: WorldManager().activeWorld.theme,
                              )
                            : _loadError
                            ? _buildLoadError(context)
                            : const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryCyan,
                                ),
                              ),
                      ),
                      _buildBottomBar(context, game),
                    ],
                  ),
                  if (game.isFailed)
                    FailureOverlay(
                      result: game.lastResult,
                      onRetry: () => game.resetLevel(),
                      onMenu: () =>
                          context.read<NavigationProvider>().goToLevelSelect(),
                    ),
                  if (game.isComplete)
                    VictoryOverlay(
                      result: game.lastResult,
                      onNextLevel: () => _goToNextLevel(),
                      onRetry: () => game.resetLevel(),
                      onMenu: () =>
                          context.read<NavigationProvider>().goToLevelSelect(),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              'Unable to load this level',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              'Please try again or return to the level select screen.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingL),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () =>
                      context.read<NavigationProvider>().goToLevelSelect(),
                  child: const Text('BACK TO LEVELS'),
                ),
                const SizedBox(width: AppDimensions.spacingM),
                FilledButton(onPressed: _loadLevel, child: const Text('RETRY')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _persistCompletedResult(GameProvider game) {
    final result = game.lastResult;
    if (!game.isComplete ||
        result == null ||
        _recordedResultId == result.levelId) {
      return;
    }
    _recordedResultId = result.levelId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<LevelProvider>().completeLevel(result);
      }
    });
  }

  Widget _buildHUD(BuildContext context, GameProvider game) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingS,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
              size: 22,
            ),
            onPressed: () {
              context.read<NavigationProvider>().goToLevelSelect();
            },
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${AppStrings.level} ${game.state?.level.levelNumber ?? ''}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingL),
                _hudItem(
                  context,
                  Icons.touch_app_outlined,
                  '${game.moveCount}',
                  AppStrings.moves,
                ),
                const SizedBox(width: AppDimensions.spacingXL),
                _hudItem(
                  context,
                  Icons.timer_outlined,
                  '${game.elapsedSeconds}s',
                  AppStrings.time,
                ),
                const SizedBox(width: AppDimensions.spacingXL),
                _hudItem(
                  context,
                  Icons.star_outline,
                  '${game.score}',
                  AppStrings.score,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: AppColors.textSecondary,
              size: 24,
            ),
            onPressed: () => game.resetLevel(),
          ),
        ],
      ),
    );
  }

  Widget _hudItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.primaryCyan),
            const SizedBox(width: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, GameProvider game) {
    final state = game.state;
    if (state == null) return const SizedBox.shrink();

    final required = state.level.requiredConnections.length;
    final completed = state.activeConnections.where((c) => c.isLocked).length;

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Connections: $completed / $required',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          if (game.comboCount > 1) ...[
            const SizedBox(width: AppDimensions.spacingM),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentGold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.accentGold.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                '${AppStrings.combo} x${game.comboCount}',
                style: const TextStyle(
                  color: AppColors.accentGold,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _goToNextLevel() {
    final levelProvider = context.read<LevelProvider>();
    final levels = levelProvider.currentLevels;
    final currentIndex = levels.indexWhere((l) => l.id == widget.levelId);
    if (currentIndex >= 0 && currentIndex < levels.length - 1) {
      final nextLevel = levels[currentIndex + 1];
      if (levelProvider.isLevelUnlocked(nextLevel.id)) {
        context.read<NavigationProvider>().goToGame(nextLevel.id);
      } else {
        context.read<NavigationProvider>().goToLevelSelect();
      }
    } else {
      context.read<NavigationProvider>().goToLevelSelect();
    }
  }
}
