import 'package:flutter/material.dart';

import '../models/puzzle.dart';
import '../models/puzzle_result.dart';
import '../services/puzzle_hint_service.dart';
import '../services/puzzle_validation_service.dart';
import '../utils/khmer_text_utils.dart';
import 'angkor_puzzle_theme.dart';
import 'hint_button.dart';
import 'puzzle_feedback_banner.dart';
import 'puzzle_header.dart';
import 'puzzle_progress.dart';
import 'puzzle_state_views.dart';
import 'puzzle_tactile_motion.dart';

/// Interactive Word Matching puzzle widget pairing Khmer words with meanings.
class WordMatchingWidget extends StatefulWidget {
  const WordMatchingWidget({
    super.key,
    required this.puzzle,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    this.onClose,
    this.onCompleted,
    this.onAnswerFeedback,
    this.onPairMatched,
    this.onHintRequested,
    this.validator = const PuzzleValidationService(),
    this.hintService = const PuzzleHintService(),
  });

  final Puzzle? puzzle;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onClose;
  final ValueChanged<PuzzleResult>? onCompleted;
  final ValueChanged<PuzzleResult>? onAnswerFeedback;
  final ValueChanged<PuzzleResult>? onPairMatched;
  final ValueChanged<HintResponse>? onHintRequested;
  final PuzzleValidationService validator;
  final PuzzleHintService hintService;

  @override
  State<WordMatchingWidget> createState() => _WordMatchingWidgetState();
}

class _WordMatchingWidgetState extends State<WordMatchingWidget> {
  String? _selectedLeftId;
  String? _selectedRightId;
  final Set<String> _matchedOptionIds = {};
  int _matchedPairsCount = 0;
  int _attemptsUsed = 0;
  int _mismatchShakeCount = 0;
  bool _isCompleted = false;
  PuzzleResult? _lastResult;
  HintSession? _hintSession;
  String? _activeHint;

  @override
  void initState() {
    super.initState();
    _initSession();
  }

  @override
  void didUpdateWidget(covariant WordMatchingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.puzzle?.id != widget.puzzle?.id) {
      _initSession();
    }
  }

  void _initSession() {
    _selectedLeftId = null;
    _selectedRightId = null;
    _matchedOptionIds.clear();
    _matchedPairsCount = 0;
    _attemptsUsed = 0;
    _mismatchShakeCount = 0;
    _isCompleted = false;
    _lastResult = null;
    _activeHint = null;
    final puzzle = widget.puzzle;
    _hintSession = puzzle == null
        ? null
        : widget.hintService.startSession(
            target: puzzle.targetVocabulary,
            puzzleType: puzzle.type,
            difficulty: puzzle.difficulty,
          );
  }

  void _tapLeft(String optionId) {
    if (_isCompleted || _matchedOptionIds.contains(optionId)) {
      return;
    }
    setState(() {
      _selectedLeftId = _selectedLeftId == optionId ? null : optionId;
    });
    _evaluateIfPairSelected();
  }

  void _tapRight(String optionId) {
    if (_isCompleted || _matchedOptionIds.contains(optionId)) {
      return;
    }
    setState(() {
      _selectedRightId = _selectedRightId == optionId ? null : optionId;
    });
    _evaluateIfPairSelected();
  }

  void _evaluateIfPairSelected() {
    final puzzle = widget.puzzle;
    final leftId = _selectedLeftId;
    final rightId = _selectedRightId;
    if (puzzle == null || leftId == null || rightId == null) {
      return;
    }

    final result = widget.validator.validateSubmission(
      puzzle: puzzle,
      leftOptionId: leftId,
      rightOptionId: rightId,
      completedPairIds: _matchedOptionIds,
      attempts: _attemptsUsed + 1,
      hintsUsed: _hintSession?.hintsUsed ?? 0,
      alreadySolved: _isCompleted,
    );

    if (result.isDuplicate) {
      setState(() {
        _selectedLeftId = null;
        _selectedRightId = null;
        _lastResult = result;
      });
      return;
    }

    if (result.isSolved) {
      final totalPairs = puzzle.prompt.options.length;
      final newMatchedCount = _matchedPairsCount + 1;
      final allSolved = newMatchedCount >= totalPairs;

      setState(() {
        _matchedOptionIds.add(leftId);
        _matchedOptionIds.add(rightId);
        _matchedPairsCount = newMatchedCount;
        _selectedLeftId = null;
        _selectedRightId = null;
        _lastResult = result;
        _isCompleted = allSolved;
      });

      widget.onPairMatched?.call(result);
      widget.onAnswerFeedback?.call(result);
      if (allSolved) {
        widget.onCompleted?.call(result);
      }
    } else {
      final nextAttempts = _attemptsUsed + 1;
      final outOfAttempts = nextAttempts >= puzzle.prompt.maxAttempts;

      setState(() {
        _attemptsUsed = nextAttempts;
        _mismatchShakeCount++;
        _selectedLeftId = null;
        _selectedRightId = null;
        _lastResult = result;
        _isCompleted = outOfAttempts;
      });

      widget.onAnswerFeedback?.call(result);
      if (outOfAttempts) {
        widget.onCompleted?.call(result);
      }
    }
  }

  void _requestHint() {
    final session = _hintSession;
    if (session == null || _isCompleted) {
      return;
    }
    final response = session.requestNextHint();
    setState(() {
      if (response.hasHint) {
        _activeHint = response.text;
      }
    });
    widget.onHintRequested?.call(response);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const PuzzleLoadingView();
    }
    if (widget.errorMessage != null) {
      return PuzzleErrorView(
        message: widget.errorMessage!,
        onRetry: widget.onRetry,
      );
    }

    final puzzle = widget.puzzle;
    if (puzzle == null) {
      return PuzzleErrorView(
        message: 'No Word Matching puzzle is available.',
        onRetry: widget.onRetry,
      );
    }

    final prompt = puzzle.prompt;
    final totalPairs = prompt.options.length;
    final maxHints = prompt.maxHints;
    final hintsUsed = _hintSession?.hintsUsed ?? 0;
    final remainingHints = (maxHints - hintsUsed).clamp(0, maxHints);

    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = constraints.maxWidth.clamp(280.0, 720.0);
        final sideBySide = contentWidth >= 360;

        final khmerColumn = _MatchingColumn(
          heading: 'Khmer Words',
          options: prompt.options,
          selectedId: _selectedLeftId,
          matchedIds: _matchedOptionIds,
          enabled: !_isCompleted,
          isKhmer: true,
          onTap: _tapLeft,
        );

        final englishColumn = _MatchingColumn(
          heading: 'Meanings',
          options: prompt.rightOptions,
          selectedId: _selectedRightId,
          matchedIds: _matchedOptionIds,
          enabled: !_isCompleted,
          isKhmer: false,
          onTap: _tapRight,
        );

        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: contentWidth,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PuzzleHeader(
                    title: 'Word Matching',
                    difficulty: prompt.difficulty,
                    instruction: prompt.instruction,
                    onClosePressed: widget.onClose,
                  ),
                  PuzzleProgress(
                    attemptsUsed: _attemptsUsed,
                    maxAttempts: prompt.maxAttempts,
                    completedSteps: _matchedPairsCount,
                    totalSteps: totalPairs,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TactileShakeWrapper(
                          shakeCount: _mismatchShakeCount,
                          child: sideBySide
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: khmerColumn),
                                    const SizedBox(width: 12),
                                    Expanded(child: englishColumn),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    khmerColumn,
                                    const SizedBox(height: 16),
                                    englishColumn,
                                  ],
                                ),
                        ),
                        if (_activeHint != null) ...[
                          const SizedBox(height: 14),
                          PuzzleHintBanner(hintText: _activeHint!),
                        ],
                        if (_lastResult != null) ...[
                          const SizedBox(height: 14),
                          PuzzleFeedbackBanner(
                            message: _lastResult!.feedbackMessage,
                            isCorrect: _lastResult!.isSolved,
                            educationalNote: _lastResult!.educationalNote,
                          ),
                        ],
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: HintButton(
                            remainingHints: remainingHints,
                            maxHints: maxHints,
                            enabled: !_isCompleted,
                            onPressed: _requestHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MatchingColumn extends StatelessWidget {
  const _MatchingColumn({
    required this.heading,
    required this.options,
    required this.selectedId,
    required this.matchedIds,
    required this.enabled,
    required this.isKhmer,
    required this.onTap,
  });

  final String heading;
  final List<PuzzleOption> options;
  final String? selectedId;
  final Set<String> matchedIds;
  final bool enabled;
  final bool isKhmer;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final angkor = AngkorPuzzleTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          heading,
          style: theme.textTheme.labelLarge?.copyWith(
            color: angkor.mutedInk,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        for (final option in options) ...[
          _MatchingTile(
            label: option.label,
            isSelected: option.id == selectedId,
            isMatched: matchedIds.contains(option.id),
            enabled: enabled,
            isKhmer: isKhmer,
            onTap: () => onTap(option.id),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _MatchingTile extends StatelessWidget {
  const _MatchingTile({
    required this.label,
    required this.isSelected,
    required this.isMatched,
    required this.enabled,
    required this.isKhmer,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isMatched;
  final bool enabled;
  final bool isKhmer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final angkor = AngkorPuzzleTheme.of(context);
    final canTap = enabled && !isMatched;
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    final Color backgroundColor;
    final Color borderColor;
    final Color textColor;

    if (isMatched) {
      backgroundColor = angkor.stoneMatched;
      borderColor = angkor.mossAccent;
      textColor = angkor.inkText;
    } else if (isSelected) {
      backgroundColor = angkor.stoneSelected;
      borderColor = angkor.goldAccent;
      textColor = angkor.inkText;
    } else {
      backgroundColor = angkor.stoneTile;
      borderColor = angkor.sandstoneBorder;
      textColor = angkor.inkText;
    }

    final baseStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: textColor,
      fontWeight: (isSelected || isMatched) ? FontWeight.w700 : FontWeight.w600,
    );

    return Semantics(
      button: true,
      selected: isSelected,
      enabled: canTap,
      label: isMatched ? '$label (matched)' : label,
      child: TactilePressScale(
        enabled: canTap,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: canTap ? onTap : null,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 54),
              child: AnimatedContainer(
                duration: disableAnimations
                    ? Duration.zero
                    : const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: borderColor,
                    width: (isSelected || isMatched) ? 2 : 1.5,
                  ),
                  boxShadow: canTap
                      ? [
                          BoxShadow(
                            color: angkor.stoneShadow.withValues(
                              alpha: isSelected ? 0.32 : 0.22,
                            ),
                            offset: Offset(0, isSelected ? 2 : 3),
                            blurRadius: 0,
                          ),
                        ]
                      : null,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: isKhmer
                            ? KhmerTextUtils.khmerTextStyle(baseStyle)
                            : baseStyle,
                      ),
                    ),
                    if (isMatched)
                      Icon(
                        Icons.check_circle,
                        size: 18,
                        color: angkor.mossAccent,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
