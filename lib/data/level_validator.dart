import 'package:nexus_link/models/level_model.dart';

class LevelValidationIssue {
  const LevelValidationIssue(this.message);

  final String message;

  @override
  String toString() => message;
}

class LevelValidationResult {
  const LevelValidationResult({required this.level, required this.issues});

  final LevelModel level;
  final List<LevelValidationIssue> issues;

  bool get isValid => issues.isEmpty;
}

/// Development/test validator for authored level integrity.
class LevelValidator {
  const LevelValidator();

  List<LevelValidationResult> validateAll(Iterable<LevelModel> levels) {
    final seenIds = <String>{};
    return levels
        .map((level) {
          final issues = validate(level).toList();
          if (!seenIds.add(level.id)) {
            issues.add(LevelValidationIssue('Duplicate level ID: ${level.id}'));
          }
          return LevelValidationResult(level: level, issues: issues);
        })
        .toList(growable: false);
  }

  Iterable<LevelValidationIssue> validate(LevelModel level) sync* {
    final nodeIds = level.nodes.map((node) => node.id).toSet();
    if (nodeIds.length != level.nodes.length) {
      yield const LevelValidationIssue('Duplicate node ID');
    }
    for (final node in level.nodes) {
      if (node.normalizedX < 0 ||
          node.normalizedX > 1 ||
          node.normalizedY < 0 ||
          node.normalizedY > 1 ||
          node.normalizedZ < -1 ||
          node.normalizedZ > 1) {
        yield LevelValidationIssue(
          'Node ${node.id} is outside normalized bounds',
        );
      }
    }

    final allowed = level.allowedConnections
        .map((connection) => connection.key)
        .toSet();
    final required = <String>{};
    for (final connection in level.requiredConnections) {
      if (!required.add(connection.key)) {
        yield LevelValidationIssue(
          'Duplicate required connection ${connection.key}',
        );
      }
      if (connection.fromNodeId == connection.toNodeId) {
        yield LevelValidationIssue(
          'Self connection ${connection.key} is invalid',
        );
      }
      if (!nodeIds.contains(connection.fromNodeId) ||
          !nodeIds.contains(connection.toNodeId)) {
        yield LevelValidationIssue(
          'Required connection ${connection.key} references a missing node',
        );
      }
      if (!allowed.contains(connection.key)) {
        yield LevelValidationIssue(
          'Required connection ${connection.key} is not allowed',
        );
      }
    }

    final degree = <String, int>{};
    for (final connection in level.requiredConnections) {
      degree[connection.fromNodeId] = (degree[connection.fromNodeId] ?? 0) + 1;
      degree[connection.toNodeId] = (degree[connection.toNodeId] ?? 0) + 1;
    }
    for (final node in level.nodes) {
      if (node.requiredConnections > 0 &&
          (degree[node.id] ?? 0) > node.requiredConnections) {
        yield LevelValidationIssue(
          'Node ${node.id} requires ${node.requiredConnections} connections but solution needs ${degree[node.id]}',
        );
      }
    }
    if (level.targetMoves < level.requiredConnections.length) {
      yield const LevelValidationIssue(
        'Target moves are below required connections',
      );
    }
    if (level.maximumMoves < level.requiredConnections.length) {
      yield const LevelValidationIssue(
        'Maximum moves are below required connections',
      );
    }
    for (final obstacle in level.obstacles) {
      if (obstacle.bounds.left < 0 ||
          obstacle.bounds.top < 0 ||
          obstacle.bounds.right > 1 ||
          obstacle.bounds.bottom > 1 ||
          !obstacle.bounds.isFinite ||
          obstacle.bounds.isEmpty) {
        yield LevelValidationIssue(
          'Obstacle ${obstacle.id} has invalid bounds',
        );
      }
    }
  }
}
