import 'package:flutter/foundation.dart';
import 'package:nexus_link/models/connection_model.dart';
import 'package:nexus_link/models/game_state.dart';
import 'package:nexus_link/models/level_model.dart';
import 'package:nexus_link/models/level_result.dart';
import 'package:nexus_link/models/node_model.dart';
import 'package:nexus_link/game/score_calculator.dart';
import 'package:nexus_link/game/star_calculator.dart';

/// Core puzzle game engine. Manages game logic independently of UI.
class GameEngine {
  GameState? _state;
  final ScoreCalculator _scoreCalculator = ScoreCalculator();
  final StarCalculator _starCalculator = StarCalculator();

  final VoidCallback? onStateChanged;
  final VoidCallback? onLevelComplete;
  final ValueChanged<bool>? onConnectionAttempt; // true=valid, false=invalid

  GameEngine({
    this.onStateChanged,
    this.onLevelComplete,
    this.onConnectionAttempt,
  });

  GameState? get state => _state;
  bool get isPlaying => _state?.playState == PlayState.playing;

  /// Load a level and initialize game state.
  void loadLevel(LevelModel level) {
    _state = GameState.fromLevel(level);
    _notifyChanged();
  }

  /// Reset the current level.
  void resetLevel() {
    if (_state == null) return;
    loadLevel(_state!.level);
  }

  /// Begin a drag from a node.
  bool startDrag(String nodeId) {
    if (_state == null || !isPlaying) return false;

    final node = _state!.getNode(nodeId);
    if (node == null || !node.canConnect) return false;

    _state!.activeNodeId = nodeId;
    node.state = NodeState.active;
    _notifyChanged();
    return true;
  }

  /// Update hover state during drag.
  void updateHover(String? nodeId) {
    if (_state == null || !isPlaying) return;

    // Reset previous hover.
    if (_state!.hoverNodeId != null &&
        _state!.hoverNodeId != _state!.activeNodeId) {
      final prevHover = _state!.getNode(_state!.hoverNodeId!);
      if (prevHover != null && prevHover.state == NodeState.active) {
        prevHover.state = prevHover.currentConnections > 0
            ? NodeState.connected
            : NodeState.idle;
      }
    }

    _state!.hoverNodeId = nodeId;

    if (nodeId != null && nodeId != _state!.activeNodeId) {
      final hoverNode = _state!.getNode(nodeId);
      if (hoverNode != null && hoverNode.canConnect) {
        hoverNode.state = NodeState.active;
      }
    }

    _notifyChanged();
  }

  /// Attempt to complete a connection when drag ends on a node.
  ConnectionResult attemptConnection(String targetNodeId) {
    if (_state == null || !isPlaying || _state!.activeNodeId == null) {
      _cancelDrag();
      return ConnectionResult.cancelled;
    }

    final fromId = _state!.activeNodeId!;
    final toId = targetNodeId;

    // Can't connect to self.
    if (fromId == toId) {
      _cancelDrag();
      return ConnectionResult.cancelled;
    }

    // Check if already connected.
    if (_state!.connectionExists(fromId, toId)) {
      _state!.mistakeCount++;
      _state!.moveCount++;
      _state!.comboCount = 0;
      _cancelDrag();
      onConnectionAttempt?.call(false);
      _checkForFailure();
      return ConnectionResult.alreadyExists;
    }

    // Check if connection is allowed.
    if (!_state!.isConnectionAllowed(fromId, toId)) {
      _state!.mistakeCount++;
      _state!.comboCount = 0;
      _state!.moveCount++;
      _cancelDrag();
      onConnectionAttempt?.call(false);
      _checkForFailure();
      return ConnectionResult.invalid;
    }

    if (_state!.isConnectionBlocked(fromId, toId)) {
      _state!.mistakeCount++;
      _state!.moveCount++;
      _state!.comboCount = 0;
      _cancelDrag();
      onConnectionAttempt?.call(false);
      _checkForFailure();
      return ConnectionResult.blocked;
    }

    // Valid connection!
    final connection = ConnectionModel(
      fromNodeId: fromId,
      toNodeId: toId,
      isLocked: true,
      isValid: true,
      animationProgress: 1.0,
    );
    _state!.activeConnections.add(connection);
    _state!.moveCount++;
    _state!.comboCount++;
    if (_state!.comboCount > _state!.maxCombo) {
      _state!.maxCombo = _state!.comboCount;
    }

    // Update node states.
    final fromNode = _state!.getNode(fromId);
    final toNode = _state!.getNode(toId);
    if (fromNode != null) {
      fromNode.currentConnections++;
      fromNode.state = NodeState.connected;
    }
    if (toNode != null) {
      toNode.currentConnections++;
      toNode.state = NodeState.connected;
    }

    _state!.activeNodeId = null;
    _state!.hoverNodeId = null;

    // Update score.
    _state!.score = _scoreCalculator.calculate(
      moves: _state!.moveCount,
      mistakes: _state!.mistakeCount,
      combo: _state!.comboCount,
      maxCombo: _state!.maxCombo,
      elapsedSeconds: _state!.elapsedSeconds,
      targetMoves: _state!.level.targetMoves,
      targetTime: _state!.level.targetTime,
      difficultyMultiplier: _state!.level.scoreMultiplier,
    );

    onConnectionAttempt?.call(true);
    _notifyChanged();

    // Check completion.
    if (_state!.isComplete) {
      _completeLevel();
    } else {
      _checkForFailure();
    }

    return ConnectionResult.success;
  }

  /// Cancel the current drag without making a connection.
  void cancelDrag() {
    _cancelDrag();
  }

  void _cancelDrag() {
    if (_state == null) return;

    if (_state!.activeNodeId != null) {
      final activeNode = _state!.getNode(_state!.activeNodeId!);
      if (activeNode != null) {
        activeNode.state = activeNode.currentConnections > 0
            ? NodeState.connected
            : NodeState.idle;
      }
    }
    if (_state!.hoverNodeId != null) {
      final hoverNode = _state!.getNode(_state!.hoverNodeId!);
      if (hoverNode != null && hoverNode.state == NodeState.active) {
        hoverNode.state = hoverNode.currentConnections > 0
            ? NodeState.connected
            : NodeState.idle;
      }
    }

    _state!.activeNodeId = null;
    _state!.hoverNodeId = null;
    _notifyChanged();
  }

  void _completeLevel() {
    if (_state == null) return;

    _state!.playState = PlayState.completed;

    // Mark all nodes as completed.
    for (final node in _state!.nodes) {
      if (node.state != NodeState.locked) {
        node.state = NodeState.completed;
      }
    }

    _notifyChanged();
    onLevelComplete?.call();
  }

  /// Get the result of the completed level.
  LevelResult? getResult() {
    if (_state == null ||
        (_state!.playState != PlayState.completed &&
            _state!.playState != PlayState.failed)) {
      return null;
    }

    final stars = _state!.playState == PlayState.completed
        ? _starCalculator.calculate(
            moves: _state!.moveCount,
            thresholds: _state!.level.starThresholds,
            elapsedSeconds: _state!.elapsedSeconds,
            mistakes: _state!.mistakeCount,
          )
        : 0;

    return LevelResult(
      levelId: _state!.level.id,
      score: _state!.score,
      stars: stars,
      moves: _state!.moveCount,
      timeSeconds: _state!.elapsedSeconds,
      mistakes: _state!.mistakeCount,
      isPerfect:
          _state!.mistakeCount == 0 &&
          _state!.moveCount <= _state!.level.targetMoves,
      combo: _state!.maxCombo,
      failureReason: _state!.failureReason,
    );
  }

  /// Update elapsed time (called by a timer).
  void tick() {
    if (_state == null || !isPlaying) return;
    _state!.elapsedSeconds++;
    if (_state!.elapsedSeconds > _state!.level.targetTime) {
      _failLevel(FailureReason.timeExpired);
      return;
    }
    _notifyChanged();
  }

  void _checkForFailure() {
    if (_state == null || !isPlaying) return;
    if (_state!.mistakeCount >= _state!.level.maximumMistakes) {
      _failLevel(FailureReason.tooManyMistakes);
    } else if (_state!.moveCount >= _state!.level.maximumMoves) {
      _failLevel(FailureReason.outOfMoves);
    }
  }

  void _failLevel(FailureReason reason) {
    if (_state == null || !isPlaying) return;
    _state!.failureReason = reason;
    _state!.playState = PlayState.failed;
    _cancelDrag();
    _notifyChanged();
  }

  void _notifyChanged() {
    onStateChanged?.call();
  }
}

/// Possible results of a connection attempt.
enum ConnectionResult { success, invalid, alreadyExists, blocked, cancelled }
