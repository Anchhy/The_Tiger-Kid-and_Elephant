/// Configurable lives & mistake tracker for M3 Khmer puzzle sessions.
class LivesManager {
  LivesManager({int initialLives = 3, int? maxLives})
    : maxLives = maxLives ?? initialLives,
      _defaultInitialLives = initialLives {
    if (initialLives <= 0 || this.maxLives < initialLives) {
      throw ArgumentError(
        'initialLives must be > 0 and <= maxLives (got initialLives=$initialLives, maxLives=${this.maxLives}).',
      );
    }
    _remainingLives = initialLives;
  }

  final int maxLives;
  final int _defaultInitialLives;

  late int _remainingLives;
  int _mistakesMade = 0;

  int get remainingLives => _remainingLives;
  int get mistakesMade => _mistakesMade;
  bool get isGameOver => _remainingLives <= 0;

  /// Resets remaining lives back to [customInitialLives] (or default initial).
  void reset([int? customInitialLives]) {
    final target = customInitialLives ?? _defaultInitialLives;
    if (target <= 0 || target > maxLives) {
      throw ArgumentError(
        'customInitialLives must be between 1 and $maxLives (got $target).',
      );
    }
    _remainingLives = target;
    _mistakesMade = 0;
  }

  /// Deducts one life on an incorrect answer, clamped to `0`.
  int recordIncorrectAnswer() {
    _mistakesMade++;
    _remainingLives = (_remainingLives - 1).clamp(0, maxLives);
    return _remainingLives;
  }

  /// Correct answers cause zero life loss.
  int recordCorrectAnswer() => _remainingLives;

  /// Hint requests cause zero life loss.
  int recordHintUsed() => _remainingLives;

  /// Optionally restores [count] lives up to [maxLives].
  int restoreLife([int count = 1]) {
    if (count > 0) {
      _remainingLives = (_remainingLives + count).clamp(0, maxLives);
    }
    return _remainingLives;
  }
}
