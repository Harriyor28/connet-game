import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nexus_link/core/constants/app_colors.dart';
import 'package:nexus_link/core/constants/app_strings.dart';
import 'package:nexus_link/core/constants/app_dimensions.dart';
import 'package:nexus_link/providers/level_provider.dart';
import 'package:nexus_link/providers/navigation_provider.dart';
import 'package:nexus_link/widgets/common/gradient_background.dart';
import 'package:nexus_link/widgets/ui/premium_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _titleFade;
  late Animation<double> _titleSlide;
  late Animation<double> _buttonFade;
  late Animation<double> _taglineFade;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<double>(begin: -30, end: 0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _taglineFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.25, 0.55, curve: Curves.easeOut),
      ),
    );
    _buttonFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.5, 0.85, curve: Curves.easeOut),
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.read<NavigationProvider>();
    final levelProvider = context.watch<LevelProvider>();
    final unlocks = levelProvider.progress.unlockedLevels;
    final currentLevel = levelProvider.progress.currentLevelId ?? 'easy_001';
    final isNewPlayer = unlocks.length <= 1;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.panelPadding,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 1),
                  AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _titleSlide.value),
                        child: Opacity(opacity: _titleFade.value, child: child),
                      );
                    },
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return const LinearGradient(
                          colors: [
                            AppColors.primaryCyan,
                            AppColors.secondaryMagenta,
                          ],
                        ).createShader(bounds);
                      },
                      child: Text(
                        AppStrings.appName.toUpperCase(),
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(
                              fontSize: 44,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: AppColors.primaryCyan.withValues(
                                    alpha: 0.5,
                                  ),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      return Opacity(opacity: _taglineFade.value, child: child);
                    },
                    child: Text(
                      AppStrings.tagline,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 3.0,
                      ),
                    ),
                  ),
                  const Spacer(flex: 1),
                  AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _buttonFade.value,
                        child: Transform.scale(
                          scale: 0.8 + _buttonFade.value * 0.2,
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        PremiumButton(
                          text: isNewPlayer ? 'START GAME' : 'CONTINUE',
                          onPressed: () => nav.goToWorldSelect(),
                          isPrimary: true,
                          width: 240,
                        ),
                        if (!isNewPlayer) ...[
                          const SizedBox(height: AppDimensions.spacingS),
                          Text(
                            'Level ${currentLevel.replaceAll(RegExp(r'[^0-9]'), '')}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingL),
                  _menuButton('WORLDS', onPressed: nav.goToWorldSelect),
                  _menuButton('ACHIEVEMENTS', onPressed: nav.goToAchievements),
                  _menuButton('PROFILE', onPressed: nav.goToProfile),
                  _menuButton('SETTINGS', onPressed: nav.goToSettings),
                  const Spacer(flex: 1),
                  AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _buttonFade.value * 0.5,
                        child: child,
                      );
                    },
                    child: Text(
                      'v1.0.0',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuButton(String label, {required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingS),
      child: PremiumButton(
        text: label,
        onPressed: onPressed,
        isPrimary: false,
        width: 200,
      ),
    );
  }
}
