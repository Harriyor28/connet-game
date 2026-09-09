class AchievementDefinition {
  final String id;
  final String title;
  final String description;
  final int progress;
  final int total;
  final bool unlocked;

  const AchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.progress,
    required this.total,
    this.unlocked = false,
  });
}

class AchievementManager {
  static const List<AchievementDefinition> _definitions = [
    AchievementDefinition(
      id: 'first_connection',
      title: 'FIRST CONNECTION',
      description: 'Complete your first level.',
      progress: 1,
      total: 1,
      unlocked: true,
    ),
    AchievementDefinition(
      id: 'perfect_start',
      title: 'PERFECT START',
      description: 'Earn your first 3-star level.',
      progress: 1,
      total: 1,
      unlocked: true,
    ),
    AchievementDefinition(
      id: 'combo_master',
      title: 'COMBO MASTER',
      description: 'Reach x10 combo.',
      progress: 8,
      total: 10,
      unlocked: false,
    ),
    AchievementDefinition(
      id: 'speed_runner',
      title: 'SPEED RUNNER',
      description: 'Complete a level under target time.',
      progress: 2,
      total: 3,
      unlocked: false,
    ),
    AchievementDefinition(
      id: 'puzzle_master',
      title: 'PUZZLE MASTER',
      description: 'Complete 100 levels.',
      progress: 48,
      total: 100,
      unlocked: false,
    ),
  ];

  const AchievementManager();

  List<AchievementDefinition> get achievements => _definitions;

  AchievementDefinition? getById(String id) {
    try {
      return _definitions.firstWhere((achievement) => achievement.id == id);
    } catch (_) {
      return null;
    }
  }
}
