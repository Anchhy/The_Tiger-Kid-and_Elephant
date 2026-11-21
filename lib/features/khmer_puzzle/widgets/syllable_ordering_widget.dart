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

/// Interactive Syllable Ordering puzzle widget using verified Khmer segments.
class SyllableOrderingWidget extends StatefulWidget {
  const SyllableOrderingWidget({
    super.key,
    required this.puzzle,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    this.onClose,
    this.onCompleted,
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
  final ValueChanged<HintResponse>? onHintRequested;
  final PuzzleValidationService validator;
  final PuzzleHintService hintService;

  @override
  State<SyllableOrderingWidget> createState() => _SyllableOrderingWidgetState();
}

class _SyllableOrderingWidgetState extends State<SyllableOrderingWidget> {
  /// Ordered list of tile indices from `puzzle.prompt.syllableChips`.
  /// Tracking indices (not raw text) lets repeated syllable tiles work cleanly.
  final List<int> _selectedTileIndices = [];
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
  void didUpdateWidget(covariant SyllableOrderingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.puzzle?.id != widget.puzzle?.id) {
      _initSession();
    }
  }

  void _initSession() {
    _selectedTileIndices.clear();
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

  void _selectTile(int tileIndex) {
    if (_isCompleted || _selectedTileIndices.contains(tileIndex)) {
      return;
    }
    setState(() {
      _selectedTileIndices.add(tileIndex);
    });
  }

  void _removeSelectedAt(int slotPosition) {
    if (_isCompleted ||
        slotPosition < 0 ||
        slotPosition >= _selectedTileIndices.length) {
      return;
    }
    setState(() {
      _selectedTileIndices.removeAt(slotPosition);
    });
  }

  void _resetSelection() {
    if (_isCompleted || _selectedTileIndices.isEmpty) {
      return;
    }
    setState(() {
      _selectedTileIndices.clear();
      _lastResult = null;
    });
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

  void _submitOrder() {
    final puzzle = widget.puzzle;
    if (puzzle == null || _isCompleted || _selectedTileIndices.isEmpty) {
      return;
    }

    final chips = puzzle.prompt.syllableChips;
    final selectedSyllables = _selectedTileIndices
        .map((index) => chips[index])
        .toList();

    final nextAttempts = _attemptsUsed + 1;
    final result = widget.validator.validateSubmission(
      puzzle: puzzle,
      selectedSyllables: selectedSyllables,
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
      }
    });

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
        message: 'No Syllable Ordering puzzle is available.',
        onRetry: widget.onRetry,
      );
    }

    final prompt = puzzle.prompt;
    final chips = prompt.syllableChips;
    final maxHints = prompt.maxHints;
    final hintsUsed = _hintSession?.hintsUsed ?? 0;
    final remainingHints = (maxHints - hintsUsed).clamp(0, maxHints);
    final angkor = AngkorPuzzleTheme.of(context);
    final isSolved = _isCompleted && (_lastResult?.isSolved ?? false);
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = constraints.maxWidth.clamp(280.0, 680.0);

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
                    title: 'Syllable Ordering',
                    difficulty: prompt.difficulty,
                    instruction: prompt.instruction,
                    onClosePressed: widget.onClose,
                  ),
                  PuzzleProgress(
                    attemptsUsed: _attemptsUsed,
                    maxAttempts: prompt.maxAttempts,
                    completedSteps: _selectedTileIndices.length,
                    totalSteps: chips.length,
                    stepLabel: 'Syllables placed',
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (prompt.promptText.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              color: angkor.stoneTile,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: angkor.sandstoneBorder,
                                width: 1.5,
                              ),
                            ),
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Target meaning',
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(
                                        color: angkor.mutedInk,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  prompt.promptText,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: angkor.inkText,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                        Text(
                          'Your word',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: angkor.inkText,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        TactileShakeWrapper(
                          shakeCount: _wrongShakeCount,
                          child: AnimatedContainer(
                            duration: disableAnimations
                                ? Duration.zero
                                : const Duration(milliseconds: 200),
                            constraints: const BoxConstraints(minHeight: 76),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSolved
                                  ? angkor.stoneMatched.withValues(alpha: 0.45)
                                  : angkor.recessedTray,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSolved
                                    ? angkor.mossAccent
                                    : (_selectedTileIndices.isNotEmpty
                                          ? angkor.goldAccent
                                          : angkor.sandstoneBorder),
                                width:
                                    isSolved || _selectedTileIndices.isNotEmpty
                                    ? 2
                                    : 1.5,
                              ),
                            ),
                            child: _selectedTileIndices.isEmpty
                                ? Center(
                                    child: Text(
                                      'Tap syllables below in order',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: angkor.mutedInk),
                                    ),
                                  )
                                : Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      for (
                                        var pos = 0;
                                        pos < _selectedTileIndices.length;
                                        pos++
                                      )
                                        _SyllableTileButton(
                                          key: ValueKey(
                                            'selected_${_selectedTileIndices[pos]}',
                                          ),
                                          label:
                                              chips[_selectedTileIndices[pos]],
                                          selected: true,
                                          solved: isSolved,
                                          enabled: !_isCompleted,
                                          onTap: () => _removeSelectedAt(pos),
                                        ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Available syllables',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: angkor.inkText,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (var i = 0; i < chips.length; i++)
                              _SyllableTileButton(
                                key: ValueKey('bank_$i'),
                                label: chips[i],
                                selected: false,
                                solved: false,
                                enabled:
                                    !_isCompleted &&
                                    !_selectedTileIndices.contains(i),
                                onTap: () => _selectTile(i),
                              ),
                          ],
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
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.spaceBetween,
                          children: [
                            HintButton(
                              remainingHints: remainingHints,
                              maxHints: maxHints,
                              enabled: !_isCompleted,
                              onPressed: _requestHint,
                            ),
                            OutlinedButton.icon(
                              onPressed:
                                  (!_isCompleted &&
                                      _selectedTileIndices.isNotEmpty)
                                  ? _resetSelection
                                  : null,
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(100, 48),
                                foregroundColor: angkor.inkText,
                                backgroundColor: angkor.stoneTile,
                                side: BorderSide(
                                  color: angkor.sandstoneBorder,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reset'),
                            ),
                            FilledButton(
                              onPressed:
                                  (!_isCompleted &&
                                      _selectedTileIndices.isNotEmpty)
                                  ? _submitOrder
                                  : null,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(132, 48),
                                backgroundColor: angkor.inkText,
                                foregroundColor: angkor.parchmentSurface,
                              ),
                              child: const Text('Check Answer'),
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

class _SyllableTileButton extends StatelessWidget {
  const _SyllableTileButton({
    super.key,
    required this.label,
    required this.selected,
    required this.solved,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool solved;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final angkor = AngkorPuzzleTheme.of(context);
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    final Color backgroundColor;
    final Color borderColor;
    final Color textColor;

    if (solved && selected) {
      backgroundColor = angkor.stoneMatched;
      borderColor = angkor.mossAccent;
      textColor = angkor.inkText;
    } else if (selected) {
      backgroundColor = angkor.stoneSelected;
      borderColor = angkor.goldAccent;
      textColor = angkor.inkText;
    } else if (enabled) {
      backgroundColor = angkor.stoneTile;
      borderColor = angkor.sandstoneBorder;
      textColor = angkor.inkText;
    } else {
      backgroundColor = angkor.recessedTray;
      borderColor = angkor.sandstoneBorder.withValues(alpha: 0.45);
      textColor = angkor.mutedInk.withValues(alpha: 0.45);
    }

    return Semantics(
      button: true,
      enabled: enabled,
      label: selected ? 'Remove syllable $label' : 'Select syllable $label',
      child: TactilePressScale(
        enabled: enabled,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 56, minHeight: 48),
              child: AnimatedContainer(
                duration: disableAnimations
                    ? Duration.zero
                    : const Duration(milliseconds: 160),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: borderColor,
                    width: (selected || solved) ? 2 : 1.5,
                  ),
                  boxShadow: (enabled || selected)
                      ? [
                          BoxShadow(
                            color: angkor.stoneShadow.withValues(
                              alpha: selected ? 0.35 : 0.28,
                            ),
                            offset: const Offset(0, 3),
                            blurRadius: 0,
                          ),
                        ]
                      : null,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                child: Center(
                  widthFactor: 1,
                  child: Text(
                    label,
                    style: KhmerTextUtils.khmerTextStyle(
                      Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w700,
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
