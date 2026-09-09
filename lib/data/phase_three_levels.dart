import 'phase_one_levels.dart';

/// Offline authored catalog for Phase 3 progression tests.
class PhaseThreeLevels {
  static List<Map<String, dynamic>> get all {
    return [
      ...PhaseOneLevels.all,
      ..._generatedLevels(
        difficulty: 'easy',
        startNumber: 6,
        count: 5,
        nodeCount: 6,
        targetTime: 55,
        targetMoves: 5,
        maximumMistakes: 4,
      ),
      ..._generatedLevels(
        difficulty: 'medium',
        startNumber: 1,
        count: 10,
        nodeCount: 8,
        targetTime: 55,
        targetMoves: 7,
        maximumMistakes: 3,
      ),
      ..._generatedLevels(
        difficulty: 'hard',
        startNumber: 1,
        count: 5,
        nodeCount: 11,
        targetTime: 65,
        targetMoves: 10,
        maximumMistakes: 2,
      ),
      ..._generatedLevels(
        difficulty: 'professional',
        startNumber: 1,
        count: 3,
        nodeCount: 14,
        targetTime: 70,
        targetMoves: 13,
        maximumMistakes: 1,
        specialMechanics: ['precision_links'],
      ),
    ];
  }

  static List<Map<String, dynamic>> _generatedLevels({
    required String difficulty,
    required int startNumber,
    required int count,
    required int nodeCount,
    required int targetTime,
    required int targetMoves,
    required int maximumMistakes,
    List<String> specialMechanics = const [],
  }) {
    return List.generate(count, (index) {
      final levelNumber = startNumber + index;
      final id = '${difficulty}_${levelNumber.toString().padLeft(3, '0')}';
      final required = List.generate(
        nodeCount - 1,
        (connectionIndex) => {
          'from': 'n${connectionIndex + 1}',
          'to': 'n${connectionIndex + 2}',
        },
      );
      final optional = <Map<String, String>>[
        if (nodeCount > 4) {'from': 'n1', 'to': 'n3'},
        if (nodeCount > 6) {'from': 'n3', 'to': 'n5'},
        if (nodeCount > 8) {'from': 'n2', 'to': 'n5'},
      ];

      return {
        'id': id,
        'name': _nameFor(difficulty, levelNumber),
        'difficulty': difficulty,
        'world': 'neon_lab',
        'worldId': 1,
        'themeId': 'neon_lab',
        'environmentId': 'prototype',
        'levelNumber': levelNumber,
        'nodes': List.generate(nodeCount, (nodeIndex) {
          final isEndpoint = nodeIndex == 0 || nodeIndex == nodeCount - 1;
          return {
            'id': 'n${nodeIndex + 1}',
            'x': _xFor(nodeIndex, nodeCount),
            'y': _yFor(nodeIndex, nodeCount, index),
            'z': ((nodeIndex + index) % 5 - 2) / 12,
            'requiredConnections': isEndpoint ? 1 : 2,
          };
        }),
        'requiredConnections': required,
        'allowedConnections': [...required, ...optional],
        'optionalConnections': optional,
        'targetMoves': targetMoves + (index ~/ 3),
        'targetTime': targetTime + index * 3,
        'maximumMistakes': maximumMistakes,
        'specialMechanics': specialMechanics,
        'scoreMultiplier': _multiplierFor(difficulty),
        'unlockRule': levelNumber == 1 ? 'difficulty_gate' : 'previous_level',
        'stars': {
          'one': {'maxMoves': targetMoves + 3 + (index ~/ 3)},
          'two': {
            'maxMoves': targetMoves + 1 + (index ~/ 3),
            'maxTime': targetTime + index * 3,
          },
          'three': {'maxMoves': targetMoves + (index ~/ 3), 'maxMistakes': 0},
        },
      };
    });
  }

  static String _nameFor(String difficulty, int number) {
    final prefix = switch (difficulty) {
      'easy' => 'Guided Link',
      'medium' => 'Circuit Weave',
      'hard' => 'Fracture Grid',
      _ => 'Precision Core',
    };
    return '$prefix ${number.toString().padLeft(2, '0')}';
  }

  static double _xFor(int index, int count) {
    final columns = count <= 8 ? 4 : 5;
    return 0.16 + (index % columns) * (0.68 / (columns - 1));
  }

  static double _yFor(int index, int count, int variant) {
    final rows = (count / (count <= 8 ? 4 : 5)).ceil();
    final row = index ~/ (count <= 8 ? 4 : 5);
    final offset = ((row + variant) % 2) * 0.06;
    return 0.20 + row * (0.58 / (rows - 1).clamp(1, 99)) + offset;
  }

  static double _multiplierFor(String difficulty) {
    return switch (difficulty) {
      'easy' => 1.0,
      'medium' => 1.25,
      'hard' => 1.5,
      _ => 1.85,
    };
  }
}
