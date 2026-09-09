import 'package:nexus_link/models/node_model.dart';
import 'package:nexus_link/models/connection_model.dart';
import 'package:nexus_link/world/obstacle_definition.dart';

/// Star thresholds for a level.
class StarThresholds {
  final int oneStarMaxMoves;
  final int twoStarMaxMoves;
  final int threeStarMaxMoves;
  final int twoStarMaxTime;
  final int threeStarMaxMistakes;

  const StarThresholds({
    required this.oneStarMaxMoves,
    required this.twoStarMaxMoves,
    required this.threeStarMaxMoves,
    this.twoStarMaxTime = 0,
    this.threeStarMaxMistakes = 0,
  });

  factory StarThresholds.fromJson(Map<String, dynamic> json) {
    return StarThresholds(
      oneStarMaxMoves: json['one']?['maxMoves'] as int? ?? 99,
      twoStarMaxMoves: json['two']?['maxMoves'] as int? ?? 10,
      threeStarMaxMoves: json['three']?['maxMoves'] as int? ?? 5,
      twoStarMaxTime: json['two']?['maxTime'] as int? ?? 0,
      threeStarMaxMistakes: json['three']?['maxMistakes'] as int? ?? 0,
    );
  }
}

/// Difficulty enum.
enum Difficulty { easy, medium, hard, professional }

/// Complete definition of a puzzle level.
class LevelModel {
  final String id;
  final String name;
  final String description;
  final Difficulty difficulty;
  final String world;
  final int worldId;
  final String themeId;
  final String environmentId;
  final int levelNumber;
  final List<NodeModel> nodes;
  final List<ConnectionModel> requiredConnections;
  final List<ConnectionModel> allowedConnections;
  final List<ConnectionModel> optionalConnections;
  final int targetMoves;
  final int maximumMoves;
  final int targetTime; // seconds
  final int maximumMistakes;
  final List<String> specialMechanics;
  final int baseScore;
  final double scoreMultiplier;
  final double comboMultiplier;
  final String music;
  final String background;
  final String lightingPreset;
  final String cameraPreset;
  final bool tutorialEnabled;
  final Map<String, Object?> difficultyModifiers;
  final List<String> completionEffects;
  final int availableHints;
  final String? perfectSolution;
  final Map<String, Object?> unlockRequirement;
  final String unlockRule;
  final StarThresholds starThresholds;
  final List<ObstacleDefinition> obstacles;

  const LevelModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.difficulty,
    required this.world,
    this.worldId = 1,
    this.themeId = 'neon_lab',
    this.environmentId = 'prototype',
    required this.levelNumber,
    required this.nodes,
    required this.requiredConnections,
    required this.allowedConnections,
    this.optionalConnections = const [],
    required this.targetMoves,
    int? maximumMoves,
    required this.targetTime,
    this.maximumMistakes = 3,
    this.specialMechanics = const [],
    this.baseScore = 1000,
    this.scoreMultiplier = 1.0,
    this.comboMultiplier = 1.0,
    this.music = '',
    this.background = '',
    this.lightingPreset = '',
    this.cameraPreset = '',
    this.tutorialEnabled = false,
    this.difficultyModifiers = const {},
    this.completionEffects = const [],
    this.availableHints = 0,
    this.perfectSolution,
    this.unlockRequirement = const {'type': 'previous_level'},
    this.unlockRule = 'previous_level',
    required this.starThresholds,
    this.obstacles = const [],
  }) : maximumMoves = maximumMoves ?? targetMoves + 3;

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      difficulty: Difficulty.values.firstWhere(
        (e) => e.name == (json['difficulty'] as String),
        orElse: () => Difficulty.easy,
      ),
      world: json['world'] as String? ?? 'neon_lab',
      worldId: json['worldId'] as int? ?? 1,
      themeId: json['themeId'] as String? ?? 'neon_lab',
      environmentId: json['environmentId'] as String? ?? 'prototype',
      levelNumber: json['levelNumber'] as int? ?? 1,
      nodes: (json['nodes'] as List)
          .map((n) => NodeModel.fromJson(n as Map<String, dynamic>))
          .toList(),
      requiredConnections: (json['requiredConnections'] as List)
          .map((c) => ConnectionModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      allowedConnections: (json['allowedConnections'] as List)
          .map((c) => ConnectionModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      optionalConnections: ((json['optionalConnections'] as List?) ?? [])
          .map((c) => ConnectionModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      targetMoves: json['targetMoves'] as int? ?? 10,
      maximumMoves: json['maximumMoves'] as int?,
      targetTime: json['targetTime'] as int? ?? 60,
      maximumMistakes: json['maximumMistakes'] as int? ?? 3,
      specialMechanics: ((json['specialMechanics'] as List?) ?? [])
          .map((mechanic) => mechanic.toString())
          .toList(),
      baseScore: json['baseScore'] as int? ?? 1000,
      scoreMultiplier: (json['scoreMultiplier'] as num?)?.toDouble() ?? 1.0,
      comboMultiplier: (json['comboMultiplier'] as num?)?.toDouble() ?? 1.0,
      music: json['music'] as String? ?? '',
      background: json['background'] as String? ?? '',
      lightingPreset: json['lightingPreset'] as String? ?? '',
      cameraPreset: json['cameraPreset'] as String? ?? '',
      tutorialEnabled: json['tutorialEnabled'] as bool? ?? false,
      difficultyModifiers: Map<String, Object?>.from(
        (json['difficultyModifiers'] as Map?)?.cast<String, Object?>() ??
            const {},
      ),
      completionEffects: ((json['completionEffects'] as List?) ?? [])
          .map((effect) => effect.toString())
          .toList(),
      availableHints: json['availableHints'] as int? ?? 0,
      perfectSolution: json['perfectSolution'] as String?,
      unlockRequirement: Map<String, Object?>.from(
        (json['unlockRequirement'] as Map?)?.cast<String, Object?>() ??
            {'type': json['unlockRule'] as String? ?? 'previous_level'},
      ),
      unlockRule: json['unlockRule'] as String? ?? 'previous_level',
      starThresholds: StarThresholds.fromJson(
        json['stars'] as Map<String, dynamic>? ?? {},
      ),
      obstacles: (json['obstacles'] as List<dynamic>? ?? const [])
          .map(
            (item) => ObstacleDefinition.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  @override
  String toString() => 'LevelModel($id, $name, $difficulty)';
}
