import 'package:nexus_link/models/game_state.dart';

/// Validates connections in the puzzle.
class ConnectionValidator {
  /// Check if a connection from [fromId] to [toId] is valid.
  ValidationResult validate(GameState state, String fromId, String toId) {
    // Can't connect to self.
    if (fromId == toId) {
      return ValidationResult.selfConnection;
    }

    // Check nodes exist.
    final fromNode = state.getNode(fromId);
    final toNode = state.getNode(toId);
    if (fromNode == null || toNode == null) {
      return ValidationResult.nodeNotFound;
    }

    // Check node states.
    if (!fromNode.canConnect) {
      return ValidationResult.nodeCannotConnect;
    }
    if (!toNode.canConnect) {
      return ValidationResult.nodeCannotConnect;
    }

    // Check if already connected.
    if (state.connectionExists(fromId, toId)) {
      return ValidationResult.alreadyConnected;
    }

    // Check if allowed.
    if (!state.isConnectionAllowed(fromId, toId)) {
      return ValidationResult.notAllowed;
    }

    return ValidationResult.valid;
  }
}

enum ValidationResult {
  valid,
  selfConnection,
  nodeNotFound,
  nodeCannotConnect,
  alreadyConnected,
  notAllowed,
}
