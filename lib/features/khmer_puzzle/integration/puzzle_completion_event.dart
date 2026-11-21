import '../models/puzzle_enums.dart';
import '../models/puzzle_result.dart';

/// Standardized completion event emitted by M3 for M2 gameplay and M5 saving.
class PuzzleCompletionEvent {
  const PuzzleCompletionEvent({
    required this.levelId,
    required this.puzzleId,
    required this.puzzleType,
    required this.difficulty,
    required this.vocabularyId,
    required this.isCompleted,
    required this.isCorrect,
    required this.attempts,
    required this.hintsUsed,
    this.score,
    this.feedbackMessage = '',
    this.educationalNote = '',
  });

  final String levelId;
  final String puzzleId;
  final PuzzleType puzzleType;
  final PuzzleDifficulty difficulty;
  final String vocabularyId;

  /// Whether the puzzle round reached a terminal state (solved or attempts exhausted).
  final bool isCompleted;

  /// Whether the player solved the puzzle correctly.
  final bool isCorrect;

  final int attempts;
  final int hintsUsed;

  /// Optional score populated when M5/M1 provides a scoring rule.
  final int? score;

  final String feedbackMessage;
  final String educationalNote;

  factory PuzzleCompletionEvent.fromResult({
    required String levelId,
    required PuzzleResult result,
    required bool isCompleted,
    int? score,
  }) {
    return PuzzleCompletionEvent(
      levelId: levelId,
      puzzleId: result.puzzleId,
      puzzleType: result.puzzleType,
      difficulty: result.difficulty,
      vocabularyId: result.vocabularyId,
      isCompleted: isCompleted,
      isCorrect: result.isSolved,
      attempts: result.attempts,
      hintsUsed: result.hintsUsed,
      score: score,
      feedbackMessage: result.feedbackMessage,
      educationalNote: result.educationalNote,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'levelId': levelId,
      'puzzleId': puzzleId,
      'puzzleType': puzzleType.name,
      'difficulty': difficulty.name,
      'vocabularyId': vocabularyId,
      'isCompleted': isCompleted,
      'isCorrect': isCorrect,
      'attempts': attempts,
      'hintsUsed': hintsUsed,
      if (score != null) 'score': score,
      'feedbackMessage': feedbackMessage,
      'educationalNote': educationalNote,
    };
  }
}
