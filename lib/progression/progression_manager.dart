import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexus_link/data/level_repository.dart';
import 'package:nexus_link/models/level_model.dart';
import 'package:nexus_link/models/level_result.dart';

/// A serializable snapshot of the player's offline progression.
class PlayerProgress {
  final Set<String> completedLevels;
  final Map<String, int> stars;
  final Map<String, int> bestScores;
  final Map<String, int> bestTimes;
  final Map<String, int> bestMoves;
  final Map<String, int> bestCombos;
  final Set<String> perfectLevels;
  final Set<String> unlockedLevels;
  final int currentWorld;
  final String? currentLevelId;

  const PlayerProgress({
    this.completedLevels = const {},
    this.stars = const {},
    this.bestScores = const {},
    this.bestTimes = const {},
    this.bestMoves = const {},
    this.bestCombos = const {},
    this.perfectLevels = const {},
    this.unlockedLevels = const {},
    this.currentWorld = 1,
    this.currentLevelId,
  });

  int get totalStars => stars.values.fold(0, (total, value) => total + value);

  PlayerProgress copyWith({
    Set<String>? completedLevels,
    Map<String, int>? stars,
    Map<String, int>? bestScores,
    Map<String, int>? bestTimes,
    Map<String, int>? bestMoves,
    Map<String, int>? bestCombos,
    Set<String>? perfectLevels,
    Set<String>? unlockedLevels,
    int? currentWorld,
    String? currentLevelId,
  }) {
    return PlayerProgress(
      completedLevels: completedLevels ?? this.completedLevels,
      stars: stars ?? this.stars,
      bestScores: bestScores ?? this.bestScores,
      bestTimes: bestTimes ?? this.bestTimes,
      bestMoves: bestMoves ?? this.bestMoves,
      bestCombos: bestCombos ?? this.bestCombos,
      perfectLevels: perfectLevels ?? this.perfectLevels,
      unlockedLevels: unlockedLevels ?? this.unlockedLevels,
      currentWorld: currentWorld ?? this.currentWorld,
      currentLevelId: currentLevelId ?? this.currentLevelId,
    );
  }

  Map<String, dynamic> toJson() => {
    'completedLevels': completedLevels.toList(),
    'stars': stars,
    'bestScores': bestScores,
    'bestTimes': bestTimes,
    'bestMoves': bestMoves,
    'bestCombos': bestCombos,
    'perfectLevels': perfectLevels.toList(),
    'unlockedLevels': unlockedLevels.toList(),
    'currentWorld': currentWorld,
    'currentLevelId': currentLevelId,
  };

  factory PlayerProgress.fromJson(Map<String, dynamic> json) {
    Map<String, int> readScores(String key) {
      final values = json[key] as Map<String, dynamic>? ?? {};
      return values.map((id, value) => MapEntry(id, (value as num).toInt()));
    }

    return PlayerProgress(
      completedLevels: Set<String>.from(json['completedLevels'] as List? ?? []),
      stars: readScores('stars'),
      bestScores: readScores('bestScores'),
      bestTimes: readScores('bestTimes'),
      bestMoves: readScores('bestMoves'),
      bestCombos: readScores('bestCombos'),
      perfectLevels: Set<String>.from(json['perfectLevels'] as List? ?? []),
      unlockedLevels: Set<String>.from(json['unlockedLevels'] as List? ?? []),
      currentWorld: json['currentWorld'] as int? ?? 1,
      currentLevelId: json['currentLevelId'] as String?,
    );
  }
}

/// Owns progression rules and local persistence, with no network dependency.
class ProgressionManager {
  static const _storageKey = 'connect3d_player_progress_v1';

  PlayerProgress _progress = const PlayerProgress();

  PlayerProgress get progress => _progress;

  Future<void> load(LevelRepository repository) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      try {
        _progress = PlayerProgress.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      } catch (_) {
        _progress = const PlayerProgress();
      }
    }

    if (_progress.unlockedLevels.isEmpty) {
      final firstEasy = repository.getLevelByNumber(Difficulty.easy, 1);
      if (firstEasy != null) {
        _progress = _progress.copyWith(
          unlockedLevels: {firstEasy.id},
          currentLevelId: firstEasy.id,
        );
        await save();
      }
    }
  }

  bool isUnlocked(String levelId) => _progress.unlockedLevels.contains(levelId);

  int getStars(String levelId) => _progress.stars[levelId] ?? 0;
  int getBestCombo(String levelId) => _progress.bestCombos[levelId] ?? 0;
  bool isPerfect(String levelId) => _progress.perfectLevels.contains(levelId);

  void recordResult(LevelResult result, LevelRepository repository) {
    final level = repository.getLevel(result.levelId);
    if (level == null) return;

    final completed = {..._progress.completedLevels, result.levelId};
    final stars = {..._progress.stars};
    final bestScores = {..._progress.bestScores};
    final bestTimes = {..._progress.bestTimes};
    final bestMoves = {..._progress.bestMoves};
    final bestCombos = {..._progress.bestCombos};
    final perfectLevels = {..._progress.perfectLevels};
    final unlocked = {..._progress.unlockedLevels, result.levelId};

    if (result.stars > (stars[result.levelId] ?? 0)) {
      stars[result.levelId] = result.stars;
    }
    if (result.score > (bestScores[result.levelId] ?? 0)) {
      bestScores[result.levelId] = result.score;
    }
    if (result.timeSeconds < (bestTimes[result.levelId] ?? 1 << 30)) {
      bestTimes[result.levelId] = result.timeSeconds;
    }
    if (result.moves < (bestMoves[result.levelId] ?? 1 << 30)) {
      bestMoves[result.levelId] = result.moves;
    }
    if (result.combo > (bestCombos[result.levelId] ?? 0)) {
      bestCombos[result.levelId] = result.combo;
    }
    if (result.isPerfect) {
      perfectLevels.add(result.levelId);
    }

    final next = repository.getNextLevel(result.levelId);
    if (next != null && level.unlockRule == 'previous_level') {
      unlocked.add(next.id);
    }

    if (next == null || level.unlockRule == 'difficulty_gate') {
      final nextDifficulty = _nextDifficulty(level.difficulty);
      if (nextDifficulty != null) {
        final firstNext = repository.getLevelByNumber(nextDifficulty, 1);
        if (firstNext != null) unlocked.add(firstNext.id);
      }
    }

    _progress = _progress.copyWith(
      completedLevels: completed,
      stars: stars,
      bestScores: bestScores,
      bestTimes: bestTimes,
      bestMoves: bestMoves,
      bestCombos: bestCombos,
      perfectLevels: perfectLevels,
      unlockedLevels: unlocked,
      currentWorld: level.worldId,
      currentLevelId: result.levelId,
    );
    save();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_progress.toJson()));
  }

  Future<void> reset(LevelRepository repository) async {
    final firstEasy = repository.getLevelByNumber(Difficulty.easy, 1);
    _progress = PlayerProgress(
      unlockedLevels: firstEasy == null ? {} : {firstEasy.id},
      currentLevelId: firstEasy?.id,
    );
    await save();
  }

  Difficulty? _nextDifficulty(Difficulty difficulty) {
    final index = Difficulty.values.indexOf(difficulty);
    if (index < 0 || index == Difficulty.values.length - 1) return null;
    return Difficulty.values[index + 1];
  }
}
