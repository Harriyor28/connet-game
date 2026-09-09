import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class VoiceManager {
  AudioPlayer? _player;
  bool _enabled = true;
  double _volume = 0.85;
  final Map<String, Timer> _cooldowns = {};

  AudioPlayer? _ensurePlayer() {
    try {
      _player ??= AudioPlayer();
      return _player;
    } on MissingPluginException {
      return null;
    } catch (_) {
      return null;
    }
  }

  void applySettings(bool enabled, double volume) {
    _enabled = enabled;
    _volume = volume.clamp(0.0, 1.0);
    final player = _ensurePlayer();
    if (player == null) return;

    () async {
      try {
        await player.setVolume(_enabled ? _volume : 0.0);
      } catch (_) {
        _player = null;
      }
    }();
  }

  Future<void> play(String eventKey, double volume) async {
    if (!_enabled) return;
    final player = _ensurePlayer();
    if (player == null) return;
    final safeVolume = volume.clamp(0.0, 1.0);
    final assetPath = 'audio/voice/$eventKey.mp3';
    if (_cooldowns.containsKey(eventKey)) return;

    try {
      await player.setSource(AssetSource(assetPath));
      await player.setVolume(safeVolume);
      await player.resume();
      _cooldowns[eventKey] = Timer(const Duration(milliseconds: 350), () {
        _cooldowns.remove(eventKey);
      });
    } catch (_) {
      _player = null;
      // Voice assets remain optional during this phase.
    }
  }

  Future<void> clear() async {
    for (final timer in _cooldowns.values) {
      timer.cancel();
    }
    _cooldowns.clear();
    final player = _ensurePlayer();
    if (player == null) return;
    try {
      await player.stop();
    } catch (_) {}
  }
}
