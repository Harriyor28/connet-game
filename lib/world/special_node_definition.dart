enum SpecialNodeType { normal, energy, bonus, locked, rotating, timed }

/// Declarative special-node behavior; rendering and gameplay can consume it independently.
class SpecialNodeDefinition {
  final String id;
  final SpecialNodeType type;
  final String effectName;
  final bool canConnect;
  final int scoreBonus;
  final String? activationRequirement;

  const SpecialNodeDefinition({
    required this.id,
    required this.type,
    required this.effectName,
    this.canConnect = true,
    this.scoreBonus = 0,
    this.activationRequirement,
  });

  factory SpecialNodeDefinition.normal() => const SpecialNodeDefinition(
        id: 'special_normal',
        type: SpecialNodeType.normal,
        effectName: 'connection_pulse',
      );

  factory SpecialNodeDefinition.energy() => const SpecialNodeDefinition(
        id: 'special_energy',
        type: SpecialNodeType.energy,
        effectName: 'energy_pulse',
      );

  factory SpecialNodeDefinition.bonus() => const SpecialNodeDefinition(
        id: 'special_bonus',
        type: SpecialNodeType.bonus,
        effectName: 'bonus_burst',
        scoreBonus: 250,
      );

  factory SpecialNodeDefinition.locked({String requirement = 'required_connection'}) => SpecialNodeDefinition(
        id: 'special_locked',
        type: SpecialNodeType.locked,
        effectName: 'unlock_flash',
        canConnect: false,
        activationRequirement: requirement,
      );

  factory SpecialNodeDefinition.rotating() => const SpecialNodeDefinition(
        id: 'special_rotating',
        type: SpecialNodeType.rotating,
        effectName: 'rotation_tick',
      );

  factory SpecialNodeDefinition.timed() => const SpecialNodeDefinition(
        id: 'special_timed',
        type: SpecialNodeType.timed,
        effectName: 'timed_pulse',
      );
}
