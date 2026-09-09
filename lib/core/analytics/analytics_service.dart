import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'analytics_config.dart';
import 'analytics_context.dart';
import 'analytics_event.dart';
import 'package:nexus_link/core/config/app_environment.dart';

abstract class AnalyticsService {
  Future<void> initialize();
  Future<void> logEvent(
    AnalyticsEventName name, {
    Map<String, Object?> parameters,
    AnalyticsContext? context,
  });
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    required ErrorCategory category,
    AnalyticsContext? context,
    bool fatal = false,
  });
  Future<void> setScreen(String screen);
  Future<void> setUserProperty(String name, String value);
  void setConsent(AnalyticsConsent consent);
}

class LocalAnalyticsService implements AnalyticsService {
  LocalAnalyticsService({AnalyticsConfig? config})
    : config = config ?? const AnalyticsConfig.development(),
      _consent = (config ?? const AnalyticsConfig.development()).consent;

  static final LocalAnalyticsService instance = LocalAnalyticsService(
    config: AppEnvironment.analyticsConfig,
  );
  static const _queueKey = 'analytics_event_queue';
  static const _sessionKey = 'analytics_session_id';

  final AnalyticsConfig config;
  final List<AnalyticsEvent> _events = <AnalyticsEvent>[];
  final List<Map<String, Object?>> _errors = <Map<String, Object?>>[];
  final Map<String, String> _userProperties = <String, String>{};
  AnalyticsConsent _consent;
  String? _sessionId;
  String? _currentScreen;
  bool _initialized = false;

  AnalyticsConsent get consent => _consent;

  bool get isInitialized => _initialized;
  String? get currentScreen => _currentScreen;
  String? get sessionId => _sessionId;
  List<AnalyticsEvent> get recentEvents => List.unmodifiable(_events);
  List<Map<String, Object?>> get recentErrors => List.unmodifiable(_errors);
  Map<String, String> get userProperties => Map.unmodifiable(_userProperties);

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _sessionId = prefs.getString(_sessionKey) ?? _newSessionId();
      await prefs.setString(_sessionKey, _sessionId!);
      final queued = prefs.getStringList(_queueKey) ?? <String>[];
      for (final encoded in queued) {
        try {
          final json = jsonDecode(encoded) as Map<String, dynamic>;
          final name = AnalyticsEventName.values.firstWhere(
            (value) => value.value == json['name'],
          );
          _events.add(
            AnalyticsEvent(
              name: name,
              parameters: Map<String, Object?>.from(
                (json['parameters'] as Map?)?.cast<String, Object?>() ??
                    <String, Object?>{},
              ),
              timestamp: DateTime.parse(json['timestamp'] as String),
            ),
          );
        } catch (_) {
          // Malformed diagnostics must never block startup.
        }
      }
      _initialized = true;
    } catch (error, stackTrace) {
      _initialized = true;
      if (kDebugMode) {
        debugPrint('Analytics initialization unavailable: $error\n$stackTrace');
      }
    }
  }

  @override
  Future<void> logEvent(
    AnalyticsEventName name, {
    Map<String, Object?> parameters = const <String, Object?>{},
    AnalyticsContext? context,
  }) async {
    if (!_allowsCollection) return;
    final merged = <String, Object?>{
      ...?context?.toParameters(),
      ...parameters,
      if (_currentScreen != null) 'current_screen': _currentScreen,
      if (_sessionId != null) 'session_id': _sessionId,
    };
    final event = AnalyticsEvent(
      name: name,
      parameters: _sanitize(merged),
      timestamp: DateTime.now(),
    );
    _events.add(event);
    while (_events.length > config.maxQueuedEvents) {
      _events.removeAt(0);
    }
    await _persistQueue();
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    required ErrorCategory category,
    AnalyticsContext? context,
    bool fatal = false,
  }) async {
    if (!_allowsCollection) return;
    final report = <String, Object?>{
      'category': category.name,
      'error': error.toString(),
      'stack': stackTrace.toString(),
      'fatal': fatal,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      ...?context?.toParameters(),
      if (_currentScreen != null) 'current_screen': _currentScreen,
      if (_sessionId != null) 'session_id': _sessionId,
    };
    _errors.add(_sanitize(report));
    while (_errors.length > config.maxQueuedEvents) {
      _errors.removeAt(0);
    }
    if (kDebugMode) debugPrint('[$category] $error\n$stackTrace');
  }

  @override
  Future<void> setScreen(String screen) async {
    _currentScreen = screen;
    await logEvent(
      AnalyticsEventName.screenViewed,
      parameters: <String, Object?>{'screen': screen},
    );
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    if (!_allowsCollection) return;
    _userProperties[name] = value;
  }

  @override
  void setConsent(AnalyticsConsent consent) {
    _consent = consent;
  }

  bool get _allowsCollection =>
      config.enabled &&
      (config.environment == AnalyticsEnvironment.development ||
          _consent == AnalyticsConsent.granted);

  String _newSessionId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${Object().hashCode}';

  Future<void> _persistQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _queueKey,
        _events.map((event) => jsonEncode(event.toJson())).toList(),
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          'Analytics queue persistence unavailable: $error\n$stackTrace',
        );
      }
    }
  }

  Map<String, Object?> _sanitize(Map<String, Object?> values) =>
      Map<String, Object?>.fromEntries(
        values.entries
            .where((entry) => entry.key.length <= 64)
            .map((entry) => MapEntry(entry.key, _sanitizeValue(entry.value))),
      );

  Object? _sanitizeValue(Object? value) {
    if (value is String) {
      return value.length > 256 ? value.substring(0, 256) : value;
    }
    if (value is num || value is bool || value == null) return value;
    return value.toString();
  }
}
