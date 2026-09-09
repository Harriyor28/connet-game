import 'dart:math';

/// Calculates score based on gameplay performance.
class ScoreCalculator {
  static const int baseScore = 1000;
  static const int moveBonus = 100;
  static const int mistakePenalty = 150;
  static const int comboBonus = 50;
  static const int timeBonus = 10;

  int calculate({
    required int moves,
    required int mistakes,
    required int combo,
    required int maxCombo,
    required int elapsedSeconds,
    required int targetMoves,
    required int targetTime,
    double difficultyMultiplier = 1.0,
  }) {
    int score = baseScore;

    // Bonus for using fewer moves than target.
    final movesUnderTarget = targetMoves - moves;
    if (movesUnderTarget > 0) {
      score += movesUnderTarget * moveBonus;
    }

    // Penalty for mistakes.
    score -= mistakes * mistakePenalty;

    // Combo bonus.
    score += maxCombo * comboBonus;

    // Time bonus (points for being under target time).
    final timeUnderTarget = targetTime - elapsedSeconds;
    if (timeUnderTarget > 0) {
      score += timeUnderTarget * timeBonus;
    }

    // Never go below 100.
    return max(100, (score * difficultyMultiplier).round());
  }
}
