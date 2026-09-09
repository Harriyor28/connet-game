import 'package:nexus_link/core/ads/ad_config.dart';
import 'package:nexus_link/core/analytics/analytics_config.dart';

enum AppEnvironmentName { development, staging, production }

class AppEnvironment {
  const AppEnvironment._();

  static AppEnvironmentName get name => switch (_environmentFromDefine) {
    'production' => AppEnvironmentName.production,
    'staging' => AppEnvironmentName.staging,
    _ => AppEnvironmentName.development,
  };

  static bool get isProduction => name == AppEnvironmentName.production;

  static AdConfig get adConfig =>
      isProduction ? AdConfig.production() : AdConfig.development();

  static AnalyticsConfig get analyticsConfig => isProduction
      ? const AnalyticsConfig.production()
      : const AnalyticsConfig.development();
}

const String _environmentFromDefine = String.fromEnvironment(
  'NEXUS_LINK_ENV',
  defaultValue: 'development',
);
