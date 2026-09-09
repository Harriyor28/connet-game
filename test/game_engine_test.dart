import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_link/game/connection_validator.dart';
import 'package:nexus_link/game/game_engine.dart';
import 'package:nexus_link/game/score_calculator.dart';
import 'package:nexus_link/game/star_calculator.dart';
import 'package:nexus_link/models/connection_model.dart';
import 'package:nexus_link/models/game_state.dart';
import 'package:nexus_link/models/level_model.dart';
import 'package:nexus_link/models/node_model.dart';

void main() {
  group('ConnectionValidator', () {
    late ConnectionValidator validator;
    late LevelModel testLevel;
    late GameState state;

    setUp(() {
      validator = ConnectionValidator();
      testLevel = LevelModel(
        id: 'test_1',
        name: 'Test Level',
        difficulty: Difficulty.easy,
        world: 'neon_lab',
        levelNumber: 1,
        nodes: [
          NodeModel(id: 'A', normalizedX: 0.2, normalizedY: 0.2, requiredConnections: 1),
          NodeModel(id: 'B', normalizedX: 0.8, normalizedY: 0.2, requiredConnections: 2),
          NodeModel(id: 'C', normalizedX: 0.5, normalizedY: 0.8, requiredConnections: 1),
        ],
        requiredConnections: [
          ConnectionModel(fromNodeId: 'A', toNodeId: 'B'),
          ConnectionModel(fromNodeId: 'B', toNodeId: 'C'),
        ],
        allowedConnections: [
          ConnectionModel(fromNodeId: 'A', toNodeId: 'B'),
          ConnectionModel(fromNodeId: 'B', toNodeId: 'C'),
        ],
        targetMoves: 2,
        targetTime: 30,
        starThresholds: const StarThresholds(
          oneStarMaxMoves: 10,
          twoStarMaxMoves: 5,
          threeStarMaxMoves: 2,
        ),
      );
      state = GameState.fromLevel(testLevel);
    });

    test('Self-connection is rejected', () {
      final res = validator.validate(state, 'A', 'A');
      expect(res, ValidationResult.selfConnection);
    });

    test('Non-existent node is rejected', () {
      final res = validator.validate(state, 'A', 'Z');
      expect(res, ValidationResult.nodeNotFound);
    });

    test('Valid allowed connection succeeds', () {
      final res = validator.validate(state, 'A', 'B');
      expect(res, ValidationResult.valid);
    });

    test('Disallowed connection is rejected', () {
      final res = validator.validate(state, 'A', 'C');
      expect(res, ValidationResult.notAllowed);
    });

    test('Duplicate connection is rejected', () {
      state.activeConnections.add(
        ConnectionModel(fromNodeId: 'A', toNodeId: 'B', isLocked: true),
      );
      final res = validator.validate(state, 'A', 'B');
      expect(res, ValidationResult.alreadyConnected);
    });
  });

  group('GameEngine & Level Progression', () {
    late GameEngine engine;
    late LevelModel testLevel;

    setUp(() {
      testLevel = LevelModel(
        id: 'test_1',
        name: 'Triangle Link',
        difficulty: Difficulty.easy,
        world: 'neon_lab',
        levelNumber: 1,
        nodes: [
          NodeModel(id: 'A', normalizedX: 0.2, normalizedY: 0.2, requiredConnections: 2),
          NodeModel(id: 'B', normalizedX: 0.8, normalizedY: 0.2, requiredConnections: 2),
          NodeModel(id: 'C', normalizedX: 0.5, normalizedY: 0.8, requiredConnections: 2),
        ],
        requiredConnections: [
          ConnectionModel(fromNodeId: 'A', toNodeId: 'B'),
          ConnectionModel(fromNodeId: 'B', toNodeId: 'C'),
        ],
        allowedConnections: [
          ConnectionModel(fromNodeId: 'A', toNodeId: 'B'),
          ConnectionModel(fromNodeId: 'B', toNodeId: 'C'),
          ConnectionModel(fromNodeId: 'A', toNodeId: 'C'),
        ],
        targetMoves: 2,
        targetTime: 30,
        starThresholds: const StarThresholds(
          oneStarMaxMoves: 10,
          twoStarMaxMoves: 5,
          threeStarMaxMoves: 2,
        ),
      );
      engine = GameEngine();
      engine.loadLevel(testLevel);
    });

    test('Initial state is correctly configured', () {
      expect(engine.isPlaying, isTrue);
      expect(engine.state?.moveCount, equals(0));
      expect(engine.state?.activeConnections.length, equals(0));
      expect(engine.state?.nodes.length, equals(3));
    });

    test('Successful drag and connection', () {
      final started = engine.startDrag('A');
      expect(started, isTrue);
      expect(engine.state?.activeNodeId, equals('A'));

      final result = engine.attemptConnection('B');
      expect(result, equals(ConnectionResult.success));
      expect(engine.state?.activeConnections.length, equals(1));
      expect(engine.state?.moveCount, equals(1));
    });

    test('Completing all required connections marks level complete', () {
      bool levelCompletedTriggered = false;
      engine = GameEngine(
        onLevelComplete: () {
          levelCompletedTriggered = true;
        },
      );
      engine.loadLevel(testLevel);

      engine.startDrag('A');
      engine.attemptConnection('B');

      engine.startDrag('B');
      engine.attemptConnection('C');

      expect(levelCompletedTriggered, isTrue);
      expect(engine.state?.playState, equals(PlayState.completed));
      final result = engine.getResult();
      expect(result, isNotNull);
      expect(result?.stars, equals(3));
      expect(result?.isPerfect, isTrue);
    });

    test('Reset resets state', () {
      engine.startDrag('A');
      engine.attemptConnection('B');
      expect(engine.state?.activeConnections.length, equals(1));

      engine.resetLevel();
      expect(engine.state?.activeConnections.length, equals(0));
      expect(engine.state?.moveCount, equals(0));
    });
  });

  group('Calculators', () {
    test('StarCalculator returns expected stars based on moves', () {
      final starCalc = StarCalculator();
      const thresholds = StarThresholds(
        oneStarMaxMoves: 10,
        twoStarMaxMoves: 5,
        threeStarMaxMoves: 2,
      );
      expect(starCalc.calculate(moves: 2, thresholds: thresholds), equals(3));
      expect(starCalc.calculate(moves: 3, thresholds: thresholds), equals(2));
      expect(starCalc.calculate(moves: 8, thresholds: thresholds), equals(1));
    });

    test('ScoreCalculator awards bonuses appropriately', () {
      final scoreCalc = ScoreCalculator();
      final scorePerfect = scoreCalc.calculate(
        moves: 2,
        mistakes: 0,
        combo: 2,
        maxCombo: 2,
        elapsedSeconds: 10,
        targetMoves: 2,
        targetTime: 30,
      );
      final scoreSlow = scoreCalc.calculate(
        moves: 4,
        mistakes: 2,
        combo: 0,
        maxCombo: 0,
        elapsedSeconds: 50,
        targetMoves: 2,
        targetTime: 30,
      );
      expect(scorePerfect, greaterThan(scoreSlow));
    });
  });
}
