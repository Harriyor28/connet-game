import 'world_definition.dart';

/// Offline registry and lifecycle boundary for world presentation data.
class WorldManager {
  static final WorldManager _instance = WorldManager._internal();
  factory WorldManager() => _instance;
  WorldManager._internal();

  static const List<WorldDefinition> _worlds = [
    WorldDefinition(
      id: 1,
      name: 'Neon Lab',
      environmentId: 'neon_lab',
      themeId: 'neon',
      theme: WorldTheme.neonLab,
      assetKeys: ['world_neon_lab', 'obstacle_static', 'effect_connection'],
    ),
    WorldDefinition(
      id: 2,
      name: 'Space',
      environmentId: 'space',
      themeId: 'space',
      theme: WorldTheme.placeholder,
    ),
    WorldDefinition(
      id: 3,
      name: 'Crystal',
      environmentId: 'crystal',
      themeId: 'crystal',
      theme: WorldTheme.placeholder,
    ),
    WorldDefinition(
      id: 4,
      name: 'Cyber City',
      environmentId: 'cyber_city',
      themeId: 'cyber_city',
      theme: WorldTheme.placeholder,
    ),
    WorldDefinition(
      id: 5,
      name: 'Ancient Temple',
      environmentId: 'ancient_temple',
      themeId: 'ancient_temple',
      theme: WorldTheme.placeholder,
    ),
    WorldDefinition(
      id: 6,
      name: 'Ocean',
      environmentId: 'ocean',
      themeId: 'ocean',
      theme: WorldTheme.placeholder,
    ),
    WorldDefinition(
      id: 7,
      name: 'Volcano',
      environmentId: 'volcano',
      themeId: 'volcano',
      theme: WorldTheme.placeholder,
    ),
  ];

  WorldDefinition? _activeWorld;

  List<WorldDefinition> get allWorlds => List.unmodifiable(_worlds);
  WorldDefinition get activeWorld => _activeWorld ?? _worlds.first;

  WorldDefinition? getWorld(int id) {
    for (final world in _worlds) {
      if (world.id == id) return world;
    }
    return null;
  }

  WorldDefinition loadWorld(int id) {
    final world = getWorld(id) ?? _worlds.first;
    _activeWorld = world;
    return world;
  }

  void unloadWorld() {
    _activeWorld = null;
  }
}
