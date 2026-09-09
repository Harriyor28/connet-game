import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_link/core/ads/ad_config.dart';
import 'package:nexus_link/core/ads/ad_state.dart';

void main() {
  group('Phase 7 ads', () {
    test('development config uses test ad units', () {
      final config = AdConfig.development();

      expect(config.environment, AdEnvironment.development);
      expect(config.bannerAdUnitId.contains('test') || config.bannerAdUnitId.contains('3940256099942544'), isTrue);
      expect(config.interstitialAdUnitId.contains('3940256099942544'), isTrue);
      expect(config.rewardedAdUnitId.contains('3940256099942544'), isTrue);
    });

    test('frequency guard only allows interstitials after sufficient progress', () {
      final guard = AdFrequencyManager(
        minimumLevelsBeforeInterstitial: 3,
        minimumIntervalMinutes: 5,
      );

      expect(
        guard.shouldShowInterstitial(
          levelsCompletedSinceInterstitial: 0,
          lastInterstitialAt: null,
        ),
        isFalse,
      );

      final now = DateTime.now();
      expect(
        guard.shouldShowInterstitial(
          levelsCompletedSinceInterstitial: 3,
          lastInterstitialAt: now.subtract(const Duration(minutes: 10)),
        ),
        isTrue,
      );
    });

    test('reward results distinguish success from cancelled or unavailable', () {
      expect(RewardedAdResult.success, isNot(RewardedAdResult.cancelled));
      expect(RewardedAdResult.unavailable, isNot(RewardedAdResult.success));
      expect(RewardedAdResult.failed, isNot(RewardedAdResult.cancelled));
    });

    test('ad-state enum tracks lifecycle transitions clearly', () {
      expect(AdState.idle.index, 0);
      expect(AdState.loaded.index, 2);
      expect(AdState.completed.index, 4);
    });
  });
}
