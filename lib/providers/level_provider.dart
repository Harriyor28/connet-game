import 'package:flutter/material.dart';
import 'package:nexus_link/data/level_repository.dart';
import 'package:nexus_link/models/level_model.dart';
import 'package:nexus_link/models/level_result.dart';
import 'package:nexus_link/progression/progression_manager.dart';

/// Provider that manages level progression and unlocking.
class LevelProvider extends ChangeNotifier {
  final LevelRepository _repository = LevelRepository();
  final ProgressionManager _progression = ProgressionManager();

  Difficulty _selectedDifficulty = Difficulty.easy;

  Difficulty get selectedDifficulty => _selectedDifficulty;

  LevelProvider() {
    _initializeProgress();
  }

  PlayerProgress get progress => _progression.progress;
  int get totalStars => progress.totalStars;

  Future<void> _initializeProgress() async {
    await _progression.load(_repository);
    notifyListeners();
  }

  /// Set the active difficulty.
  void setDifficulty(Difficulty difficulty) {
    _selectedDifficulty = difficulty;
    notifyListeners();
  }

  /// Get all levels for the selected difficulty.
  List<LevelModel> get currentLevels {
    return _repository.getLevels(_selectedDifficulty);
  }

  List<LevelModel> getLevelsByWorld(int worldId) {
    return _repository
        .getAllLevels()
        .where((level) => level.worldId == worldId)
        .toList();
  }

  /// Get all levels for a specific difficulty.
  List<LevelModel> getLevels(Difficulty difficulty) {
    return _repository.getLevels(difficulty);
  }

  /// Check if a level is unlocked.
  bool isLevelUnlocked(String levelId) {
    return _progression.isUnlocked(levelId);
  }

  /// Get the stars earned for a level (null if not completed).
  int? getStars(String levelId) {
    final stars = _progression.getStars(levelId);
    return stars == 0 ? null : stars;
  }

  int getBestCombo(String levelId) => _progression.getBestCombo(levelId);

  bool isPerfect(String levelId) => _progression.isPerfect(levelId);

  List<LevelModel> get unlockedLevels =>
      _repository.getUnlockedLevels(progress.unlockedLevels);

  List<LevelModel> get completedLevels =>
      _repository.getCompletedLevels(progress.completedLevels);

  /// Record completion of a level and unlock the next one.
  void completeLevel(LevelResult result) {
    _progression.recordResult(result, _repository);
    notifyListeners();
  }

  int getCompletedCount(Difficulty difficulty) {
    return currentLevelsFor(
      difficulty,
    ).where((level) => progress.completedLevels.contains(level.id)).length;
  }

  int getStarsForDifficulty(Difficulty difficulty) {
    return currentLevelsFor(
      difficulty,
    ).fold(0, (total, level) => total + _progression.getStars(level.id));
  }

  List<LevelModel> currentLevelsFor(Difficulty difficulty) {
    return _repository.getLevels(difficulty);
  }

  Future<void> resetProgress() async {
    await _progression.reset(_repository);
    notifyListeners();
  }

  /// Get a level by its ID.
  LevelModel? getLevel(String id) {
    return _repository.getLevel(id);
  }
}
