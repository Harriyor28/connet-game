import 'dart:async';

import 'package:flutter/foundation.dart';

import 'analytics_event.dart';
import 'analytics_service.dart';

class ErrorMonitor {
  ErrorMonitor._();

  static AnalyticsService? _service;
  static FlutterExceptionHandler? _previousFlutterError;
  static bool Function(Object, StackTrace)? _previousPlatformError;

  static void install(AnalyticsService service) {
    if (_service != null) return;
    _service = service;
    _previousFlutterError = FlutterError.onError;
    FlutterError.onError = (details) {
      unawaited(
        service.recordError(
          details.exception,
          details.stack ?? StackTrace.empty,
          category: ErrorCategory.unknown,
        ),
      );
      _previousFlutterError?.call(details);
      if (kDebugMode && _previousFlutterError == null) {
        FlutterError.dumpErrorToConsole(details);
      }
    };

    _previousPlatformError = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (error, stack) {
      unawaited(
        service.recordError(
          error,
          stack,
          category: ErrorCategory.unknown,
          fatal: true,
        ),
      );
      return _previousPlatformError?.call(error, stack) ?? false;
    };
  }
}
