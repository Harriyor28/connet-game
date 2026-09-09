import 'analytics_event.dart';
import 'analytics_context.dart';
import 'analytics_service.dart';

class PerformanceDiagnostics {
  const PerformanceDiagnostics(this.analytics);

  final AnalyticsService analytics;

  Future<T> measure<T>(
    String operation,
    Future<T> Function() action, {
    Duration warningThreshold = const Duration(milliseconds: 500),
    AnalyticsContext? context,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      return await action();
    } finally {
      stopwatch.stop();
      if (stopwatch.elapsed >= warningThreshold) {
        await analytics.logEvent(
          AnalyticsEventName.performanceIssue,
          parameters: <String, Object?>{
            'operation': operation,
            'duration_ms': stopwatch.elapsedMilliseconds,
          },
          context: context,
        );
      }
    }
  }
}
