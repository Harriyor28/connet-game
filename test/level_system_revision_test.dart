import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexus_link/data/level_repository.dart';
import 'package:nexus_link/data/level_validator.dart';
import 'package:nexus_link/models/connection_model.dart';
import 'package:nexus_link/models/level_model.dart';
import 'package:nexus_link/models/level_result.dart';
import 'package:nexus_link/models/node_model.dart';
import 'package:nexus_link/progression/progression_manager.dart';

void main() {
  group('Progressive level catalog', () {
    final repository = LevelRepository();

    test('catalog exposes the actual authored campaign counts', () {
      expect(repository.getLevelCount(Difficulty.easy), 10);
      expect(repository.getLevelCount(Difficulty.medium), 10);
      expect(repository.getLevelCount(Difficulty.hard), 5);
      expect(repository.getLevelCount(Difficulty.professional), 3);
      expect(repository.getLevel('easy_001'), isNotNull);
      expect(repository.getLevel('professional_003'), isNotNull);
    });

    test('repository navigation stays within each difficulty sequence', () {
      expect(repository.getPreviousLevel('easy_002')?.id, 'easy_001');
      expect(repository.getNextLevel('easy_001')?.id, 'easy_002');
      expect(repository.getNextLevel('easy_010'), isNull);
      expect(repository.getNextLevel('medium_001')?.id, 'medium_002');
    });

    test('all current catalog levels pass integrity validation', () {
      final results = const LevelValidator().validateAll(
        repository.getAllLevels(),
      );
      final failures = results.where((result) => !result.isValid).toList();
      expect(
        failures,
        isEmpty,
        reason: failures
            .map((failure) {
              return '${failure.level.id}: ${failure.issues.join(', ')}';
            })
            .join('\n'),
      );
    });
  });

  group('Progression persistence', () {
    test(
      'initializes only easy level one and preserves best results',
      () async {
        SharedPreferences.setMockInitialValues(<String, Object>{});
        final repository = LevelRepository();
        final progression = ProgressionManager();
        await progression.load(repository);

        expect(progression.isUnlocked('easy_001'), isTrue);
        expect(progression.isUnlocked('easy_002'), isFalse);
        expect(progression.isUnlocked('medium_001'), isFalse);

        progression.recordResult(
          const LevelResult(
            levelId: 'easy_001',
            score: 100,
            stars: 2,
            moves: 5,
            timeSeconds: 20,
            mistakes: 0,
            isPerfect: false,
            combo: 3,
          ),
          repository,
        );
        await progression.save();
        expect(progression.isUnlocked('easy_002'), isTrue);
        expect(progression.progress.stars['easy_001'], 2);
        expect(progression.progress.bestCombos['easy_001'], 3);

        progression.recordResult(
          const LevelResult(
            levelId: 'easy_001',
            score: 120,
            stars: 3,
            moves: 4,
            timeSeconds: 15,
            mistakes: 0,
            isPerfect: true,
            combo: 4,
          ),
          repository,
        );
        await progression.save();
        expect(progression.progress.stars['easy_001'], 3);
        expect(progression.progress.perfectLevels, contains('easy_001'));

        final restored = ProgressionManager();
        await restored.load(repository);
        expect(restored.progress.stars['easy_001'], 3);
        expect(restored.progress.perfectLevels, contains('easy_001'));
        expect(restored.isUnlocked('easy_002'), isTrue);
      },
    );
    test('finishing a campaign unlocks the next difficulty campaign', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final repository = LevelRepository();
      final progression = ProgressionManager();
      await progression.load(repository);

      progression.recordResult(
        const LevelResult(
          levelId: 'easy_010',
          score: 100,
          stars: 1,
          moves: 10,
          timeSeconds: 50,
          mistakes: 1,
          isPerfect: false,
        ),
        repository,
      );

      expect(progression.isUnlocked('medium_001'), isTrue);
    });
  });

  test('validator reports missing required node references', () {
    final level = LevelModel(
      id: 'invalid_001',
      name: 'Invalid',
      difficulty: Difficulty.easy,
      world: 'neon_lab',
      levelNumber: 1,
      nodes: [NodeModel(id: 'A', normalizedX: .2, normalizedY: .2)],
      requiredConnections: [
        ConnectionModel(fromNodeId: 'A', toNodeId: 'missing'),
      ],
      allowedConnections: [
        ConnectionModel(fromNodeId: 'A', toNodeId: 'missing'),
      ],
      targetMoves: 1,
      targetTime: 10,
      starThresholds: const StarThresholds(
        oneStarMaxMoves: 1,
        twoStarMaxMoves: 1,
        threeStarMaxMoves: 1,
      ),
    );
    final result = const LevelValidator().validate(level).toList();
    expect(
      result.any((issue) => issue.message.contains('missing node')),
      isTrue,
    );
  });
}
