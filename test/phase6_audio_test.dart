import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_link/audio/audio_manager.dart';
import 'package:nexus_link/managers/settings_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Phase 6 audio system', () {
    test(
      'audio settings persist music, sfx, voice, and haptics values',
      () async {
        final settings = SettingsManager();
        await settings.load();

        settings.setMusicEnabled(false);
        settings.setMusicVolume(0.55);
        settings.setSfxEnabled(false);
        settings.setSfxVolume(0.65);
        settings.setVoiceEnabled(true);
        settings.setVoiceVolume(0.75);
        settings.setHapticsEnabled(true);

        expect(settings.musicEnabled, isFalse);
        expect(settings.musicVolume, closeTo(0.55, 0.0001));
        expect(settings.sfxEnabled, isFalse);
        expect(settings.sfxVolume, closeTo(0.65, 0.0001));
        expect(settings.voiceEnabled, isTrue);
        expect(settings.voiceVolume, closeTo(0.75, 0.0001));
        expect(settings.hapticsEnabled, isTrue);
      },
    );

    test('audio manager can configure state without throwing', () async {
      final audio = AudioManager();
      final settings = AudioSettings(
        musicEnabled: true,
        musicVolume: 0.5,
        sfxEnabled: true,
        sfxVolume: 0.6,
        voiceEnabled: true,
        voiceVolume: 0.7,
        hapticsEnabled: true,
      );

      expect(() => audio.configure(settings), returnsNormally);
      expect(() => audio.playSfx('connection_valid'), returnsNormally);
      expect(() => audio.playVoice('level_complete'), returnsNormally);
      expect(() => audio.startWorldMusic('neon_lab'), returnsNormally);
      expect(() => audio.stopMusic(), returnsNormally);
    });
  });
}
