enum AdEnvironment { development, production }

enum RewardType { extraMove, secondChance, hint, scoreBoost }

enum RewardedAdResult { success, cancelled, failed, unavailable }

class AdConfig {
  const AdConfig({
    required this.environment,
    required this.bannerAdUnitId,
    required this.interstitialAdUnitId,
    required this.rewardedAdUnitId,
    required this.isProduction,
  });

  final AdEnvironment environment;
  final String bannerAdUnitId;
  final String interstitialAdUnitId;
  final String rewardedAdUnitId;
  final bool isProduction;

  factory AdConfig.development() {
    return const AdConfig(
      environment: AdEnvironment.development,
      bannerAdUnitId: 'ca-app-pub-3940256099942544/9214589741',
      interstitialAdUnitId: 'ca-app-pub-3940256099942544/1033173712',
      rewardedAdUnitId: 'ca-app-pub-3940256099942544/5224354917',
      isProduction: false,
    );
  }

  factory AdConfig.production() {
    return const AdConfig(
      environment: AdEnvironment.production,
      bannerAdUnitId: '',
      interstitialAdUnitId: '',
      rewardedAdUnitId: '',
      isProduction: true,
    );
  }
}
