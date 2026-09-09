/// Represents a connection between two nodes.
class ConnectionModel {
  final String fromNodeId;
  final String toNodeId;
  bool isLocked;
  bool isValid;
  double animationProgress;  // 0.0 to 1.0 for connection animation

  ConnectionModel({
    required this.fromNodeId,
    required this.toNodeId,
    this.isLocked = false,
    this.isValid = true,
    this.animationProgress = 0.0,
  });

  /// A canonical key so (A->B) and (B->A) are the same connection.
  String get key {
    final sorted = [fromNodeId, toNodeId]..sort();
    return '${sorted[0]}->${sorted[1]}';
  }

  factory ConnectionModel.fromJson(Map<String, dynamic> json) {
    return ConnectionModel(
      fromNodeId: json['from'] as String,
      toNodeId: json['to'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'from': fromNodeId,
    'to': toNodeId,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectionModel && other.key == key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => 'Connection($fromNodeId -> $toNodeId, locked=$isLocked)';
}
