import 'package:flutter/foundation.dart';

import '../integration/puzzle_completion_event.dart';
import '../integration/puzzle_integration_adapter.dart';
import '../integration/puzzle_request.dart';
import '../models/puzzle.dart';
import '../models/puzzle_enums.dart';
import '../models/puzzle_result.dart';
import 'puzzle_hint_service.dart';
import 'score_calculator.dart';

/// Lifecycle states for a single M3 puzzle session.
enum PuzzleGameState {
  initial,
  loading,
  ready,
  answering,
  correct,
  incorrect,
  completed,
  error,
}

/// Stateful controller enforcing valid M3 puzzle state transitions,
/// duplicate-submission prevention, progressive hints, and score calculation.
class PuzzleSessionController extends ChangeNotifier {
  PuzzleSessionController({
    required this.adapter,
    this.scoreCalculator = const ScoreCalculator(),
  });

  final PuzzleIntegrationAdapter adapter;
  final ScoreCalculator scoreCalculator;

  PuzzleGameState _state = PuzzleGameState.initial;
  PuzzleRequest? _request;
  Puzzle? _puzzle;
  HintSession? _hintSession;
  String? _activeHint;
  PuzzleResult? _lastResult;
  PuzzleCompletionEvent? _completionEvent;
  PuzzleIntegrationError? _error;

  int _attemptsUsed = 0;
  int _score = 0;
  final Set<String> _matchedOptionIds = {};
  final Set<String> _submittedWrongOptionIds = {};
  final List<PuzzleGameState> _stateHistory = [PuzzleGameState.initial];

  PuzzleGameState get state => _state;
  PuzzleRequest? get request => _request;
  Puzzle? get puzzle => _puzzle;
  PuzzlePresentation? get presentation => _puzzle?.prompt;
  String? get activeHint => _activeHint;
  PuzzleResult? get lastResult => _lastResult;
  PuzzleCompletionEvent? get completionEvent => _completionEvent;
  PuzzleIntegrationError? get error => _error;
  int get attemptsUsed => _attemptsUsed;
  int get hintsUsed => _hintSession?.hintsUsed ?? 0;
  int get score => _score;
  Set<String> get matchedOptionIds =>
      Set<String>.unmodifiable(_matchedOptionIds);
  List<PuzzleGameState> get stateHistory =>
      List<PuzzleGameState>.unmodifiable(_stateHistory);

  bool get canSubmit =>
      _puzzle != null &&
      (_state == PuzzleGameState.ready ||
          _state == PuzzleGameState.incorrect ||
          (_puzzle!.type == PuzzleType.wordMatching &&
              _state == PuzzleGameState.correct &&
              !_isWordMatchingFinished));

  bool get _isWordMatchingFinished =>
      _puzzle != null &&
      _puzzle!.type == PuzzleType.wordMatching &&
      (_matchedOptionIds.length ~/ 2) >= _puzzle!.prompt.options.length;

  /// Loads a puzzle for [request], transitioning `initial/error/completed -> loading -> ready | error`.
  Future<void> loadPuzzle(PuzzleRequest request) async {
    if (_state == PuzzleGameState.loading ||
        _state == PuzzleGameState.answering) {
      return;
    }

    _request = request;
    _puzzle = null;
    _hintSession = null;
    _activeHint = null;
    _lastResult = null;
    _completionEvent = null;
    _error = null;
    _attemptsUsed = 0;
    _score = 0;
    _matchedOptionIds.clear();
    _submittedWrongOptionIds.clear();
    _transitionTo(PuzzleGameState.loading);

    final outcome = await adapter.loadPuzzle(request);
    if (!outcome.isSuccess) {
      _error = outcome.error;
      _transitionTo(PuzzleGameState.error);
      return;
    }

    _puzzle = outcome.puzzle;
    _hintSession = adapter.startHintSession(_puzzle!);
    _transitionTo(PuzzleGameState.ready);
  }

  /// Requests the next non-repeating progressive hint when interactive.
  HintResponse? requestHint() {
    final session = _hintSession;
    if (session == null || !canSubmit) {
      return null;
    }
    final response = adapter.requestHint(session);
    if (response.hasHint) {
      _activeHint = response.text;
      notifyListeners();
    }
    return response;
  }

  /// Validates a player submission while blocking invalid transitions and
  /// duplicate submissions.
  PuzzleResult? submitAnswer({
    String? selectedOptionId,
    String? leftOptionId,
    String? rightOptionId,
    List<String>? selectedSyllables,
  }) {
    final currentPuzzle = _puzzle;
    final currentRequest = _request;
    if (currentPuzzle == null || currentRequest == null || !canSubmit) {
      return null;
    }

    // Prevent repeated submission of the exact same wrong Picture Matching choice.
    if (currentPuzzle.type == PuzzleType.pictureMatching &&
        selectedOptionId != null &&
        _submittedWrongOptionIds.contains(selectedOptionId.trim())) {
      return PuzzleResult(
        puzzleId: currentPuzzle.id,
        puzzleType: currentPuzzle.type,
        difficulty: currentPuzzle.difficulty,
        vocabularyId: currentPuzzle.targetVocabulary.id,
        isSolved: false,
        attempts: _attemptsUsed,
        hintsUsed: hintsUsed,
        feedbackMessage: 'You already tried that option. Choose another one!',
        isDuplicate: true,
      );
    }

    _transitionTo(PuzzleGameState.answering);

    final nextAttemptCount = _attemptsUsed + 1;
    final outcome = adapter.submitAnswer(
      request: currentRequest,
      puzzle: currentPuzzle,
      selectedOptionId: selectedOptionId,
      leftOptionId: leftOptionId,
      rightOptionId: rightOptionId,
      selectedSyllables: selectedSyllables,
      completedPairIds: _matchedOptionIds,
      attempts: nextAttemptCount,
      hintsUsed: hintsUsed,
      alreadyCompleted: _state == PuzzleGameState.completed,
    );

    if (!outcome.isSuccess || outcome.result == null) {
      _error = outcome.error;
      _transitionTo(PuzzleGameState.error);
      return null;
    }

    final rawResult = outcome.result!;
    if (rawResult.isDuplicate) {
      _lastResult = rawResult;
      _transitionTo(PuzzleGameState.incorrect);
      return rawResult;
    }

    if (rawResult.isSolved) {
      if (currentPuzzle.type == PuzzleType.wordMatching &&
          leftOptionId != null &&
          rightOptionId != null) {
        _matchedOptionIds.add(leftOptionId.trim());
        _matchedOptionIds.add(rightOptionId.trim());
      }

      final finished =
          currentPuzzle.type != PuzzleType.wordMatching ||
          _isWordMatchingFinished;
      final earnedScore = finished
          ? scoreCalculator.calculateScore(
              difficulty: currentPuzzle.difficulty,
              isSolved: true,
              attempts: nextAttemptCount,
              hintsUsed: hintsUsed,
            )
          : 0;

      final enrichedResult = PuzzleResult(
        puzzleId: rawResult.puzzleId,
        puzzleType: rawResult.puzzleType,
        difficulty: rawResult.difficulty,
        vocabularyId: rawResult.vocabularyId,
        isSolved: true,
        attempts: nextAttemptCount,
        hintsUsed: hintsUsed,
        score: earnedScore,
        feedbackMessage: rawResult.feedbackMessage,
        educationalNote: rawResult.educationalNote,
      );

      _lastResult = enrichedResult;
      _transitionTo(PuzzleGameState.correct);

      if (finished) {
        _score = earnedScore;
        _completionEvent = PuzzleCompletionEvent.fromResult(
          levelId: currentRequest.levelId,
          result: enrichedResult,
          isCompleted: true,
          score: earnedScore,
        );
        _transitionTo(PuzzleGameState.completed);
      }

      return enrichedResult;
    }

    // Incorrect submission.
    _attemptsUsed = nextAttemptCount;
    if (currentPuzzle.type == PuzzleType.pictureMatching &&
        selectedOptionId != null &&
        selectedOptionId.trim().isNotEmpty) {
      _submittedWrongOptionIds.add(selectedOptionId.trim());
    }

    final exhausted = _attemptsUsed >= currentPuzzle.prompt.maxAttempts;
    _lastResult = rawResult;
    _transitionTo(PuzzleGameState.incorrect);

    if (exhausted) {
      _score = 0;
      _completionEvent = PuzzleCompletionEvent.fromResult(
        levelId: currentRequest.levelId,
        result: rawResult,
        isCompleted: true,
        score: 0,
      );
      _transitionTo(PuzzleGameState.completed);
    }

    return rawResult;
  }

  /// Resets the session back to [PuzzleGameState.initial].
  void reset() {
    _request = null;
    _puzzle = null;
    _hintSession = null;
    _activeHint = null;
    _lastResult = null;
    _completionEvent = null;
    _error = null;
    _attemptsUsed = 0;
    _score = 0;
    _matchedOptionIds.clear();
    _submittedWrongOptionIds.clear();
    _transitionTo(PuzzleGameState.initial);
  }

  void _transitionTo(PuzzleGameState next) {
    _state = next;
    _stateHistory.add(next);
    notifyListeners();
  }
}
