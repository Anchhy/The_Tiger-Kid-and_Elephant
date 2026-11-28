import 'package:flutter/material.dart';

import '../models/puzzle.dart';
import '../models/puzzle_result.dart';
import '../services/puzzle_hint_service.dart';
import '../services/puzzle_validation_service.dart';
import '../utils/khmer_text_utils.dart';
import 'hint_button.dart';
import 'angkor_puzzle_theme.dart';
import 'puzzle_feedback_banner.dart';
import 'puzzle_header.dart';
import 'puzzle_progress.dart';
import 'puzzle_state_views.dart';
import 'puzzle_tactile_motion.dart';

/// Interactive Picture Matching puzzle widget backed by M3 engine services.
class PictureMatchingWidget extends StatefulWidget {
  const PictureMatchingWidget({
    super.key,
    required this.puzzle,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    this.onClose,
    this.onCompleted,
    this.onAnswerFeedback,
    this.onOptionSelected,
    this.onHintRequested,
    this.validator = const PuzzleValidationService(),
    this.hintService = const PuzzleHintService(),
    this.imageBuilder,
  });

  final Puzzle? puzzle;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onClose;
  final ValueChanged<PuzzleResult>? onCompleted;
  final ValueChanged<PuzzleResult>? onAnswerFeedback;
  final ValueChanged<PuzzleOption>? onOptionSelected;
  final ValueChanged<HintResponse>? onHintRequested;
  final PuzzleValidationService validator;
  final PuzzleHintService hintService;
  final VocabularyImageBuilder? imageBuilder;

  @override
  State<PictureMatchingWidget> createState() => _PictureMatchingWidgetState();
}

class _PictureMatchingWidgetState extends State<PictureMatchingWidget> {
  String? _selectedOptionId;
  String? _lastSubmittedWrongId;
  int _attemptsUsed = 0;
  int _wrongShakeCount = 0;
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
  void didUpdateWidget(covariant PictureMatchingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.puzzle?.id != widget.puzzle?.id) {
      _initSession();
    }
  }

  void _initSession() {
    _selectedOptionId = null;
    _lastSubmittedWrongId = null;
    _attemptsUsed = 0;
    _wrongShakeCount = 0;
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

  void _selectOption(PuzzleOption option) {
    if (_isCompleted) {
      return;
    }
    setState(() {
      _selectedOptionId = option.id;
    });
    widget.onOptionSelected?.call(option);
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

  void _submitAnswer() {
    final puzzle = widget.puzzle;
    final selectedId = _selectedOptionId;
    if (puzzle == null || selectedId == null || _isCompleted) {
      return;
    }
    if (selectedId == _lastSubmittedWrongId) {
      return;
    }

    final nextAttempts = _attemptsUsed + 1;
    final result = widget.validator.validateSubmission(
      puzzle: puzzle,
      selectedOptionId: selectedId,
      attempts: nextAttempts,
      hintsUsed: _hintSession?.hintsUsed ?? 0,
      alreadySolved: _isCompleted,
    );

    final outOfAttempts =
        !result.isSolved && nextAttempts >= puzzle.prompt.maxAttempts;

    setState(() {
      _attemptsUsed = nextAttempts;
      _lastResult = result;
      if (!result.isSolved) {
        _wrongShakeCount++;
      }
      if (result.isSolved || outOfAttempts) {
        _isCompleted = true;
      } else {
        _lastSubmittedWrongId = selectedId;
      }
    });

    widget.onAnswerFeedback?.call(result);
    if (result.isSolved || outOfAttempts) {
      widget.onCompleted?.call(result);
    }
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
        message: 'No Picture Matching puzzle is available.',
        onRetry: widget.onRetry,
      );
    }

    final prompt = puzzle.prompt;
    final maxHints = prompt.maxHints;
    final hintsUsed = _hintSession?.hintsUsed ?? 0;
    final remainingHints = (maxHints - hintsUsed).clamp(0, maxHints);
    final canSubmit =
        !_isCompleted &&
        _selectedOptionId != null &&
        _selectedOptionId != _lastSubmittedWrongId;

    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = constraints.maxWidth.clamp(280.0, 680.0);
        final columns = contentWidth >= 420 ? 2 : 1;
        const spacing = 10.0;
        final innerWidth = (contentWidth - 32).clamp(220.0, 648.0);
        final cardWidth = columns == 1
            ? innerWidth
            : (innerWidth - spacing) / 2;

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
                    title: 'Picture Matching',
                    difficulty: prompt.difficulty,
                    instruction: prompt.instruction,
                    onClosePressed: widget.onClose,
                  ),
                  PuzzleProgress(
                    attemptsUsed: _attemptsUsed,
                    maxAttempts: prompt.maxAttempts,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        VocabularyImageFrame(
                          imagePath: prompt.promptImagePath,
                          semanticLabel: 'Picture to match with a Khmer word',
                          imageBuilder: widget.imageBuilder,
                        ),
                        const SizedBox(height: 16),
                        TactileShakeWrapper(
                          shakeCount: _wrongShakeCount,
                          child: Wrap(
                            spacing: spacing,
                            runSpacing: spacing,
                            children: prompt.options.map((option) {
                              final isSelected = option.id == _selectedOptionId;
                              final isSolvedHighlight =
                                  _isCompleted &&
                                  (_lastResult?.isSolved ?? false) &&
                                  isSelected;
                              return SizedBox(
                                width: cardWidth,
                                child: _KhmerChoiceCard(
                                  label: option.label,
                                  isSelected: isSelected,
                                  isSolved: isSolvedHighlight,
                                  enabled: !_isCompleted,
                                  onTap: () => _selectOption(option),
                                ),
                              );
                            }).toList(),
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
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.spaceBetween,
                          children: [
                            HintButton(
                              remainingHints: remainingHints,
                              maxHints: maxHints,
                              enabled: !_isCompleted,
                              onPressed: _requestHint,
                            ),
                            FilledButton(
                              onPressed: canSubmit ? _submitAnswer : null,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(140, 48),
                                backgroundColor: AngkorPuzzleTheme.of(
                                  context,
                                ).inkText,
                                foregroundColor: AngkorPuzzleTheme.of(
                                  context,
                                ).parchmentSurface,
                              ),
                              child: const Text('Submit Answer'),
                            ),
                          ],
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

class _KhmerChoiceCard extends StatelessWidget {
  const _KhmerChoiceCard({
    required this.label,
    required this.isSelected,
    required this.isSolved,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isSolved;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final angkor = AngkorPuzzleTheme.of(context);
    final backgroundColor = isSolved
        ? angkor.stoneMatched
        : (isSelected ? angkor.stoneSelected : angkor.stoneTile);
    final borderColor = isSolved
        ? angkor.mossAccent
        : (isSelected ? angkor.goldAccent : angkor.sandstoneBorder);
    final textColor = angkor.inkText;
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return Semantics(
      button: true,
      selected: isSelected,
      enabled: enabled,
      label: label,
      child: TactilePressScale(
        enabled: enabled,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(14),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 58),
              child: AnimatedContainer(
                duration: disableAnimations
                    ? Duration.zero
                    : const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: borderColor,
                    width: (isSelected || isSolved) ? 2 : 1.5,
                  ),
                  boxShadow: enabled
                      ? [
                          BoxShadow(
                            color: angkor.stoneShadow.withValues(
                              alpha: isSelected ? 0.35 : 0.22,
                            ),
                            offset: Offset(0, isSelected ? 2 : 3),
                            blurRadius: 0,
                          ),
                        ]
                      : null,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Center(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: KhmerTextUtils.khmerTextStyle(
                      Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: textColor,
                        fontWeight: (isSelected || isSolved)
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
