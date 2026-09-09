import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_link/managers/achievement_manager.dart';
import 'package:nexus_link/managers/player_statistics.dart';
import 'package:nexus_link/managers/settings_manager.dart';
import 'package:nexus_link/world/world_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  group('Phase 5 UX data layer', () {
    test('settings persist quality and toggles locally', () async {
      final settings = SettingsManager();
      await settings.load();
      settings.setAudioEnabled(false);
      settings.setMusicEnabled(false);
      settings.setEffectsEnabled(true);
      settings.setGraphicsQuality(GraphicsQuality.high);
      settings.setVibrationEnabled(true);

      expect(settings.audioEnabled, isFalse);
      expect(settings.musicEnabled, isFalse);
      expect(settings.effectsEnabled, isTrue);
      expect(settings.graphicsQuality, GraphicsQuality.high);
      expect(settings.vibrationEnabled, isTrue);
    });

    test('player statistics aggregate progression values', () {
      final stats = PlayerStatistics(
        levelsCompleted: 48,
        totalStars: 123,
        bestScore: 8450,
        perfectLevels: 21,
        highestCombo: 12,
        fastestLevelSeconds: 18,
      );

      expect(stats.levelsCompleted, 48);
      expect(stats.totalStars, 123);
      expect(stats.bestScore, 8450);
      expect(stats.perfectLevels, 21);
      expect(stats.highestCombo, 12);
      expect(stats.fastestLevelSeconds, 18);
    });

    test('achievement manager exposes phase-5 unlock states', () {
      final achievement = AchievementManager();

      expect(achievement.achievements.length, greaterThanOrEqualTo(4));
      expect(
        achievement.achievements.any((item) => item.id == 'first_connection'),
        isTrue,
      );
      expect(
        achievement.achievements.any((item) => item.id == 'combo_master'),
        isTrue,
      );
    });

    test('world registry still exposes real world metadata', () {
      final worlds = WorldManager().allWorlds;
      expect(worlds.any((world) => world.id == 1), isTrue);
      expect(worlds.any((world) => world.name == 'Neon Lab'), isTrue);
      expect(worlds.any((world) => world.name == 'Space'), isTrue);
    });
  });
}
