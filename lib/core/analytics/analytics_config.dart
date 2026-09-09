enum AnalyticsEnvironment { development, production }

enum AnalyticsConsent { unknown, granted, denied }

class AnalyticsConfig {
  const AnalyticsConfig({
    required this.environment,
    this.enabled = true,
    this.consent = AnalyticsConsent.unknown,
    this.maxQueuedEvents = 100,
  });

  const AnalyticsConfig.development()
      : this(environment: AnalyticsEnvironment.development);

  const AnalyticsConfig.production()
      : this(
          environment: AnalyticsEnvironment.production,
          consent: AnalyticsConsent.unknown,
        );

  final AnalyticsEnvironment environment;
  final bool enabled;
  final AnalyticsConsent consent;
  final int maxQueuedEvents;

  bool get allowsCollection =>
      enabled &&
      (environment == AnalyticsEnvironment.development ||
          consent == AnalyticsConsent.granted);
}