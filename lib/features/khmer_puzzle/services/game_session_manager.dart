import 'package:flutter/foundation.dart';

import '../models/game_session_models.dart';
import '../models/puzzle.dart';
import '../models/puzzle_enums.dart';
import '../models/puzzle_result.dart';
import '../repositories/khmer_puzzle_repository.dart';
import 'game_score_manager.dart';
import 'lives_manager.dart';
import 'puzzle_difficulty_service.dart';
import 'puzzle_generator.dart';
import 'puzzle_hint_service.dart';
import 'puzzle_validation_service.dart';

/// Deterministic multi-question M3 game session orchestrator.
///
/// Manages configuration validation, non-repeating question selection across
/// a session, answer validation, score/streak calculation, lives tracking,
/// progressive hints, pause/resume transitions, and structured [GameResult]
/// generation without relying on UI timers or M2/M4/M5 internals.
class GameSessionManager extends ChangeNotifier {
  GameSessionManager({
    required this.repository,
    PuzzleGenerator? generator,
    PuzzleValidationService? validator,
    PuzzleHintService? hintService,
    PuzzleDifficultyService? difficultyService,
    GameScoreManager? scoreManager,
    LivesManager? livesManager,
  }) : _difficultyService =
           difficultyService ?? const PuzzleDifficultyService(),
       _generator =
           generator ??
           PuzzleGenerator(
             repository: repository,
             difficultyService: difficultyService,
           ),
       _validator = validator ?? const PuzzleValidationService(),
       _hintService =
           hintService ??
           PuzzleHintService(
             difficultyService:
                 difficultyService ?? const PuzzleDifficultyService(),
           ),
       scoreManager = scoreManager ?? GameScoreManager(),
       livesManager = livesManager ?? LivesManager();

  final KhmerPuzzleRepository repository;
  final PuzzleDifficultyService _difficultyService;
  final PuzzleGenerator _generator;
  final PuzzleValidationService _validator;
  final PuzzleHintService _hintService;
  final GameScoreManager scoreManager;
  final LivesManager livesManager;

  GameConfig _config = const GameConfig();
  GameSessionStatus _status = GameSessionStatus.initializing;
  GameSessionStatus _prePauseStatus = GameSessionStatus.playing;

  Puzzle? _currentQuestion;
  HintSession? _currentHintSession;
  String? _activeHint;
  PuzzleResult? _lastAnswerResult;
  String? _errorMessage;

  int _currentQuestionIndex = 0;
  int _questionsAttempted = 0;
  int _correctAnswers = 0;
  int _incorrectAnswers = 0;
  int _totalHintsUsed = 0;

  final Set<String> _usedVocabularyIds = {};
  final Set<String> _matchedPairOptionIds = {};

  GameConfig get config => _config;
  GameSessionStatus get status => _status;
  Puzzle? get currentQuestion => _currentQuestion;
  PuzzlePrompt? get currentPresentation => _currentQuestion?.prompt;
  String? get activeHint => _activeHint;
  PuzzleResult? get lastAnswerResult => _lastAnswerResult;
  String? get errorMessage => _errorMessage;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get questionsAttempted => _questionsAttempted;
  int get correctAnswers => _correctAnswers;
  int get incorrectAnswers => _incorrectAnswers;
  int get totalHintsUsed => _totalHintsUsed;
  int get totalScore => scoreManager.totalScore;
  int get currentStreak => scoreManager.currentStreak;
  int get maxStreak => scoreManager.maxStreak;
  int get remainingLives => livesManager.remainingLives;
  Set<String> get usedVocabularyIds =>
      Set<String>.unmodifiable(_usedVocabularyIds);
  Set<String> get matchedPairOptionIds =>
      Set<String>.unmodifiable(_matchedPairOptionIds);

  /// Initializes and starts a new multi-question session for [customConfig].
  Future<void> startSession([GameConfig? customConfig]) async {
    final nextConfig = customConfig ?? _config;
    nextConfig.validate();

    _config = nextConfig;
    _status = GameSessionStatus.initializing;
    _errorMessage = null;
    _currentQuestion = null;
    _currentHintSession = null;
    _activeHint = null;
    _lastAnswerResult = null;
    _currentQuestionIndex = 0;
    _questionsAttempted = 0;
    _correctAnswers = 0;
    _incorrectAnswers = 0;
    _totalHintsUsed = 0;
    _usedVocabularyIds.clear();
    _matchedPairOptionIds.clear();

    scoreManager.reset();
    livesManager.reset(nextConfig.initialLives);
    notifyListeners();

    await _loadQuestionAt(
      questionIndex: 0,
      readyStatus: GameSessionStatus.ready,
    );
  }

  /// Moves from [GameSessionStatus.ready] into active [GameSessionStatus.playing].
  void beginPlaying() {
    if (_status != GameSessionStatus.ready) {
      return;
    }
    _status = GameSessionStatus.playing;
    notifyListeners();
  }

  /// Requests the next non-repeating hint for the current question.
  ///
  /// Applies at most one hint score deduction per question via [scoreManager]
  /// and causes zero life loss.
  HintResponse? requestHint() {
    if (_status != GameSessionStatus.ready &&
        _status != GameSessionStatus.playing) {
      return null;
    }
    final session = _currentHintSession;
    if (session == null) {
      return null;
    }

    final response = session.requestNextHint();
    if (response.hasHint) {
      _activeHint = response.text;
      _totalHintsUsed++;
      scoreManager.recordHintUsed();
      livesManager.recordHintUsed();
      notifyListeners();
    }
    return response;
  }

  /// Validates the player's answer while enforcing state guards and preventing
  /// duplicate submissions once in feedback, paused, completed, or gameOver.
  PuzzleResult? submitAnswer({
    String? selectedOptionId,
    String? leftOptionId,
    String? rightOptionId,
    List<String>? selectedSyllables,
    String? submittedMeaningText,
  }) {
    if (_status != GameSessionStatus.ready &&
        _status != GameSessionStatus.playing) {
      return null;
    }

    final puzzle = _currentQuestion;
    if (puzzle == null) {
      return null;
    }

    if (_status == GameSessionStatus.ready) {
      _status = GameSessionStatus.playing;
    }

    final PuzzleResult result;
    if (submittedMeaningText != null) {
      final check = _validator.validateMeaningText(
        target: puzzle.targetVocabulary,
        submittedMeaning: submittedMeaningText,
      );
      result = PuzzleResult(
        puzzleId: puzzle.id,
        puzzleType: puzzle.type,
        difficulty: puzzle.difficulty,
        vocabularyId: puzzle.targetVocabulary.id,
        isSolved: check.isCorrect,
        attempts: 1,
        hintsUsed: _currentHintSession?.hintsUsed ?? 0,
        feedbackMessage: check.feedbackMessage,
        educationalNote: check.educationalNote,
        isDuplicate: check.isDuplicate,
        validationStatus: check.status,
      );
    } else {
      result = _validator.validateSubmission(
        puzzle: puzzle,
        selectedOptionId: selectedOptionId,
        leftOptionId: leftOptionId,
        rightOptionId: rightOptionId,
        selectedSyllables: selectedSyllables,
        completedPairIds: _matchedPairOptionIds,
        attempts: 1,
        hintsUsed: _currentHintSession?.hintsUsed ?? 0,
      );
    }

    if (result.validationStatus == AnswerValidationStatus.invalidInput) {
      _lastAnswerResult = result;
      notifyListeners();
      return result;
    }

    // Support progressive multi-pair completion for Word Matching rounds.
    if (puzzle.type == PuzzleType.wordMatching &&
        submittedMeaningText == null &&
        leftOptionId != null &&
        rightOptionId != null) {
      if (result.isSolved) {
        _matchedPairOptionIds.add(leftOptionId.trim());
        _matchedPairOptionIds.add(rightOptionId.trim());
        final allPairsMatched =
            (_matchedPairOptionIds.length ~/ 2) >= puzzle.prompt.options.length;
        if (!allPairsMatched) {
          _lastAnswerResult = result;
          notifyListeners();
          return result;
        }
      }
    }

    _questionsAttempted++;
    _usedVocabularyIds.add(puzzle.targetVocabulary.id);

    if (result.isSolved) {
      _correctAnswers++;
      final earned = scoreManager.recordAnswer(isCorrect: true);
      livesManager.recordCorrectAnswer();
      _lastAnswerResult = PuzzleResult(
        puzzleId: result.puzzleId,
        puzzleType: result.puzzleType,
        difficulty: result.difficulty,
        vocabularyId: result.vocabularyId,
        isSolved: true,
        attempts: result.attempts,
        hintsUsed: result.hintsUsed,
        score: earned,
        feedbackMessage: result.feedbackMessage,
        educationalNote: result.educationalNote,
        validationStatus: result.validationStatus,
      );
      _status = GameSessionStatus.answerFeedback;
    } else {
      _incorrectAnswers++;
      scoreManager.recordAnswer(isCorrect: false);
      livesManager.recordIncorrectAnswer();
      _lastAnswerResult = result;
      _status = livesManager.isGameOver
          ? GameSessionStatus.gameOver
          : GameSessionStatus.answerFeedback;
    }

    notifyListeners();
    return _lastAnswerResult;
  }

  /// Advances from [GameSessionStatus.answerFeedback] to the next question, or
  /// transitions to [GameSessionStatus.completed] when the session goal is met.
  Future<bool> nextQuestion() async {
    if (_status != GameSessionStatus.answerFeedback) {
      return false;
    }
    if (livesManager.isGameOver) {
      _status = GameSessionStatus.gameOver;
      notifyListeners();
      return false;
    }

    _status = GameSessionStatus.nextQuestion;
    if (_questionsAttempted >= _config.questionsPerSession) {
      _status = GameSessionStatus.completed;
      notifyListeners();
      return false;
    }

    _currentQuestionIndex++;
    _activeHint = null;
    _lastAnswerResult = null;
    _matchedPairOptionIds.clear();
    scoreManager.startNewQuestion();

    await _loadQuestionAt(
      questionIndex: _currentQuestionIndex,
      readyStatus: GameSessionStatus.playing,
    );
    return _status == GameSessionStatus.playing;
  }

  /// Pauses an active session cleanly without affecting lives or score.
  void pauseSession() {
    if (_status == GameSessionStatus.ready ||
        _status == GameSessionStatus.playing ||
        _status == GameSessionStatus.answerFeedback) {
      _prePauseStatus = _status;
      _status = GameSessionStatus.paused;
      notifyListeners();
    }
  }

  /// Restores a paused session back to its prior active state.
  void resumeSession() {
    if (_status != GameSessionStatus.paused) {
      return;
    }
    _status = _prePauseStatus;
    notifyListeners();
  }

  /// Returns an immutable summary snapshot of the current/completed session.
  GameResult buildResult() {
    final resolvedStatus = _status == GameSessionStatus.gameOver
        ? GameSessionStatus.gameOver
        : GameSessionStatus.completed;

    return GameResult(
      totalScore: scoreManager.totalScore,
      correctAnswers: _correctAnswers,
      incorrectAnswers: _incorrectAnswers,
      questionsAttempted: _questionsAttempted,
      accuracyPercentage: GameResult.calculateAccuracy(
        correctAnswers: _correctAnswers,
        questionsAttempted: _questionsAttempted,
      ),
      hintsUsed: _totalHintsUsed,
      maxStreak: scoreManager.maxStreak,
      livesRemaining: livesManager.remainingLives,
      completionStatus: resolvedStatus,
    );
  }

  Future<void> _loadQuestionAt({
    required int questionIndex,
    required GameSessionStatus readyStatus,
  }) async {
    try {
      final eligibleCount = await _countEligibleTargets();
      if (eligibleCount > 0 && _usedVocabularyIds.length >= eligibleCount) {
        _usedVocabularyIds.clear();
      }

      Puzzle generated;
      try {
        generated = await _generateSingleQuestion();
      } on PuzzleGenerationException {
        if (_usedVocabularyIds.isEmpty) {
          rethrow;
        }
        _usedVocabularyIds.clear();
        generated = await _generateSingleQuestion();
      }

      // If generator wrapped due to category/difficulty subset exhaustion,
      // reset the exclusion pool cleanly for the next cycle while recording
      // this cycle's new target.
      if (_usedVocabularyIds.contains(generated.targetVocabulary.id)) {
        _usedVocabularyIds.clear();
      }

      _currentQuestion = generated;
      _currentHintSession = _hintService.startSession(
        target: generated.targetVocabulary,
        puzzleType: generated.type,
        difficulty: generated.difficulty,
      );
      _status = readyStatus;
    } on Exception catch (error) {
      _errorMessage = error.toString();
      _status = GameSessionStatus.gameOver;
    }
    notifyListeners();
  }

  Future<int> _countEligibleTargets() async {
    final pool = await repository.queryVocabulary(
      VocabularyQuery(category: _config.category),
    );
    final allowedTiers = _difficultyService
        .getSettings(_config.difficulty)
        .allowedVocabularyTiers;

    final filtered = switch (_config.puzzleType) {
      PuzzleType.pictureMatching => pool.where(
        (item) =>
            (!_config.requireImage || item.hasImage) &&
            allowedTiers.contains(item.difficulty),
      ),
      PuzzleType.wordMatching => pool.where(
        (item) =>
            item.englishMeaning.trim().isNotEmpty &&
            allowedTiers.contains(item.difficulty),
      ),
      PuzzleType.syllableOrdering => pool.where(
        (item) =>
            item.supportsSyllableOrdering &&
            (!_config.requireVerifiedSyllables ||
                item.verification.areSyllablesVerified) &&
            allowedTiers.contains(item.difficulty),
      ),
    };
    return filtered.length;
  }

  Future<Puzzle> _generateSingleQuestion() {
    return _generator.generate(
      type: _config.puzzleType,
      difficulty: _config.difficulty,
      category: _config.category,
      excludeVocabularyIds: _usedVocabularyIds,
      requireVerifiedSyllables: _config.requireVerifiedSyllables,
      requireImage: _config.requireImage,
    );
  }
}
