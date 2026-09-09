import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class MusicManager {
  AudioPlayer? _player;
  bool _enabled = true;
  double _volume = 0.7;
  String _currentTrack = '';

  String get currentTrack => _currentTrack;

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
        if (!_enabled) {
          await player.stop();
        }
      } catch (_) {
        _player = null;
      }
    }();
  }

  Future<void> startTrack(String worldId, double volume) async {
    if (!_enabled) return;

    final player = _ensurePlayer();
    if (player == null) return;

    _currentTrack = worldId;
    _volume = volume.clamp(0.0, 1.0);
    final assetPath = 'audio/music/worlds/$worldId.mp3';

    try {
      await player.setSource(AssetSource(assetPath));
      await player.setReleaseMode(ReleaseMode.loop);
      await player.setVolume(_volume);
      await player.resume();
    } catch (_) {
      // Assets are optional during early development; ignore missing files.
    }
  }

  Future<void> stop() async {
    final player = _ensurePlayer();
    if (player == null) return;
    try {
      await player.stop();
    } catch (_) {}
  }

  Future<void> pause() async {
    final player = _ensurePlayer();
    if (player == null) return;
    try {
      await player.pause();
    } catch (_) {}
  }

  Future<void> resume() async {
    if (!_enabled) return;
    final player = _ensurePlayer();
    if (player == null) return;
    try {
      await player.resume();
    } catch (_) {}
  }
}
