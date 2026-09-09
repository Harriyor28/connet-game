import 'dart:async';

import 'audio_settings.dart';
import 'haptics_manager.dart';
import 'music_manager.dart';
import 'sfx_manager.dart';
import 'voice_manager.dart';

export 'audio_settings.dart';
export 'haptics_manager.dart';

/// Centralized audio facade for gameplay, UI, voice, and haptics.
class AudioManager {
  AudioManager._internal();
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;

  final MusicManager _music = MusicManager();
  final SfxManager _sfx = SfxManager();
  final VoiceManager _voice = VoiceManager();
  final HapticsManager _haptics = HapticsManager();

  bool _musicEnabled = true;
  bool _sfxEnabled = true;
  bool _voiceEnabled = true;
  bool _hapticsEnabled = true;
  double _musicVolume = 0.7;
  double _sfxVolume = 0.8;
  double _voiceVolume = 0.85;

  bool get musicEnabled => _musicEnabled;
  bool get sfxEnabled => _sfxEnabled;
  bool get voiceEnabled => _voiceEnabled;
  bool get hapticsEnabled => _hapticsEnabled;
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;
  double get voiceVolume => _voiceVolume;

  void configure(AudioSettings settings) {
    _musicEnabled = settings.musicEnabled;
    _sfxEnabled = settings.sfxEnabled;
    _voiceEnabled = settings.voiceEnabled;
    _hapticsEnabled = settings.hapticsEnabled;
    _musicVolume = settings.musicVolume.clamp(0.0, 1.0);
    _sfxVolume = settings.sfxVolume.clamp(0.0, 1.0);
    _voiceVolume = settings.voiceVolume.clamp(0.0, 1.0);

    _music.applySettings(_musicEnabled, _musicVolume);
    _sfx.applySettings(_sfxEnabled, _sfxVolume);
    _voice.applySettings(_voiceEnabled, _voiceVolume);
    _haptics.applySettings(_hapticsEnabled);
  }

  Future<void> init() async {
    _music.applySettings(_musicEnabled, _musicVolume);
    _sfx.applySettings(_sfxEnabled, _sfxVolume);
    _voice.applySettings(_voiceEnabled, _voiceVolume);
    _haptics.applySettings(_hapticsEnabled);
  }

  void playSfx(String eventKey) {
    if (!_sfxEnabled) return;
    _sfx.play(eventKey, _sfxVolume);
  }

  void playConnectionSound() => playSfx('connection_valid');

  void playInvalidSound() => playSfx('connection_invalid');

  void playVictorySound() => playSfx('level_complete');

  void playComboSound(int comboLevel) {
    if (!_sfxEnabled) return;
    final event = comboLevel >= 10
        ? 'combo_major'
        : comboLevel >= 5
        ? 'combo_milestone'
        : comboLevel >= 3
        ? 'combo_enhanced'
        : 'combo_basic';
    _sfx.play(event, _sfxVolume);
  }

  void playButtonSound() => playSfx('ui_button');

  void playAchievementSound() => playSfx('achievement_unlock');

  void playWorldUnlockSound() => playSfx('world_unlock');

  void playLevelFailedSound() => playSfx('level_failed');

  void playNewRecordSound() => playSfx('new_record');

  void playVoice(String eventKey) {
    if (!_voiceEnabled) return;
    _voice.play(eventKey, _voiceVolume);
  }

  void playNarration(String message) =>
      playVoice(message.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_'));

  void startWorldMusic(String worldId) {
    if (!_musicEnabled) return;
    _music.startTrack(worldId, _musicVolume);
  }

  void stopMusic() => _music.stop();

  void pauseMusic() => _music.pause();

  void resumeMusic() => _music.resume();

  void triggerHaptic(HapticsPattern pattern) {
    if (!_hapticsEnabled) return;
    _haptics.trigger(pattern);
  }

  void dispose() {
    _music.stop();
    _voice.clear();
  }
}
