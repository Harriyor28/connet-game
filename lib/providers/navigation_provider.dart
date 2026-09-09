import 'package:flutter/material.dart';
import 'package:nexus_link/models/level_model.dart';

/// Screens in the game.
enum AppScreen {
  splash,
  home,
  worldSelect,
  difficultySelect,
  levelSelect,
  game,
  settings,
  achievements,
  profile,
  help,
  tutorial,
  loading,
  error,
}

/// Provider for managing screen navigation state.
class NavigationProvider extends ChangeNotifier {
  AppScreen _currentScreen = AppScreen.splash;
  String? _selectedLevelId;
  int _selectedWorldId = 1;
  Difficulty _selectedDifficulty = Difficulty.easy;

  AppScreen get currentScreen => _currentScreen;
  String? get selectedLevelId => _selectedLevelId;
  int get selectedWorldId => _selectedWorldId;
  Difficulty get selectedDifficulty => _selectedDifficulty;

  void navigateTo(
    AppScreen screen, {
    String? levelId,
    int? worldId,
    Difficulty? difficulty,
  }) {
    _currentScreen = screen;
    if (levelId != null) {
      _selectedLevelId = levelId;
    }
    if (worldId != null) {
      _selectedWorldId = worldId;
    }
    if (difficulty != null) {
      _selectedDifficulty = difficulty;
    }
    notifyListeners();
  }

  void setWorld(int worldId) {
    _selectedWorldId = worldId;
    notifyListeners();
  }

  void setDifficulty(Difficulty difficulty) {
    _selectedDifficulty = difficulty;
    notifyListeners();
  }

  void goToHome() => navigateTo(AppScreen.home);
  void goToWorldSelect() => navigateTo(AppScreen.worldSelect);
  void goToDifficultySelect() => navigateTo(AppScreen.difficultySelect);
  void goToLevelSelect() => navigateTo(AppScreen.levelSelect);
  void goToGame(String levelId) => navigateTo(AppScreen.game, levelId: levelId);
  void goToSettings() => navigateTo(AppScreen.settings);
  void goToAchievements() => navigateTo(AppScreen.achievements);
  void goToProfile() => navigateTo(AppScreen.profile);
  void goToHelp() => navigateTo(AppScreen.help);
  void goToTutorial() => navigateTo(AppScreen.tutorial);

  void goBack() {
    switch (_currentScreen) {
      case AppScreen.game:
        navigateTo(AppScreen.levelSelect);
      case AppScreen.levelSelect:
        navigateTo(AppScreen.difficultySelect);
      case AppScreen.difficultySelect:
        navigateTo(AppScreen.worldSelect);
      case AppScreen.worldSelect:
        navigateTo(AppScreen.home);
      case AppScreen.settings:
      case AppScreen.achievements:
      case AppScreen.profile:
      case AppScreen.help:
      case AppScreen.tutorial:
        navigateTo(AppScreen.home);
      default:
        break;
    }
  }
}
