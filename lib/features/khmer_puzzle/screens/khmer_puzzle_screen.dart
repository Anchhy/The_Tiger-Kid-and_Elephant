import 'package:flutter/material.dart';

import '../integration/puzzle_completion_event.dart';
import '../integration/puzzle_integration_adapter.dart';
import '../integration/puzzle_request.dart';
import '../models/puzzle.dart';
import '../models/puzzle_enums.dart';
import '../models/puzzle_result.dart';
import '../repositories/khmer_puzzle_repository.dart';
import '../services/puzzle_hint_service.dart';
import '../services/puzzle_validation_service.dart';
import '../widgets/angkor_puzzle_theme.dart';
import '../widgets/picture_matching_widget.dart';
import '../widgets/puzzle_state_views.dart';
import '../widgets/syllable_ordering_widget.dart';
import '../widgets/word_matching_widget.dart';

/// Public entry-point screen for launching any M3 Khmer puzzle mode.
///
/// External modules (such as M2 gameplay checkpoints or M5 navigation) can
/// push or embed this widget directly, construct it from a [PuzzleRequest] via
/// [KhmerPuzzleScreen.fromRequest], or show it over a Flame scene via
/// [KhmerPuzzleScreen.showAsDialog].
class KhmerPuzzleScreen extends StatefulWidget {
  const KhmerPuzzleScreen({
    super.key,
    required this.puzzleType,
    required this.difficulty,
    this.levelId = 'standalone_puzzle',
    this.repository,
    this.adapter,
    this.category,
    this.targetVocabularyId,
    this.requireVerifiedSyllables = true,
    this.requireImage = false,
    this.onlyVerifiedSpelling = false,
    this.onlyVerifiedMeaning = false,
    this.scoreCalculator,
    this.onCompleted,
    this.onCompletionEvent,
    this.onAnswerFeedback,
    this.onHintRequested,
    this.onLoadError,
    this.onClose,
    this.imageBuilder,
  });

  /// Creates a [KhmerPuzzleScreen] directly from an M1/M5 [PuzzleRequest].
  KhmerPuzzleScreen.fromRequest({
    super.key,
    required PuzzleRequest request,
    this.repository,
    this.adapter,
    this.scoreCalculator,
    this.onCompleted,
    this.onCompletionEvent,
    this.onAnswerFeedback,
    this.onHintRequested,
    this.onLoadError,
    this.onClose,
    this.imageBuilder,
  }) : levelId = request.levelId,
       puzzleType = request.puzzleType,
       difficulty = request.difficulty,
       category = request.category,
       targetVocabularyId = request.configuration.targetVocabularyId,
       requireVerifiedSyllables =
           request.configuration.requireVerifiedSyllables,
       requireImage = request.configuration.requireImage,
       onlyVerifiedSpelling = request.configuration.onlyVerifiedSpelling,
       onlyVerifiedMeaning = request.configuration.onlyVerifiedMeaning;

  final String levelId;
  final PuzzleType puzzleType;
  final PuzzleDifficulty difficulty;
  final KhmerPuzzleRepository? repository;
  final PuzzleIntegrationAdapter? adapter;
  final String? category;
  final String? targetVocabularyId;
  final bool requireVerifiedSyllables;
  final bool requireImage;
  final bool onlyVerifiedSpelling;
  final bool onlyVerifiedMeaning;
  final PuzzleScoreCalculator? scoreCalculator;
  final ValueChanged<PuzzleResult>? onCompleted;
  final ValueChanged<PuzzleCompletionEvent>? onCompletionEvent;
  final ValueChanged<PuzzleResult>? onAnswerFeedback;
  final ValueChanged<HintResponse>? onHintRequested;
  final ValueChanged<PuzzleIntegrationError>? onLoadError;
  final VoidCallback? onClose;
  final VocabularyImageBuilder? imageBuilder;

  /// Effective M3 [PuzzleRequest] represented by this screen configuration.
  PuzzleRequest get effectiveRequest => PuzzleRequest(
    levelId: levelId,
    puzzleType: puzzleType,
    difficulty: difficulty,
    category: category,
    configuration: PuzzleRequestConfig(
      targetVocabularyId: targetVocabularyId,
      requireVerifiedSyllables: requireVerifiedSyllables,
      requireImage: requireImage,
      onlyVerifiedSpelling: onlyVerifiedSpelling,
      onlyVerifiedMeaning: onlyVerifiedMeaning,
    ),
  );

  /// Launches [request] as an Angkor-styled modal overlay suitable for
  /// Flame `GameScreen` checkpoints, returning the emitted
  /// [PuzzleCompletionEvent] when the player closes the overlay.
  static Future<PuzzleCompletionEvent?> showAsDialog(
    BuildContext context, {
    required PuzzleRequest request,
    KhmerPuzzleRepository? repository,
    PuzzleIntegrationAdapter? adapter,
    PuzzleScoreCalculator? scoreCalculator,
    ValueChanged<PuzzleCompletionEvent>? onCompletionEvent,
    ValueChanged<PuzzleResult>? onAnswerFeedback,
    ValueChanged<HintResponse>? onHintRequested,
    ValueChanged<PuzzleIntegrationError>? onLoadError,
    VocabularyImageBuilder? imageBuilder,
  }) {
    PuzzleCompletionEvent? capturedEvent;

    return showDialog<PuzzleCompletionEvent?>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final palette = AngkorPuzzleTheme.of(context);
        return Theme(
          data: AngkorPuzzleTheme.storybookThemeData(),
          child: Dialog(
            backgroundColor: palette.parchmentSurface,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: palette.sandstoneBorder, width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760, maxHeight: 580),
              child: KhmerPuzzleScreen.fromRequest(
                request: request,
                repository: repository,
                adapter: adapter,
                scoreCalculator: scoreCalculator,
                onCompletionEvent: (event) {
                  capturedEvent = event;
                  onCompletionEvent?.call(event);
                },
                onAnswerFeedback: onAnswerFeedback,
                onHintRequested: onHintRequested,
                onLoadError: onLoadError,
                imageBuilder: imageBuilder,
                onClose: () => Navigator.of(dialogContext).pop(capturedEvent),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  State<KhmerPuzzleScreen> createState() => _KhmerPuzzleScreenState();
}

class _KhmerPuzzleScreenState extends State<KhmerPuzzleScreen> {
  late KhmerPuzzleRepository _repository;
  late PuzzleIntegrationAdapter _adapter;

  Puzzle? _puzzle;
  bool _isLoading = true;
  bool _completionEmitted = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initAndLoad();
  }

  @override
  void didUpdateWidget(covariant KhmerPuzzleScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.levelId != widget.levelId ||
        oldWidget.puzzleType != widget.puzzleType ||
        oldWidget.difficulty != widget.difficulty ||
        oldWidget.repository != widget.repository ||
        oldWidget.adapter != widget.adapter ||
        oldWidget.category != widget.category ||
        oldWidget.targetVocabularyId != widget.targetVocabularyId ||
        oldWidget.requireVerifiedSyllables != widget.requireVerifiedSyllables ||
        oldWidget.requireImage != widget.requireImage ||
        oldWidget.onlyVerifiedSpelling != widget.onlyVerifiedSpelling ||
        oldWidget.onlyVerifiedMeaning != widget.onlyVerifiedMeaning) {
      _initAndLoad();
    }
  }

  void _initAndLoad() {
    _repository = widget.repository ?? KhmerPuzzleRepository();
    _adapter =
        widget.adapter ??
        PuzzleIntegrationAdapter(
          repository: _repository,
          scoreCalculator: widget.scoreCalculator,
        );
    _loadPuzzle();
  }

  Future<void> _loadPuzzle() async {
    setState(() {
      _isLoading = true;
      _completionEmitted = false;
      _errorMessage = null;
    });

    final outcome = await _adapter.loadPuzzle(widget.effectiveRequest);
    if (!mounted) {
      return;
    }

    if (!outcome.isSuccess) {
      final error = outcome.error;
      setState(() {
        _puzzle = null;
        _errorMessage = error?.message ?? 'Failed to load puzzle.';
        _isLoading = false;
      });
      if (error != null) {
        widget.onLoadError?.call(error);
      }
      return;
    }

    setState(() {
      _puzzle = outcome.puzzle;
      _isLoading = false;
    });
  }

  void _handleCompleted(PuzzleResult result) {
    if (_completionEmitted) {
      return;
    }
    _completionEmitted = true;
    widget.onCompleted?.call(result);

    final computedScore = result.isSolved
        ? (widget.scoreCalculator?.call(result) ??
              _adapter.scoreCalculator?.call(result) ??
              result.score)
        : null;

    final event = PuzzleCompletionEvent.fromResult(
      levelId: widget.levelId,
      result: result,
      isCompleted: true,
      score: computedScore,
    );
    widget.onCompletionEvent?.call(event);
  }

  void _closeScreen() {
    if (widget.onClose != null) {
      widget.onClose!.call();
      return;
    }
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    const validator = PuzzleValidationService();
    const hintService = PuzzleHintService();

    final body = switch (widget.puzzleType) {
      PuzzleType.pictureMatching => PictureMatchingWidget(
        puzzle: _puzzle,
        isLoading: _isLoading,
        errorMessage: _errorMessage,
        onRetry: _loadPuzzle,
        onClose: _closeScreen,
        onCompleted: _handleCompleted,
        onAnswerFeedback: widget.onAnswerFeedback,
        onHintRequested: widget.onHintRequested,
        validator: validator,
        hintService: hintService,
        imageBuilder: widget.imageBuilder,
      ),
      PuzzleType.wordMatching => WordMatchingWidget(
        puzzle: _puzzle,
        isLoading: _isLoading,
        errorMessage: _errorMessage,
        onRetry: _loadPuzzle,
        onClose: _closeScreen,
        onCompleted: _handleCompleted,
        onAnswerFeedback: widget.onAnswerFeedback,
        onHintRequested: widget.onHintRequested,
        validator: validator,
        hintService: hintService,
      ),
      PuzzleType.syllableOrdering => SyllableOrderingWidget(
        puzzle: _puzzle,
        isLoading: _isLoading,
        errorMessage: _errorMessage,
        onRetry: _loadPuzzle,
        onClose: _closeScreen,
        onCompleted: _handleCompleted,
        onAnswerFeedback: widget.onAnswerFeedback,
        onHintRequested: widget.onHintRequested,
        validator: validator,
        hintService: hintService,
      ),
    };

    return Scaffold(body: SafeArea(child: body));
  }
}
