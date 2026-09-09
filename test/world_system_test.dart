import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_link/world/world_manager.dart';
import 'package:nexus_link/world/special_node_definition.dart';
import 'package:nexus_link/world/obstacle_definition.dart';

void main() {
  group('Phase 4 world system', () {
    test('world registry includes neon lab and placeholder worlds', () {
      final worlds = WorldManager().allWorlds;
      expect(
        worlds.any((world) => world.id == 1 && world.name == 'Neon Lab'),
        isTrue,
      );
      expect(
        worlds.any((world) => world.id == 2 && world.name == 'Space'),
        isTrue,
      );
      expect(worlds.length >= 4, isTrue);
    });

    test('special node definitions are registered and keyed', () {
      final energy = SpecialNodeDefinition.energy();
      final bonus = SpecialNodeDefinition.bonus();

      expect(energy.id, 'special_energy');
      expect(energy.effectName, 'energy_pulse');
      expect(bonus.id, 'special_bonus');
    });

    test('obstacle definitions describe valid blockers', () {
      final staticObstacle = ObstacleDefinition.staticBlocker();
      final movingObstacle = ObstacleDefinition.movingBlocker();

      expect(staticObstacle.type, ObstacleType.staticBlocker);
      expect(movingObstacle.type, ObstacleType.movingBlocker);
      expect(staticObstacle.isBlocking, isTrue);
    });
  });
}
