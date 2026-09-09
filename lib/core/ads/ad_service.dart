import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';
import 'ad_state.dart';
import 'package:nexus_link/core/analytics/analytics_event.dart';
import 'package:nexus_link/core/analytics/analytics_service.dart';

class AdService {
  AdService({AdConfig? config, AnalyticsService? analytics})
    : _config = config ?? AdConfig.development(),
      _analytics = analytics ?? LocalAnalyticsService.instance;

  final AdConfig _config;
  final AnalyticsService _analytics;
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isInitialized = false;
  bool _isLoadingBanner = false;
  bool _isLoadingInterstitial = false;
  bool _isLoadingRewarded = false;
  AdState _bannerState = AdState.idle;
  AdState _interstitialState = AdState.idle;
  AdState _rewardedState = AdState.idle;

  bool get isInitialized => _isInitialized;
  bool get bannerAvailable =>
      _bannerAd != null && _bannerState == AdState.loaded;
  bool get interstitialAvailable =>
      _interstitialAd != null && _interstitialState == AdState.loaded;
  bool get rewardedAvailable =>
      _rewardedAd != null && _rewardedState == AdState.loaded;
  AdState get bannerState => _bannerState;
  AdState get interstitialState => _interstitialState;
  AdState get rewardedState => _rewardedState;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
    } catch (_) {
      _isInitialized = false;
    }
  }

  Future<void> loadBanner({required String adUnitId}) async {
    if (_isLoadingBanner || _config.isProduction && adUnitId.isEmpty) {
      return;
    }

    _isLoadingBanner = true;
    _bannerState = AdState.loading;
    unawaited(
      _analytics.logEvent(
        AnalyticsEventName.adLoadRequested,
        parameters: const <String, Object?>{'ad_type': 'banner'},
      ),
    );

    try {
      _bannerAd?.dispose();
      final ad = BannerAd(
        adUnitId: adUnitId,
        request: const AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (_) {
            _bannerState = AdState.loaded;
            _isLoadingBanner = false;
            unawaited(
              _analytics.logEvent(
                AnalyticsEventName.adLoaded,
                parameters: const <String, Object?>{'ad_type': 'banner'},
              ),
            );
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            _bannerAd = null;
            _bannerState = AdState.failed;
            _isLoadingBanner = false;
            unawaited(
              _analytics.logEvent(
                AnalyticsEventName.adLoadFailed,
                parameters: <String, Object?>{
                  'ad_type': 'banner',
                  'error_code': error.code,
                },
              ),
            );
          },
        ),
      );

      await ad.load();
      _bannerAd = ad;
    } catch (_) {
      _bannerState = AdState.unavailable;
      _isLoadingBanner = false;
    }
  }

  Future<void> loadInterstitial() async {
    if (_isLoadingInterstitial) return;
    if (_config.isProduction && _config.interstitialAdUnitId.isEmpty) {
      _interstitialState = AdState.unavailable;
      return;
    }

    _isLoadingInterstitial = true;
    _interstitialState = AdState.loading;
    unawaited(
      _analytics.logEvent(
        AnalyticsEventName.adLoadRequested,
        parameters: const <String, Object?>{'ad_type': 'interstitial'},
      ),
    );

    try {
      await InterstitialAd.load(
        adUnitId: _config.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _interstitialState = AdState.loaded;
            _isLoadingInterstitial = false;
            unawaited(
              _analytics.logEvent(
                AnalyticsEventName.adLoaded,
                parameters: const <String, Object?>{'ad_type': 'interstitial'},
              ),
            );
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                _interstitialAd = null;
                _interstitialState = AdState.completed;
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                _interstitialAd = null;
                _interstitialState = AdState.failed;
              },
            );
          },
          onAdFailedToLoad: (error) {
            _interstitialAd = null;
            _interstitialState = AdState.failed;
            _isLoadingInterstitial = false;
            unawaited(
              _analytics.logEvent(
                AnalyticsEventName.adLoadFailed,
                parameters: <String, Object?>{
                  'ad_type': 'interstitial',
                  'error_code': error.code,
                },
              ),
            );
          },
        ),
      );
    } catch (_) {
      _interstitialState = AdState.unavailable;
      _isLoadingInterstitial = false;
    }
  }

  Future<void> loadRewarded() async {
    if (_isLoadingRewarded) return;
    if (_config.isProduction && _config.rewardedAdUnitId.isEmpty) {
      _rewardedState = AdState.unavailable;
      return;
    }

    _isLoadingRewarded = true;
    _rewardedState = AdState.loading;
    unawaited(
      _analytics.logEvent(
        AnalyticsEventName.adLoadRequested,
        parameters: const <String, Object?>{'ad_type': 'rewarded'},
      ),
    );

    try {
      await RewardedAd.load(
        adUnitId: _config.rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _rewardedState = AdState.loaded;
            _isLoadingRewarded = false;
            unawaited(
              _analytics.logEvent(
                AnalyticsEventName.adLoaded,
                parameters: const <String, Object?>{'ad_type': 'rewarded'},
              ),
            );
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                _rewardedAd = null;
                _rewardedState = AdState.completed;
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                _rewardedAd = null;
                _rewardedState = AdState.failed;
              },
            );
          },
          onAdFailedToLoad: (error) {
            _rewardedAd = null;
            _rewardedState = AdState.failed;
            _isLoadingRewarded = false;
            unawaited(
              _analytics.logEvent(
                AnalyticsEventName.adLoadFailed,
                parameters: <String, Object?>{
                  'ad_type': 'rewarded',
                  'error_code': error.code,
                },
              ),
            );
          },
        ),
      );
    } catch (_) {
      _rewardedState = AdState.unavailable;
      _isLoadingRewarded = false;
    }
  }

  Future<bool> showInterstitial() async {
    final ad = _interstitialAd;
    if (ad == null ||
        _config.isProduction && _config.interstitialAdUnitId.isEmpty) {
      return false;
    }

    _interstitialState = AdState.showing;
    try {
      await ad.show();
      return true;
    } catch (_) {
      _interstitialState = AdState.failed;
      return false;
    }
  }

  Future<RewardedAdResult> showRewarded() async {
    final ad = _rewardedAd;
    if (ad == null ||
        _config.isProduction && _config.rewardedAdUnitId.isEmpty) {
      return RewardedAdResult.unavailable;
    }

    _rewardedState = AdState.showing;
    unawaited(
      _analytics.logEvent(
        AnalyticsEventName.rewardedStarted,
        parameters: const <String, Object?>{'reward_type': 'unknown'},
      ),
    );

    try {
      await ad.show(
        onUserEarnedReward: (ad, item) {
          _rewardedState = AdState.completed;
        },
      );
      final result = _rewardedState == AdState.completed
          ? RewardedAdResult.success
          : RewardedAdResult.cancelled;
      unawaited(
        _analytics.logEvent(
          result == RewardedAdResult.success
              ? AnalyticsEventName.rewardedCompleted
              : AnalyticsEventName.rewardedCancelled,
          parameters: <String, Object?>{
            'reward_type': 'unknown',
            'reward_result': result.name,
          },
        ),
      );
      return result;
    } catch (_) {
      _rewardedState = AdState.failed;
      unawaited(
        _analytics.logEvent(
          AnalyticsEventName.rewardedFailed,
          parameters: const <String, Object?>{'reward_type': 'unknown'},
        ),
      );
      return RewardedAdResult.failed;
    }
  }

  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
