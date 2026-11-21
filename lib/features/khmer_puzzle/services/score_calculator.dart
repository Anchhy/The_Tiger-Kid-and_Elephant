import '../models/puzzle_enums.dart';
import '../models/puzzle_result.dart';

/// Deterministic scoring calculator for M3 Khmer puzzle completions.
class ScoreCalculator {
  const ScoreCalculator({
    this.baseScores = defaultBaseScores,
    this.attemptPenalty = 20,
    this.hintPenalty = 10,
    this.minScoreOnSolve = 10,
  });

  static const Map<PuzzleDifficulty, int> defaultBaseScores = {
    PuzzleDifficulty.easy: 100,
    PuzzleDifficulty.medium: 150,
    PuzzleDifficulty.hard: 200,
  };

  final Map<PuzzleDifficulty, int> baseScores;
  final int attemptPenalty;
  final int hintPenalty;
  final int minScoreOnSolve;

  /// Calculates the score for a completed puzzle submission.
  ///
  /// Returns `0` when [isSolved] is `false`. When solved, starts from the
  /// difficulty base score and deducts penalties for extra wrong attempts
  /// and hints used, clamped to at least [minScoreOnSolve].
  int calculateScore({
    required PuzzleDifficulty difficulty,
    required bool isSolved,
    int attempts = 1,
    int hintsUsed = 0,
  }) {
    if (!isSolved) {
      return 0;
    }

    final base = baseScores[difficulty] ?? 100;
    final extraAttempts = attempts > 1 ? attempts - 1 : 0;
    final safeHints = hintsUsed > 0 ? hintsUsed : 0;
    final raw =
        base - (extraAttempts * attemptPenalty) - (safeHints * hintPenalty);
    final floor = minScoreOnSolve <= base ? minScoreOnSolve : base;
    return raw.clamp(floor, base);
  }

  /// Convenience wrapper calculating a score from an existing [PuzzleResult].
  int calculateForResult(PuzzleResult result) {
    return calculateScore(
      difficulty: result.difficulty,
      isSolved: result.isSolved,
      attempts: result.attempts,
      hintsUsed: result.hintsUsed,
    );
  }
}
