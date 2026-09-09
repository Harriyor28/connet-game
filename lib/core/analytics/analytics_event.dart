enum AnalyticsEventName {
  appStart('app_start'),
  appInitialized('app_initialized'),
  mainMenuLoaded('main_menu_loaded'),
  sessionStarted('session_started'),
  screenViewed('screen_viewed'),
  levelStarted('level_started'),
  levelCompleted('level_completed'),
  levelFailed('level_failed'),
  levelRestarted('level_restarted'),
  levelPaused('level_paused'),
  levelResumed('level_resumed'),
  levelAbandoned('level_abandoned'),
  worldOpened('world_opened'),
  worldUnlocked('world_unlocked'),
  difficultySelected('difficulty_selected'),
  achievementUnlocked('achievement_unlocked'),
  highScore('high_score'),
  perfectLevel('perfect_level'),
  highestComboReached('highest_combo_reached'),
  tutorialStarted('tutorial_started'),
  tutorialCompleted('tutorial_completed'),
  tutorialSkipped('tutorial_skipped'),
  graphicsQualityChanged('graphics_quality_changed'),
  musicToggled('music_toggled'),
  soundToggled('sound_toggled'),
  voiceToggled('voice_toggled'),
  hapticsToggled('haptics_toggled'),
  adLoadRequested('ad_load_requested'),
  adLoaded('ad_loaded'),
  adLoadFailed('ad_load_failed'),
  adClosed('ad_closed'),
  rewardedStarted('rewarded_started'),
  rewardedCompleted('rewarded_completed'),
  rewardedCancelled('rewarded_cancelled'),
  rewardedFailed('rewarded_failed'),
  appBackgrounded('app_backgrounded'),
  appForegrounded('app_foregrounded'),
  performanceIssue('performance_issue');

  const AnalyticsEventName(this.value);

  final String value;
}

enum ErrorCategory {
  startup,
  rendering,
  levelLoading,
  levelValidation,
  assetLoading,
  audio,
  haptics,
  navigation,
  persistence,
  ads,
  analytics,
  network,
  performance,
  unknown,
}

class AnalyticsEvent {
  const AnalyticsEvent({
    required this.name,
    this.parameters = const <String, Object?>{},
    required this.timestamp,
  });

  final AnalyticsEventName name;
  final Map<String, Object?> parameters;
  final DateTime timestamp;

  Map<String, Object?> toJson() => {
        'name': name.value,
        'parameters': parameters,
        'timestamp': timestamp.toUtc().toIso8601String(),
      };
}