import '../models/puzzle.dart';
import '../models/puzzle_enums.dart';
import '../models/puzzle_result.dart';
import '../repositories/khmer_puzzle_repository.dart';
import '../services/puzzle_generator.dart';
import '../services/puzzle_hint_service.dart';
import '../services/puzzle_validation_service.dart';
import 'puzzle_completion_event.dart';
import 'puzzle_request.dart';

/// UI-safe presentation alias reusing [PuzzlePrompt] without duplication.
typedef PuzzlePresentation = PuzzlePrompt;

/// Optional M5/M1 score calculator invoked upon puzzle completion.
typedef PuzzleScoreCalculator = int Function(PuzzleResult result);

/// Structured error returned across module boundaries instead of raw crashes.
class PuzzleIntegrationError {
  const PuzzleIntegrationError({required this.code, required this.message});

  final String code;
  final String message;
}

/// Result of requesting a puzzle through [PuzzleIntegrationAdapter].
class PuzzleLoadOutcome {
  const PuzzleLoadOutcome._({this.puzzle, this.error});

  const PuzzleLoadOutcome.success(Puzzle puzzle) : this._(puzzle: puzzle);

  const PuzzleLoadOutcome.failure(PuzzleIntegrationError error)
    : this._(error: error);

  final Puzzle? puzzle;
  final PuzzleIntegrationError? error;

  bool get isSuccess => puzzle != null && error == null;
  PuzzlePresentation? get presentation => puzzle?.prompt;
}

/// Result of submitting an answer through [PuzzleIntegrationAdapter].
class PuzzleSubmissionOutcome {
  const PuzzleSubmissionOutcome._({
    this.result,
    this.completionEvent,
    this.error,
  });

  const PuzzleSubmissionOutcome.success({
    required PuzzleResult result,
    PuzzleCompletionEvent? completionEvent,
  }) : this._(result: result, completionEvent: completionEvent);

  const PuzzleSubmissionOutcome.failure(PuzzleIntegrationError error)
    : this._(error: error);

  final PuzzleResult? result;
  final PuzzleCompletionEvent? completionEvent;
  final PuzzleIntegrationError? error;

  bool get isSuccess => result != null && error == null;
}

/// Clean boundary adapter connecting M1 level requests, M4 UI, and M5 state.
class PuzzleIntegrationAdapter {
  PuzzleIntegrationAdapter({
    required KhmerPuzzleRepository repository,
    PuzzleGenerator? generator,
    PuzzleValidationService? validator,
    PuzzleHintService? hintService,
    this.scoreCalculator,
  }) : _generator = generator ?? PuzzleGenerator(repository: repository),
       _validator = validator ?? const PuzzleValidationService(),
       _hintService = hintService ?? const PuzzleHintService();

  final PuzzleGenerator _generator;
  final PuzzleValidationService _validator;
  final PuzzleHintService _hintService;
  final PuzzleScoreCalculator? scoreCalculator;

  /// Parses an untyped M1/M5 JSON map and loads a puzzle safely.
  Future<PuzzleLoadOutcome> loadPuzzleFromJson(
    Map<String, dynamic> levelConfig,
  ) async {
    try {
      final request = PuzzleRequest.fromJson(levelConfig);
      return loadPuzzle(request);
    } on PuzzleRequestException catch (e) {
      return PuzzleLoadOutcome.failure(
        PuzzleIntegrationError(code: e.code, message: e.message),
      );
    }
  }

  /// Validates [request] and generates a puzzle with structured error handling.
  Future<PuzzleLoadOutcome> loadPuzzle(PuzzleRequest request) async {
    try {
      request.validate();
      final puzzle = await _generator.generate(
        type: request.puzzleType,
        difficulty: request.difficulty,
        category: request.category,
        targetVocabularyId: request.configuration.targetVocabularyId,
        onlyVerifiedSpelling: request.configuration.onlyVerifiedSpelling,
        onlyVerifiedMeaning: request.configuration.onlyVerifiedMeaning,
        requireVerifiedSyllables:
            request.configuration.requireVerifiedSyllables,
        requireImage: request.configuration.requireImage,
      );
      return PuzzleLoadOutcome.success(puzzle);
    } on PuzzleRequestException catch (e) {
      return PuzzleLoadOutcome.failure(
        PuzzleIntegrationError(code: e.code, message: e.message),
      );
    } on PuzzleGenerationException catch (e) {
      return PuzzleLoadOutcome.failure(
        PuzzleIntegrationError(
          code: 'INSUFFICIENT_VOCABULARY',
          message: e.message,
        ),
      );
    } on FormatException catch (e) {
      return PuzzleLoadOutcome.failure(
        PuzzleIntegrationError(
          code: 'VOCABULARY_LOAD_ERROR',
          message: e.message,
        ),
      );
    } on Exception catch (e) {
      return PuzzleLoadOutcome.failure(
        PuzzleIntegrationError(code: 'LOAD_ERROR', message: e.toString()),
      );
    }
  }

  /// Creates a progressive non-repeating [HintSession] for [puzzle].
  HintSession startHintSession(Puzzle puzzle) {
    return _hintService.startSession(
      target: puzzle.targetVocabulary,
      puzzleType: puzzle.type,
      difficulty: puzzle.difficulty,
    );
  }

  /// Requests the next progressive hint from [session].
  HintResponse requestHint(HintSession session) {
    return session.requestNextHint();
  }

  /// Validates an answer submission and emits a [PuzzleCompletionEvent] when
  /// the puzzle reaches a terminal state (solved or max attempts reached).
  PuzzleSubmissionOutcome submitAnswer({
    required PuzzleRequest request,
    required Puzzle puzzle,
    String? selectedOptionId,
    String? leftOptionId,
    String? rightOptionId,
    List<String>? selectedSyllables,
    Set<String> completedPairIds = const {},
    int attempts = 1,
    int hintsUsed = 0,
    bool alreadyCompleted = false,
  }) {
    if (puzzle.id.trim().isEmpty) {
      return const PuzzleSubmissionOutcome.failure(
        PuzzleIntegrationError(
          code: 'UNKNOWN_PUZZLE_ID',
          message: 'Unknown puzzle ID.',
        ),
      );
    }

    if (alreadyCompleted) {
      final duplicateResult = _validator.validateSubmission(
        puzzle: puzzle,
        selectedOptionId: selectedOptionId,
        leftOptionId: leftOptionId,
        rightOptionId: rightOptionId,
        selectedSyllables: selectedSyllables,
        completedPairIds: completedPairIds,
        attempts: attempts,
        hintsUsed: hintsUsed,
        alreadySolved: true,
      );
      return PuzzleSubmissionOutcome.success(
        result: duplicateResult,
        completionEvent: null,
      );
    }

    final result = _validator.validateSubmission(
      puzzle: puzzle,
      selectedOptionId: selectedOptionId,
      leftOptionId: leftOptionId,
      rightOptionId: rightOptionId,
      selectedSyllables: selectedSyllables,
      completedPairIds: completedPairIds,
      attempts: attempts,
      hintsUsed: hintsUsed,
    );

    final outOfAttempts =
        !result.isSolved && attempts >= puzzle.prompt.maxAttempts;
    final roundSolved =
        result.isSolved &&
        (puzzle.type != PuzzleType.wordMatching ||
            (completedPairIds.length ~/ 2) + 1 >= puzzle.prompt.options.length);
    final isTerminal = roundSolved || outOfAttempts;

    final completionEvent = isTerminal
        ? PuzzleCompletionEvent.fromResult(
            levelId: request.levelId,
            result: result,
            isCompleted: true,
            score: roundSolved ? scoreCalculator?.call(result) : null,
          )
        : null;

    return PuzzleSubmissionOutcome.success(
      result: result,
      completionEvent: completionEvent,
    );
  }
}
