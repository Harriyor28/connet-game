import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class SfxManager {
  AudioPlayer? _player;
  bool _enabled = true;
  double _volume = 0.8;

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
    final assetPath = 'audio/sfx/$eventKey.wav';

    try {
      await player.setSource(AssetSource(assetPath));
      await player.setVolume(safeVolume);
      await player.resume();
    } catch (_) {
      _player = null;
      // Missing asset: keep gameplay stable and silent in early prototype builds.
    }
  }
}
