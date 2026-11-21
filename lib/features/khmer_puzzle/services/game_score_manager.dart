/// Configurable multi-question scoring & streak manager for M3 puzzle sessions.
///
/// Default scoring rules:
/// - Correct answer without hints: `+10` points
/// - Correct answer with hint penalty (`-2` once per question): `+8` points
/// - Incorrect answer: `+0` points (resets current streak)
/// - 3 consecutive correct answers: `+5` streak bonus
/// - 5 consecutive correct answers: `+10` streak bonus
/// - Total score is guaranteed never to fall below `0`.
class GameScoreManager {
  GameScoreManager({
    this.correctPoints = 10,
    this.incorrectPoints = 0,
    this.hintPenaltyPerQuestion = 2,
    this.streak3Bonus = 5,
    this.streak5Bonus = 10,
  });

  final int correctPoints;
  final int incorrectPoints;
  final int hintPenaltyPerQuestion;
  final int streak3Bonus;
  final int streak5Bonus;

  int _totalScore = 0;
  int _currentStreak = 0;
  int _maxStreak = 0;
  bool _currentQuestionHintPenalized = false;

  int get totalScore => _totalScore;
  int get currentStreak => _currentStreak;
  int get maxStreak => _maxStreak;
  bool get currentQuestionHintPenalized => _currentQuestionHintPenalized;

  /// Resets all session scoring and streak state.
  void reset() {
    _totalScore = 0;
    _currentStreak = 0;
    _maxStreak = 0;
    _currentQuestionHintPenalized = false;
  }

  /// Clears per-question hint tracking when advancing to the next question.
  void startNewQuestion() {
    _currentQuestionHintPenalized = false;
  }

  /// Marks that a hint was requested on the current question.
  ///
  /// The penalty is applied at most once per question and returns the penalty
  /// amount recorded on this call (`hintPenaltyPerQuestion` or `0`).
  int recordHintUsed() {
    if (_currentQuestionHintPenalized) {
      return 0;
    }
    _currentQuestionHintPenalized = true;
    return hintPenaltyPerQuestion;
  }

  /// Computes net points for a single question outcome cleanly without mutating
  /// manager state.
  int calculateQuestionScore({
    required bool isCorrect,
    bool usedHint = false,
    int resultingStreak = 0,
  }) {
    if (!isCorrect) {
      return incorrectPoints.clamp(0, incorrectPoints);
    }
    final penalty = usedHint ? hintPenaltyPerQuestion : 0;
    final base = (correctPoints - penalty).clamp(0, correctPoints);
    final bonus = resultingStreak == 3
        ? streak3Bonus
        : (resultingStreak == 5 ? streak5Bonus : 0);
    return base + bonus;
  }

  /// Records a question answer, updates streaks & total score (never negative),
  /// and returns the delta added to [totalScore].
  int recordAnswer({required bool isCorrect, bool usedHintOnQuestion = false}) {
    if (!isCorrect) {
      _currentStreak = 0;
      _totalScore = (_totalScore + incorrectPoints).clamp(0, 1 << 30);
      return incorrectPoints;
    }

    _currentStreak++;
    if (_currentStreak > _maxStreak) {
      _maxStreak = _currentStreak;
    }

    final earned = calculateQuestionScore(
      isCorrect: true,
      usedHint: usedHintOnQuestion || _currentQuestionHintPenalized,
      resultingStreak: _currentStreak,
    );
    _totalScore = (_totalScore + earned).clamp(0, 1 << 30);
    return earned;
  }
}
