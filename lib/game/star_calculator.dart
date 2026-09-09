import 'package:nexus_link/models/level_model.dart';

/// Determines star rating based on performance.
class StarCalculator {
  int calculate({
    required int moves,
    required StarThresholds thresholds,
    int elapsedSeconds = 0,
    int mistakes = 0,
  }) {
    if (moves <= thresholds.threeStarMaxMoves &&
        (thresholds.twoStarMaxTime == 0 || elapsedSeconds <= thresholds.twoStarMaxTime) &&
        mistakes <= thresholds.threeStarMaxMistakes) {
      return 3;
    }
    if (moves <= thresholds.twoStarMaxMoves &&
        (thresholds.twoStarMaxTime == 0 || elapsedSeconds <= thresholds.twoStarMaxTime)) {
      return 2;
    }
    if (moves <= thresholds.oneStarMaxMoves) return 1;
    return 1; // Always at least 1 star on completion.
  }
}
