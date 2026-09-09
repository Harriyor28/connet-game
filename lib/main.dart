import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexus_link/app.dart';
import 'package:nexus_link/core/ads/ad_manager.dart';
import 'package:nexus_link/core/analytics/analytics_event.dart';
import 'package:nexus_link/core/analytics/analytics_service.dart';
import 'package:nexus_link/core/analytics/error_monitor.dart';

void main() {
  runZonedGuarded(_bootstrap, (error, stackTrace) {
    unawaited(
      LocalAnalyticsService.instance.recordError(
        error,
        stackTrace,
        category: ErrorCategory.unknown,
        fatal: true,
      ),
    );
  });
}

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final analytics = LocalAnalyticsService.instance;
  ErrorMonitor.install(analytics);
  unawaited(analytics.initialize());
  unawaited(analytics.logEvent(AnalyticsEventName.appStart));

  // Lock orientation to portrait for optimal mobile puzzle gameplay
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set immersive edge-to-edge system UI styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  unawaited(AdManager.initialize());
  unawaited(analytics.logEvent(AnalyticsEventName.appInitialized));
  unawaited(analytics.logEvent(AnalyticsEventName.sessionStarted));
  runApp(NexusLinkApp(analytics: analytics));
}
