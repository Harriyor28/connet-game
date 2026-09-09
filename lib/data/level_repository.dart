import 'package:nexus_link/data/phase_three_levels.dart';
import 'package:nexus_link/models/level_model.dart';

/// Repository for loading level definitions.
class LevelRepository {
  static final LevelRepository _instance = LevelRepository._internal();
  factory LevelRepository() => _instance;
  LevelRepository._internal();

  List<LevelModel>? _cachedLevels;

  /// Get all levels for a difficulty.
  List<LevelModel> getLevels(Difficulty difficulty) {
    final all = getAllLevels();
    return all.where((l) => l.difficulty == difficulty).toList();
  }

  /// Get all levels belonging to a world.
  List<LevelModel> getLevelsByWorld(int worldId) {
    return getAllLevels().where((level) => level.worldId == worldId).toList();
  }

  /// Get the levels currently unlocked by a progression snapshot.
  List<LevelModel> getUnlockedLevels(Set<String> unlockedLevelIds) {
    return getAllLevels()
        .where((level) => unlockedLevelIds.contains(level.id))
        .toList(growable: false);
  }

  /// Get completed authored levels from a progression snapshot.
  List<LevelModel> getCompletedLevels(Set<String> completedLevelIds) {
    return getAllLevels()
        .where((level) => completedLevelIds.contains(level.id))
        .toList(growable: false);
  }

  bool isLevelUnlocked(String levelId, Set<String> unlockedLevelIds) {
    return unlockedLevelIds.contains(levelId) && levelExists(levelId);
  }

  int getLevelCount(Difficulty difficulty) => getLevels(difficulty).length;

  /// Get all levels.
  List<LevelModel> getAllLevels() {
    _cachedLevels ??= _loadLevels();
    return _cachedLevels!;
  }

  /// Get a specific level by ID.
  LevelModel? getLevel(String id) {
    return getAllLevels().where((l) => l.id == id).firstOrNull;
  }

  /// Get a level by difficulty and number.
  LevelModel? getLevelByNumber(Difficulty difficulty, int number) {
    return getLevels(
      difficulty,
    ).where((l) => l.levelNumber == number).firstOrNull;
  }

  /// Return the next authored level within the same difficulty.
  LevelModel? getNextLevel(String id) {
    final current = getLevel(id);
    if (current == null) return null;
    return getLevelByNumber(current.difficulty, current.levelNumber + 1);
  }

  LevelModel? getPreviousLevel(String id) {
    final current = getLevel(id);
    if (current == null || current.levelNumber <= 1) return null;
    return getLevelByNumber(current.difficulty, current.levelNumber - 1);
  }

  bool levelExists(String id) => getLevel(id) != null;

  List<LevelModel> getMetadata() => List.unmodifiable(getAllLevels());

  List<LevelModel> _loadLevels() {
    final levels = <LevelModel>[];

    for (final data in PhaseThreeLevels.all) {
      levels.add(LevelModel.fromJson(data));
    }

    return levels;
  }

  /// Clear cache (useful for hot reload / testing).
  void clearCache() {
    _cachedLevels = null;
  }
}
