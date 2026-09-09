import 'package:flutter/material.dart';
import 'package:nexus_link/models/connection_model.dart';
import 'package:nexus_link/models/node_model.dart';
import 'package:nexus_link/models/level_model.dart';
import 'package:nexus_link/models/level_result.dart';

/// Represents the current state of a puzzle during gameplay.
enum PlayState { loading, playing, paused, completed, failed }

class GameState {
  final LevelModel level;
  final List<NodeModel> nodes;
  final List<ConnectionModel> activeConnections;
  PlayState playState;
  int moveCount;
  int mistakeCount;
  int comboCount;
  int maxCombo;
  int score;
  int elapsedSeconds;
  FailureReason? failureReason;
  String? activeNodeId; // Node currently being dragged from
  String? hoverNodeId; // Node currently being hovered over

  GameState({
    required this.level,
    required this.nodes,
    List<ConnectionModel>? activeConnections,
    this.playState = PlayState.playing,
    this.moveCount = 0,
    this.mistakeCount = 0,
    this.comboCount = 0,
    this.maxCombo = 0,
    this.score = 0,
    this.elapsedSeconds = 0,
    this.failureReason,
    this.activeNodeId,
    this.hoverNodeId,
  }) : activeConnections = activeConnections ?? [];

  /// Create initial game state from a level definition.
  factory GameState.fromLevel(LevelModel level) {
    // Deep copy nodes so we can mutate their state.
    final nodes = level.nodes
        .map(
          (n) => NodeModel(
            id: n.id,
            normalizedX: n.normalizedX,
            normalizedY: n.normalizedY,
            normalizedZ: n.normalizedZ,
            type: n.type,
            state: n.type == NodeType.locked
                ? NodeState.locked
                : NodeState.idle,
            requiredConnections: n.requiredConnections,
          ),
        )
        .toList();

    return GameState(level: level, nodes: nodes);
  }

  /// Whether all required connections have been made.
  bool get isComplete {
    final requiredKeys = level.requiredConnections.map((c) => c.key).toSet();
    final activeKeys = activeConnections
        .where((c) => c.isLocked)
        .map((c) => c.key)
        .toSet();
    return requiredKeys.every((key) => activeKeys.contains(key));
  }

  /// Whether a connection between two nodes is allowed.
  bool isConnectionAllowed(String fromId, String toId) {
    final testConnection = ConnectionModel(fromNodeId: fromId, toNodeId: toId);
    return level.allowedConnections.any((c) => c.key == testConnection.key);
  }

  bool isConnectionBlocked(String fromId, String toId) {
    final from = getNode(fromId);
    final to = getNode(toId);
    if (from == null || to == null) return false;
    final start = Offset(from.normalizedX, from.normalizedY);
    final end = Offset(to.normalizedX, to.normalizedY);
    return level.obstacles.any(
      (obstacle) => obstacle.blocksSegment(start, end),
    );
  }

  /// Whether a connection already exists.
  bool connectionExists(String fromId, String toId) {
    final testConnection = ConnectionModel(fromNodeId: fromId, toNodeId: toId);
    return activeConnections.any(
      (c) => c.key == testConnection.key && c.isLocked,
    );
  }

  /// Get a node by ID.
  NodeModel? getNode(String id) {
    try {
      return nodes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }
}
