class AnalyticsContext {
  const AnalyticsContext({
    this.screen,
    this.worldId,
    this.levelId,
    this.difficulty,
    this.gameState,
    this.moves,
    this.mistakes,
    this.combo,
    this.offline,
    this.graphicsQuality,
  });

  final String? screen;
  final int? worldId;
  final String? levelId;
  final String? difficulty;
  final String? gameState;
  final int? moves;
  final int? mistakes;
  final int? combo;
  final bool? offline;
  final String? graphicsQuality;

  Map<String, Object?> toParameters() => {
        if (screen != null) 'screen': screen,
        if (worldId != null) 'world_id': worldId,
        if (levelId != null) 'level_id': levelId,
        if (difficulty != null) 'difficulty': difficulty,
        if (gameState != null) 'game_state': gameState,
        if (moves != null) 'moves': moves,
        if (mistakes != null) 'mistakes': mistakes,
        if (combo != null) 'combo': combo,
        if (offline != null) 'offline': offline,
        if (graphicsQuality != null) 'graphics_quality': graphicsQuality,
      };
}