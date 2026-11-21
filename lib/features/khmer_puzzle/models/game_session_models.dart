import 'puzzle_enums.dart';

/// Lifecycle states for a multi-question M3 game session.
enum GameSessionStatus {
  initializing,
  ready,
  playing,
  answerFeedback,
  nextQuestion,
  completed,
  gameOver,
  paused,
}

/// Question formats supported by Word Matching rounds.
enum WordMatchingFormat { khmerToEnglish, khmerToPicture }

/// Configuration for a multi-question M3 session managed by
/// `GameSessionManager`.
class GameConfig {
  const GameConfig({
    this.questionsPerSession = 10,
    this.initialLives = 3,
    this.maxLives,
    this.difficulty = PuzzleDifficulty.easy,
    this.puzzleType = PuzzleType.pictureMatching,
    this.wordMatchingFormat = WordMatchingFormat.khmerToEnglish,
    this.category,
    this.requireVerifiedSyllables = true,
    this.requireImage = true,
  });

  final int questionsPerSession;
  final int initialLives;
  final int? maxLives;
  final PuzzleDifficulty difficulty;
  final PuzzleType puzzleType;
  final WordMatchingFormat wordMatchingFormat;
  final String? category;
  final bool requireVerifiedSyllables;
  final bool requireImage;

  int get resolvedMaxLives => maxLives ?? initialLives;

  /// Validates that session limits and lives configuration are positive.
  void validate() {
    if (questionsPerSession <= 0) {
      throw ArgumentError.value(
        questionsPerSession,
        'questionsPerSession',
        'Must be greater than zero.',
      );
    }
    if (initialLives <= 0) {
      throw ArgumentError.value(
        initialLives,
        'initialLives',
        'Must be greater than zero.',
      );
    }
    if (resolvedMaxLives < initialLives) {
      throw ArgumentError.value(
        resolvedMaxLives,
        'maxLives',
        'Must be >= initialLives.',
      );
    }
  }
}

/// Structured session outcome returned by M3 for M5 progress persistence.
class GameResult {
  const GameResult({
    required this.totalScore,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.questionsAttempted,
    required this.accuracyPercentage,
    required this.hintsUsed,
    required this.maxStreak,
    required this.livesRemaining,
    required this.completionStatus,
  });

  final int totalScore;
  final int correctAnswers;
  final int incorrectAnswers;
  final int questionsAttempted;
  final double accuracyPercentage;
  final int hintsUsed;
  final int maxStreak;
  final int livesRemaining;
  final GameSessionStatus completionStatus;

  /// Computes a 1–3 star rating from [accuracyPercentage] (`0` if game over
  /// with zero correct answers):
  /// - `>= 90%` -> `3` stars
  /// - `>= 70%` -> `2` stars
  /// - `< 70%`  -> `1` star
  int get starRating {
    if (completionStatus == GameSessionStatus.gameOver && correctAnswers == 0) {
      return 0;
    }
    if (accuracyPercentage >= 90.0) {
      return 3;
    }
    if (accuracyPercentage >= 70.0) {
      return 2;
    }
    return 1;
  }

  /// Computes accuracy percentage safely without dividing by zero.
  static double calculateAccuracy({
    required int correctAnswers,
    required int questionsAttempted,
  }) {
    if (questionsAttempted <= 0) {
      return 0.0;
    }
    return (correctAnswers / questionsAttempted) * 100.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'totalScore': totalScore,
      'correctAnswers': correctAnswers,
      'incorrectAnswers': incorrectAnswers,
      'questionsAttempted': questionsAttempted,
      'accuracyPercentage': accuracyPercentage,
      'hintsUsed': hintsUsed,
      'maxStreak': maxStreak,
      'livesRemaining': livesRemaining,
      'completionStatus': completionStatus.name,
      'starRating': starRating,
    };
  }

  factory GameResult.fromJson(Map<String, dynamic> json) {
    final statusName = json['completionStatus'] as String? ?? 'completed';
    final parsedStatus = GameSessionStatus.values.firstWhere(
      (s) => s.name == statusName,
      orElse: () => GameSessionStatus.completed,
    );

    return GameResult(
      totalScore: (json['totalScore'] as num? ?? 0).toInt(),
      correctAnswers: (json['correctAnswers'] as num? ?? 0).toInt(),
      incorrectAnswers: (json['incorrectAnswers'] as num? ?? 0).toInt(),
      questionsAttempted: (json['questionsAttempted'] as num? ?? 0).toInt(),
      accuracyPercentage: (json['accuracyPercentage'] as num? ?? 0.0)
          .toDouble(),
      hintsUsed: (json['hintsUsed'] as num? ?? 0).toInt(),
      maxStreak: (json['maxStreak'] as num? ?? 0).toInt(),
      livesRemaining: (json['livesRemaining'] as num? ?? 0).toInt(),
      completionStatus: parsedStatus,
    );
  }
}
