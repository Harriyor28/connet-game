import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nexus_link/core/ads/ad_manager.dart';
import 'package:nexus_link/core/analytics/analytics_event.dart';
import 'package:nexus_link/core/analytics/analytics_service.dart';
import 'package:nexus_link/core/constants/app_strings.dart';
import 'package:nexus_link/core/theme/app_theme.dart';
import 'package:nexus_link/core/utils/responsive.dart';
import 'package:nexus_link/managers/settings_manager.dart';
import 'package:nexus_link/providers/game_provider.dart';
import 'package:nexus_link/providers/level_provider.dart';
import 'package:nexus_link/providers/navigation_provider.dart';
import 'package:nexus_link/screens/achievements_screen.dart';
import 'package:nexus_link/screens/difficulty_select_screen.dart';
import 'package:nexus_link/screens/game_screen.dart';
import 'package:nexus_link/screens/help_screen.dart';
import 'package:nexus_link/screens/home_screen.dart';
import 'package:nexus_link/screens/level_select_screen.dart';
import 'package:nexus_link/screens/profile_screen.dart';
import 'package:nexus_link/screens/settings_screen.dart';
import 'package:nexus_link/screens/splash_screen.dart';
import 'package:nexus_link/screens/tutorial_screen.dart';
import 'package:nexus_link/screens/world_select_screen.dart';

class NexusLinkApp extends StatefulWidget {
  const NexusLinkApp({super.key, this.analytics});

  final AnalyticsService? analytics;

  @override
  State<NexusLinkApp> createState() => _NexusLinkAppState();
}

class _NexusLinkAppState extends State<NexusLinkApp>
    with WidgetsBindingObserver {
  AnalyticsService get _analytics =>
      widget.analytics ?? LocalAnalyticsService.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final event = switch (state) {
      AppLifecycleState.paused ||
      AppLifecycleState.detached => AnalyticsEventName.appBackgrounded,
      AppLifecycleState.resumed => AnalyticsEventName.appForegrounded,
      _ => null,
    };
    if (event != null) _analytics.logEvent(event);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => LevelProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => SettingsManager()),
        Provider(create: (_) => AdManager.instance),
        Provider<AnalyticsService>.value(value: _analytics),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const _AppNavigator(),
      ),
    );
  }
}

class _AppNavigator extends StatefulWidget {
  const _AppNavigator();

  @override
  State<_AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<_AppNavigator> {
  AppScreen? _trackedScreen;

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    final nav = context.watch<NavigationProvider>();
    if (_trackedScreen != nav.currentScreen) {
      _trackedScreen = nav.currentScreen;
      final analytics = context.read<AnalyticsService>();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final screenName = nav.currentScreen.name;
        analytics.setScreen(screenName);
        if (nav.currentScreen == AppScreen.home) {
          analytics.logEvent(AnalyticsEventName.mainMenuLoaded);
        }
      });
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop &&
            nav.currentScreen != AppScreen.home &&
            nav.currentScreen != AppScreen.splash) {
          nav.goBack();
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: switch (nav.currentScreen) {
          AppScreen.splash => const SplashScreen(key: ValueKey('splash')),
          AppScreen.home => const HomeScreen(key: ValueKey('home')),
          AppScreen.worldSelect => const WorldSelectScreen(
            key: ValueKey('worldSelect'),
          ),
          AppScreen.difficultySelect => const DifficultySelectScreen(
            key: ValueKey('difficultySelect'),
          ),
          AppScreen.levelSelect => const LevelSelectScreen(
            key: ValueKey('levelSelect'),
          ),
          AppScreen.settings => const SettingsScreen(key: ValueKey('settings')),
          AppScreen.achievements => const AchievementsScreen(
            key: ValueKey('achievements'),
          ),
          AppScreen.profile => const ProfileScreen(key: ValueKey('profile')),
          AppScreen.help => const HelpScreen(key: ValueKey('help')),
          AppScreen.tutorial => const TutorialScreen(key: ValueKey('tutorial')),
          AppScreen.game => GameScreen(
            key: ValueKey('game_${nav.selectedLevelId}'),
            levelId: nav.selectedLevelId ?? 'easy_001',
          ),
          AppScreen.loading ||
          AppScreen.error => const HomeScreen(key: ValueKey('fallbackHome')),
        },
      ),
    );
  }
}
