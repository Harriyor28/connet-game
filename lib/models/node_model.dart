import 'package:flutter/material.dart';

/// The type of a puzzle node.
enum NodeType { normal, bonus, energy, locked, rotating, timed, special }

/// The visual/interaction state of a node.
enum NodeState {
  idle,
  active, // Currently being dragged from/to
  connected, // Has at least one connection
  completed, // All required connections made
  locked, // Cannot be interacted with yet
  invalid, // Showing error feedback
}

/// Represents a single node in the puzzle.
class NodeModel {
  final String id;
  final double normalizedX; // 0.0–1.0
  final double normalizedY; // 0.0–1.0
  final double normalizedZ; // -1.0–1.0 depth from the camera
  final NodeType type;
  NodeState state;
  int requiredConnections;
  int currentConnections;

  NodeModel({
    required this.id,
    required this.normalizedX,
    required this.normalizedY,
    this.normalizedZ = 0.0,
    this.type = NodeType.normal,
    this.state = NodeState.idle,
    this.requiredConnections = 0,
    this.currentConnections = 0,
  });

  /// Get the absolute position on a board of given size.
  Offset getPosition(Size boardSize, Offset boardOffset) {
    return Offset(
      boardOffset.dx + normalizedX * boardSize.width,
      boardOffset.dy + normalizedY * boardSize.height,
    );
  }

  /// Check if a point is within hit range of this node.
  bool hitTest(
    Offset point,
    Size boardSize,
    Offset boardOffset,
    double hitRadius,
  ) {
    final pos = getPosition(boardSize, boardOffset);
    return (point - pos).distance <= hitRadius;
  }

  /// Whether this node can accept a new connection.
  bool get canConnect {
    if (state == NodeState.locked) return false;
    if (requiredConnections > 0 && currentConnections >= requiredConnections) {
      return false;
    }
    return true;
  }

  /// Create from JSON map.
  factory NodeModel.fromJson(Map<String, dynamic> json) {
    return NodeModel(
      id: json['id'] as String,
      normalizedX: (json['x'] as num).toDouble(),
      normalizedY: (json['y'] as num).toDouble(),
      normalizedZ: (json['z'] as num?)?.toDouble() ?? 0.0,
      type: NodeType.values.firstWhere(
        (e) => e.name == (json['type'] as String? ?? 'normal'),
        orElse: () => NodeType.normal,
      ),
      requiredConnections: json['requiredConnections'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'x': normalizedX,
    'y': normalizedY,
    'z': normalizedZ,
    'type': type.name,
    'requiredConnections': requiredConnections,
  };

  @override
  String toString() =>
      'NodeModel($id, ($normalizedX, $normalizedY), $type, $state)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NodeModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
