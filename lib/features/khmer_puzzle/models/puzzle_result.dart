import 'puzzle_enums.dart';

/// Outcome returned when a Khmer puzzle submission or session concludes.
///
/// Used by gameplay (M2) and navigation/persistence (M5) to unlock doors,
/// award progress, or handle failed attempts without coupling to puzzle UI.
class PuzzleResult {
  const PuzzleResult({
    required this.puzzleType,
    required this.difficulty,
    required this.vocabularyId,
    required this.isSolved,
    this.puzzleId = '',
    this.attempts = 0,
    this.hintsUsed = 0,
    this.score = 0,
    this.feedbackMessage = '',
    this.educationalNote = '',
    this.isDuplicate = false,
    AnswerValidationStatus? validationStatus,
  }) : validationStatus =
           validationStatus ??
           (isSolved
               ? AnswerValidationStatus.correct
               : AnswerValidationStatus.incorrect);

  final String puzzleId;
  final PuzzleType puzzleType;
  final PuzzleDifficulty difficulty;
  final String vocabularyId;
  final bool isSolved;
  final int attempts;
  final int hintsUsed;
  final int score;
  final String feedbackMessage;
  final String educationalNote;
  final bool isDuplicate;

  /// Explicit validation status classifying correct, incorrect, and invalid inputs.
  final AnswerValidationStatus validationStatus;
}
