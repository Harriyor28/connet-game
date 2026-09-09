import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nexus_link/audio/audio_manager.dart';

enum GraphicsQuality { auto, low, medium, high }

class SettingsManager extends ChangeNotifier {
  SettingsManager._internal();
  static final SettingsManager _instance = SettingsManager._internal();
  factory SettingsManager() => _instance;

  static const String _audioKey = 'settings_audio';
  static const String _musicKey = 'settings_music';
  static const String _effectsKey = 'settings_effects';
  static const String _sfxKey = 'settings_sfx';
  static const String _voiceKey = 'settings_voice';
  static const String _vibrationKey = 'settings_vibration';
  static const String _hapticsKey = 'settings_haptics';
  static const String _musicVolumeKey = 'settings_music_volume';
  static const String _sfxVolumeKey = 'settings_sfx_volume';
  static const String _voiceVolumeKey = 'settings_voice_volume';
  static const String _graphicsKey = 'settings_graphics';

  bool _audioEnabled = true;
  bool _musicEnabled = true;
  bool _effectsEnabled = true;
  bool _sfxEnabled = true;
  bool _voiceEnabled = true;
  bool _vibrationEnabled = true;
  bool _hapticsEnabled = true;
  double _musicVolume = 0.7;
  double _sfxVolume = 0.8;
  double _voiceVolume = 0.85;
  GraphicsQuality _graphicsQuality = GraphicsQuality.auto;

  bool get audioEnabled => _audioEnabled;
  bool get musicEnabled => _musicEnabled;
  bool get effectsEnabled => _effectsEnabled;
  bool get sfxEnabled => _sfxEnabled;
  bool get voiceEnabled => _voiceEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get hapticsEnabled => _hapticsEnabled;
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;
  double get voiceVolume => _voiceVolume;
  GraphicsQuality get graphicsQuality => _graphicsQuality;

  AudioSettings get audioSettings => AudioSettings(
    musicEnabled: _audioEnabled && _musicEnabled,
    musicVolume: _musicVolume,
    sfxEnabled: _audioEnabled && _sfxEnabled,
    sfxVolume: _sfxVolume,
    voiceEnabled: _audioEnabled && _voiceEnabled,
    voiceVolume: _voiceVolume,
    hapticsEnabled: _audioEnabled && _hapticsEnabled,
  );

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _audioEnabled = prefs.getBool(_audioKey) ?? true;
    _musicEnabled = prefs.getBool(_musicKey) ?? true;
    _effectsEnabled = prefs.getBool(_effectsKey) ?? true;
    _sfxEnabled = prefs.getBool(_sfxKey) ?? _effectsEnabled;
    _voiceEnabled = prefs.getBool(_voiceKey) ?? true;
    _vibrationEnabled = prefs.getBool(_vibrationKey) ?? true;
    _hapticsEnabled = prefs.getBool(_hapticsKey) ?? _vibrationEnabled;
    _musicVolume = prefs.getDouble(_musicVolumeKey) ?? 0.7;
    _sfxVolume = prefs.getDouble(_sfxVolumeKey) ?? 0.8;
    _voiceVolume = prefs.getDouble(_voiceVolumeKey) ?? 0.85;

    final stored = prefs.getString(_graphicsKey);
    _graphicsQuality = GraphicsQuality.values.firstWhere(
      (quality) => quality.name == stored,
      orElse: () => GraphicsQuality.auto,
    );

    try {
      AudioManager().configure(audioSettings);
    } on MissingPluginException {
      // Audio plugin is not available in test environments.
    } catch (_) {
      // Fail gracefully in unsupported or mocked runtime contexts.
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_audioKey, _audioEnabled);
    await prefs.setBool(_musicKey, _musicEnabled);
    await prefs.setBool(_effectsKey, _effectsEnabled);
    await prefs.setBool(_sfxKey, _sfxEnabled);
    await prefs.setBool(_voiceKey, _voiceEnabled);
    await prefs.setBool(_vibrationKey, _vibrationEnabled);
    await prefs.setBool(_hapticsKey, _hapticsEnabled);
    await prefs.setDouble(_musicVolumeKey, _musicVolume);
    await prefs.setDouble(_sfxVolumeKey, _sfxVolume);
    await prefs.setDouble(_voiceVolumeKey, _voiceVolume);
    await prefs.setString(_graphicsKey, _graphicsQuality.name);
    try {
      AudioManager().configure(audioSettings);
    } on MissingPluginException {
      // Audio plugin is not available in test environments.
    } catch (_) {
      // Fail gracefully in unsupported or mocked runtime contexts.
    }
    notifyListeners();
  }

  Future<void> setAudioEnabled(bool value) async {
    _audioEnabled = value;
    await _persist();
  }

  Future<void> setMusicEnabled(bool value) async {
    _musicEnabled = value;
    _effectsEnabled = value;
    await _persist();
  }

  Future<void> setEffectsEnabled(bool value) async {
    _effectsEnabled = value;
    _sfxEnabled = value;
    await _persist();
  }

  Future<void> setSfxEnabled(bool value) async {
    _sfxEnabled = value;
    await _persist();
  }

  Future<void> setVoiceEnabled(bool value) async {
    _voiceEnabled = value;
    await _persist();
  }

  Future<void> setVibrationEnabled(bool value) async {
    _vibrationEnabled = value;
    _hapticsEnabled = value;
    await _persist();
  }

  Future<void> setHapticsEnabled(bool value) async {
    _hapticsEnabled = value;
    await _persist();
  }

  Future<void> setMusicVolume(double value) async {
    _musicVolume = value.clamp(0.0, 1.0);
    await _persist();
  }

  Future<void> setSfxVolume(double value) async {
    _sfxVolume = value.clamp(0.0, 1.0);
    await _persist();
  }

  Future<void> setVoiceVolume(double value) async {
    _voiceVolume = value.clamp(0.0, 1.0);
    await _persist();
  }

  Future<void> setGraphicsQuality(GraphicsQuality value) async {
    _graphicsQuality = value;
    await _persist();
  }
}
