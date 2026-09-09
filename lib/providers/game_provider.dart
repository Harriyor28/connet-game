import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nexus_link/core/analytics/analytics_context.dart';
import 'package:nexus_link/core/analytics/analytics_event.dart';
import 'package:nexus_link/core/analytics/analytics_service.dart';
import 'package:nexus_link/game/game_engine.dart';
import 'package:nexus_link/models/game_state.dart';
import 'package:nexus_link/models/level_model.dart';
import 'package:nexus_link/models/level_result.dart';
import 'package:nexus_link/audio/audio_manager.dart';
import 'package:nexus_link/world/effect_controller.dart';

/// Provider that manages game state and bridges the GameEngine with the UI.
class GameProvider extends ChangeNotifier {
  late GameEngine _engine;
  final AudioManager _audio = AudioManager();
  final EffectController _effects = EffectController();
  final AnalyticsService _analytics = LocalAnalyticsService.instance;
  Timer? _timer;
  LevelResult? _lastResult;

  GameProvider() {
    _engine = GameEngine(
      onStateChanged: _onStateChanged,
      onLevelComplete: _onLevelComplete,
      onConnectionAttempt: _onConnectionAttempt,
    );
  }

  // --- Getters ---
  GameState? get state => _engine.state;
  bool get isPlaying => _engine.isPlaying;
  bool get isComplete => state?.playState == PlayState.completed;
  bool get isFailed => state?.playState == PlayState.failed;
  LevelResult? get lastResult => _lastResult;
  int get moveCount => state?.moveCount ?? 0;
  int get score => state?.score ?? 0;
  int get comboCount => state?.comboCount ?? 0;
  int get elapsedSeconds => state?.elapsedSeconds ?? 0;
  String? get activeNodeId => state?.activeNodeId;
  Stream<EffectEvent> get effectEvents => _effects.events;

  // --- Level Management ---

  /// Load and start a level.
  void loadLevel(LevelModel level) {
    _stopTimer();
    _lastResult = null;
    _engine.loadLevel(level);
    _startTimer();
    unawaited(
      _analytics.logEvent(
        AnalyticsEventName.levelStarted,
        context: AnalyticsContext(
          screen: 'game',
          worldId: level.worldId,
          levelId: level.id,
          difficulty: level.difficulty.name,
          gameState: PlayState.playing.name,
        ),
      ),
    );
  }

  /// Reset the current level.
  void resetLevel() {
    _stopTimer();
    _lastResult = null;
    _engine.resetLevel();
    _startTimer();
    final level = state?.level;
    if (level != null) {
      unawaited(
        _analytics.logEvent(
          AnalyticsEventName.levelRestarted,
          context: AnalyticsContext(
            screen: 'game',
            worldId: level.worldId,
            levelId: level.id,
            difficulty: level.difficulty.name,
          ),
        ),
      );
    }
  }

  // --- Drag/Connection ---

  /// Start dragging from a node.
  bool startDrag(String nodeId) {
    return _engine.startDrag(nodeId);
  }

  /// Update hover state during drag.
  void updateHover(String? nodeId) {
    _engine.updateHover(nodeId);
  }

  /// Attempt to complete a connection.
  ConnectionResult attemptConnection(String targetNodeId) {
    return _engine.attemptConnection(targetNodeId);
  }

  /// Cancel the current drag.
  void cancelDrag() {
    _engine.cancelDrag();
  }

  // --- Timer ---

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _engine.tick();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  // --- Callbacks ---

  void _onStateChanged() {
    if (isFailed) {
      _stopTimer();
      _lastResult ??= _engine.getResult();
      _audio.playLevelFailedSound();
      _audio.triggerHaptic(HapticsPattern.warning);
      final failedState = state;
      if (failedState != null) {
        unawaited(
          _analytics.logEvent(
            AnalyticsEventName.levelFailed,
            parameters: <String, Object?>{
              'reason': failedState.failureReason?.name ?? 'unknown',
            },
            context: AnalyticsContext(
              screen: 'game',
              worldId: failedState.level.worldId,
              levelId: failedState.level.id,
              difficulty: failedState.level.difficulty.name,
              gameState: failedState.playState.name,
              moves: failedState.moveCount,
              mistakes: failedState.mistakeCount,
              combo: failedState.maxCombo,
            ),
          ),
        );
      }
    }
    notifyListeners();
  }

  void _onLevelComplete() {
    _stopTimer();
    _lastResult = _engine.getResult();
    _audio.playVictorySound();
    _audio.triggerHaptic(HapticsPattern.success);
    _audio.playVoice('level_complete');
    _effects.playLevelCompleteEffect();
    final result = _lastResult;
    final completedState = state;
    if (result != null && completedState != null) {
      unawaited(
        _analytics.logEvent(
          AnalyticsEventName.levelCompleted,
          parameters: <String, Object?>{
            'score': result.score,
            'stars': result.stars,
            'completion_time': result.timeSeconds,
          },
          context: AnalyticsContext(
            screen: 'game',
            worldId: completedState.level.worldId,
            levelId: completedState.level.id,
            difficulty: completedState.level.difficulty.name,
            gameState: completedState.playState.name,
            moves: result.moves,
            mistakes: result.mistakes,
            combo: result.combo,
          ),
        ),
      );
      if (result.isPerfect) {
        unawaited(
          _analytics.logEvent(
            AnalyticsEventName.perfectLevel,
            parameters: <String, Object?>{'level_id': result.levelId},
          ),
        );
      }
      if (result.combo >= 3) {
        unawaited(
          _analytics.logEvent(
            AnalyticsEventName.highestComboReached,
            parameters: <String, Object?>{'combo': result.combo},
          ),
        );
      }
    }
    if (_lastResult?.isPerfect == true) {
      _effects.playPerfectEffect();
      _audio.playVoice('perfect');
    }
    notifyListeners();
  }

  void _onConnectionAttempt(bool isValid) {
    if (isValid) {
      _audio.playConnectionSound();
      _audio.triggerHaptic(HapticsPattern.light);
      _effects.playConnectionEffect(combo: state?.comboCount ?? 1);
      if ((state?.comboCount ?? 0) > 1) {
        _audio.playComboSound(state!.comboCount);
        _audio.triggerHaptic(HapticsPattern.milestone);
        _effects.playComboEffect(state!.comboCount);
      }
    } else {
      _audio.playInvalidSound();
      _audio.triggerHaptic(HapticsPattern.warning);
    }
  }

  @override
  void dispose() {
    _stopTimer();
    _effects.dispose();
    super.dispose();
  }
}
