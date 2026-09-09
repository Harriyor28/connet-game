import 'dart:async';

import 'ad_config.dart';
import 'ad_service.dart';
import 'package:nexus_link/core/config/app_environment.dart';

class AdManager {
  AdManager._internal();

  static final AdManager _instance = AdManager._internal();
  static AdManager get instance => _instance;

  final AdConfig _config = AppEnvironment.adConfig;
  late final AdService _service = AdService(config: _config);

  bool get isInitialized => _service.isInitialized;
  bool get bannerAvailable => _service.bannerAvailable;
  bool get interstitialAvailable => _service.interstitialAvailable;
  bool get rewardedAvailable => _service.rewardedAvailable;

  static Future<void> initialize() async {
    try {
      await instance._service.initialize();
      await instance._service.loadInterstitial();
      await instance._service.loadRewarded();
      await instance._service.loadBanner(
        adUnitId: instance._config.bannerAdUnitId,
      );
    } catch (_) {
      // Keep gameplay fully offline-safe even when ads fail to initialize.
    }
  }

  static Future<bool> showInterstitial() async {
    return instance._service.showInterstitial();
  }

  static Future<RewardedAdResult> showRewarded() async {
    return instance._service.showRewarded();
  }

  static void dispose() {
    instance._service.dispose();
  }
}
