/// The result of completing a level.
class LevelResult {
  final String levelId;
  final int score;
  final int stars; // 1, 2, or 3
  final int moves;
  final int timeSeconds;
  final int mistakes;
  final bool isPerfect;
  final int combo;
  final FailureReason? failureReason;

  const LevelResult({
    required this.levelId,
    required this.score,
    required this.stars,
    required this.moves,
    required this.timeSeconds,
    required this.mistakes,
    required this.isPerfect,
    this.combo = 0,
    this.failureReason,
  });

  @override
  String toString() => 'LevelResult($levelId, score=$score, stars=$stars)';
}

enum FailureReason { tooManyMistakes, outOfMoves, timeExpired }
