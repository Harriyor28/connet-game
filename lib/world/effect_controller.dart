import 'dart:async';

/// Event boundary for procedural visual effects. Rendering subscribes to these events.
class EffectController {
  final StreamController<EffectEvent> _events = StreamController.broadcast();

  Stream<EffectEvent> get events => _events.stream;

  void playConnectionEffect({int combo = 1}) => _emit(EffectEvent.connection(combo));
  void playComboEffect(int combo) => _emit(EffectEvent.combo(combo));
  void playPerfectEffect() => _emit(const EffectEvent(EffectType.perfect));
  void playLevelCompleteEffect() => _emit(const EffectEvent(EffectType.levelComplete));
  void playWorldUnlockEffect() => _emit(const EffectEvent(EffectType.worldUnlock));

  void _emit(EffectEvent event) {
    if (!_events.isClosed) _events.add(event);
  }

  Future<void> dispose() => _events.close();
}

enum EffectType { connection, combo, perfect, levelComplete, worldUnlock }

class EffectEvent {
  final EffectType type;
  final int intensity;

  const EffectEvent(this.type, {this.intensity = 1});

  const EffectEvent.connection(int combo)
      : this(EffectType.connection, intensity: combo);

  const EffectEvent.combo(int combo)
      : this(EffectType.combo, intensity: combo);
}
