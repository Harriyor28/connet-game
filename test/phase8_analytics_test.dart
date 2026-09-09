import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexus_link/core/analytics/analytics_config.dart';
import 'package:nexus_link/core/analytics/analytics_context.dart';
import 'package:nexus_link/core/analytics/analytics_event.dart';
import 'package:nexus_link/core/analytics/analytics_service.dart';
import 'package:nexus_link/core/analytics/performance_diagnostics.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('analytics records structured events with safe context', () async {
    final service = LocalAnalyticsService(
      config: const AnalyticsConfig(
        environment: AnalyticsEnvironment.development,
        maxQueuedEvents: 2,
      ),
    );
    await service.initialize();

    await service.logEvent(
      AnalyticsEventName.levelStarted,
      context: const AnalyticsContext(
        screen: 'game',
        worldId: 2,
        levelId: 'medium_003',
        difficulty: 'medium',
        offline: true,
      ),
    );

    expect(service.recentEvents.single.name, AnalyticsEventName.levelStarted);
    expect(service.recentEvents.single.parameters['world_id'], 2);
    expect(service.recentEvents.single.parameters['offline'], isTrue);
  });

  test('production analytics requires granted consent', () async {
    final service = LocalAnalyticsService(
      config: const AnalyticsConfig.production(),
    );
    await service.initialize();
    await service.logEvent(AnalyticsEventName.levelStarted);
    expect(service.recentEvents, isEmpty);

    service.setConsent(AnalyticsConsent.granted);
    await service.logEvent(AnalyticsEventName.levelStarted);
    expect(service.recentEvents, hasLength(1));

    service.setConsent(AnalyticsConsent.denied);
    await service.logEvent(AnalyticsEventName.levelCompleted);
    expect(service.recentEvents, hasLength(1));
  });

  test('offline event queue remains bounded', () async {
    final service = LocalAnalyticsService(
      config: const AnalyticsConfig(
        environment: AnalyticsEnvironment.development,
        maxQueuedEvents: 2,
      ),
    );
    await service.initialize();
    await service.logEvent(AnalyticsEventName.appStart);
    await service.logEvent(AnalyticsEventName.appInitialized);
    await service.logEvent(AnalyticsEventName.sessionStarted);

    expect(service.recentEvents, hasLength(2));
    expect(service.recentEvents.first.name, AnalyticsEventName.appInitialized);
  });

  test('errors retain category and non-sensitive context', () async {
    final service = LocalAnalyticsService();
    await service.initialize();
    await service.recordError(
      StateError('level data unavailable'),
      StackTrace.current,
      category: ErrorCategory.levelLoading,
      context: const AnalyticsContext(levelId: 'easy_001', worldId: 1),
    );

    expect(service.recentErrors.single['category'], 'levelLoading');
    expect(service.recentErrors.single['level_id'], 'easy_001');
  });

  test('slow operations produce a performance diagnostic', () async {
    final service = LocalAnalyticsService();
    await service.initialize();
    final diagnostics = PerformanceDiagnostics(service);

    await diagnostics.measure<void>(
      'level_load',
      () async {},
      warningThreshold: Duration.zero,
    );

    expect(
      service.recentEvents.any(
        (event) => event.name == AnalyticsEventName.performanceIssue,
      ),
      isTrue,
    );
  });
}