enum AdState { idle, loading, loaded, showing, completed, failed, unavailable }

class AdFrequencyManager {
  const AdFrequencyManager({
    this.minimumLevelsBeforeInterstitial = 3,
    this.minimumIntervalMinutes = 5,
  });

  final int minimumLevelsBeforeInterstitial;
  final int minimumIntervalMinutes;

  bool shouldShowInterstitial({
    required int levelsCompletedSinceInterstitial,
    required DateTime? lastInterstitialAt,
    DateTime? now,
  }) {
    if (levelsCompletedSinceInterstitial < minimumLevelsBeforeInterstitial) {
      return false;
    }

    final currentTime = now ?? DateTime.now();
    if (lastInterstitialAt == null) {
      return true;
    }

    final minutesSince = currentTime.difference(lastInterstitialAt).inMinutes;
    return minutesSince >= minimumIntervalMinutes;
  }
}
