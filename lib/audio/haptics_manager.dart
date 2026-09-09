import 'package:flutter/services.dart';

enum HapticsPattern { light, warning, milestone, success }

class HapticsManager {
  bool _enabled = true;

  void applySettings(bool enabled) {
    _enabled = enabled;
  }

  void trigger(HapticsPattern pattern) {
    if (!_enabled) return;

    switch (pattern) {
      case HapticsPattern.light:
        HapticFeedback.lightImpact();
        break;
      case HapticsPattern.warning:
        HapticFeedback.mediumImpact();
        break;
      case HapticsPattern.milestone:
        HapticFeedback.selectionClick();
        break;
      case HapticsPattern.success:
        HapticFeedback.heavyImpact();
        break;
    }
  }
}
