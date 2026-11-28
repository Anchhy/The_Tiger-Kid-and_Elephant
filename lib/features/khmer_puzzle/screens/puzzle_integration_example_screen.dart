import 'dart:convert';

import 'package:flutter/material.dart';

import '../integration/puzzle_completion_event.dart';
import '../integration/puzzle_integration_adapter.dart';
import '../integration/puzzle_request.dart';
import '../models/puzzle_enums.dart';
import '../models/puzzle_result.dart';
import '../repositories/khmer_puzzle_repository.dart';
import '../services/puzzle_hint_service.dart';
import '../widgets/angkor_puzzle_theme.dart';
import '../widgets/game_ui_components.dart';
import 'khmer_puzzle_screen.dart';

/// Checkpoint status tracked by the example host simulating M2/M5 maze state.
enum CheckpointGateState { locked, unlocked, retryNeeded }

/// Runnable Week 2 M3 integration showcase demonstrating how M1/M2/M5 trigger
/// [KhmerPuzzleScreen] from JSON [PuzzleRequest] payloads, observe real-time
/// answer/hint feedback, and handle emitted [PuzzleCompletionEvent] outcomes.
class PuzzleIntegrationExampleScreen extends StatefulWidget {
  const PuzzleIntegrationExampleScreen({
    super.key,
    this.repository,
    this.adapter,
    this.scoreCalculator,
    this.useDialogMode = false,
  });

  final KhmerPuzzleRepository? repository;
  final PuzzleIntegrationAdapter? adapter;
  final PuzzleScoreCalculator? scoreCalculator;

  /// When `true`, launches puzzles using [KhmerPuzzleScreen.showAsDialog] (ideal
  /// for Flame `GameScreen` overlays); otherwise pushes a full page route.
  final bool useDialogMode;

  @override
  State<PuzzleIntegrationExampleScreen> createState() =>
      _PuzzleIntegrationExampleScreenState();
}

class _PuzzleIntegrationExampleScreenState
    extends State<PuzzleIntegrationExampleScreen> {
  static final List<Map<String, dynamic>> _sampleCheckpointConfigs = [
    {
      'levelId': 'level_01_village_picture',
      'puzzleType': 'picture_matching',
      'difficulty': 'easy',
      'category': 'animals',
      'configuration': {
        'targetVocabularyId': 'tiger',
        'requireVerifiedSyllables': true,
        'requireImage': false,
      },
    },
    {
      'levelId': 'level_02_tonle_sap_words',
      'puzzleType': 'word_matching',
      'difficulty': 'easy',
      'category': 'food',
      'configuration': {
        'requireVerifiedSyllables': true,
        'requireImage': false,
      },
    },
    {
      'levelId': 'level_03_angkor_syllables',
      'puzzleType': 'syllable_ordering',
      'difficulty': 'easy',
      'category': 'animals',
      'configuration': {
        'targetVocabularyId': 'elephant',
        'requireVerifiedSyllables': true,
        'requireImage': false,
      },
    },
  ];

  static const Map<String, String> _checkpointTitles = {
    'level_01_village_picture': 'Village Gate (Picture)',
    'level_02_tonle_sap_words': 'Tonle Sap Dock (Words)',
    'level_03_angkor_syllables': 'Angkor Stele (Syllables)',
  };

  final Map<String, CheckpointGateState> _gateStates = {
    'level_01_village_picture': CheckpointGateState.locked,
    'level_02_tonle_sap_words': CheckpointGateState.locked,
    'level_03_angkor_syllables': CheckpointGateState.locked,
  };

  final List<String> _feedbackLog = [];

  PuzzleRequest? _activeRequest;
  PuzzleCompletionEvent? _lastCompletionEvent;
  PuzzleIntegrationError? _lastError;
  late bool _useDialogMode;

  @override
  void initState() {
    super.initState();
    _useDialogMode = widget.useDialogMode;
  }

  Future<void> _launchCheckpointConfig(Map<String, dynamic> configJson) async {
    final PuzzleRequest request;
    try {
      request = PuzzleRequest.fromJson(configJson);
      request.validate();
    } on PuzzleRequestException catch (e) {
      setState(() {
        _lastError = PuzzleIntegrationError(code: e.code, message: e.message);
        _feedbackLog.insert(0, '[${e.code}] ${e.message}');
      });
      return;
    }

    setState(() {
      _activeRequest = request;
      _lastError = null;
      _feedbackLog.insert(
        0,
        'Requested ${request.levelId} (${request.puzzleType.name})',
      );
    });

    if (_useDialogMode) {
      await KhmerPuzzleScreen.showAsDialog(
        context,
        request: request,
        repository: widget.repository,
        adapter: widget.adapter,
        scoreCalculator: widget.scoreCalculator,
        onAnswerFeedback: _onAnswerFeedback,
        onHintRequested: _onHintRequested,
        onLoadError: _onLoadError,
        onCompletionEvent: _onCompletionEvent,
      );
    } else {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => Theme(
            data: AngkorPuzzleTheme.storybookThemeData(),
            child: KhmerPuzzleScreen.fromRequest(
              request: request,
              repository: widget.repository,
              adapter: widget.adapter,
              scoreCalculator: widget.scoreCalculator,
              onAnswerFeedback: _onAnswerFeedback,
              onHintRequested: _onHintRequested,
              onLoadError: _onLoadError,
              onCompletionEvent: _onCompletionEvent,
            ),
          ),
        ),
      );
    }
  }

  Future<void> _triggerInvalidRequest() async {
    final invalid = const PuzzleRequest(
      levelId: '',
      puzzleType: PuzzleType.pictureMatching,
      difficulty: PuzzleDifficulty.easy,
    );
    setState(() {
      _activeRequest = invalid;
      _lastError = null;
    });

    final outcome =
        await (widget.adapter ??
                PuzzleIntegrationAdapter(
                  repository: widget.repository ?? KhmerPuzzleRepository(),
                ))
            .loadPuzzle(invalid);

    if (!mounted) {
      return;
    }
    if (!outcome.isSuccess && outcome.error != null) {
      _onLoadError(outcome.error!);
    }
  }

  void _onHintRequested(HintResponse hint) {
    if (!mounted || !hint.hasHint) {
      return;
    }
    setState(() {
      _feedbackLog.insert(
        0,
        'Hint (${hint.hintsUsed}/${hint.maxHints}): ${hint.text}',
      );
    });
  }

  void _onAnswerFeedback(PuzzleResult result) {
    if (!mounted) {
      return;
    }
    setState(() {
      final tag = result.isSolved ? 'Correct' : 'Try Again';
      _feedbackLog.insert(
        0,
        '[$tag • Attempt ${result.attempts}] ${result.feedbackMessage}',
      );
    });
  }

  void _onLoadError(PuzzleIntegrationError error) {
    if (!mounted) {
      return;
    }
    setState(() {
      _lastError = error;
      _feedbackLog.insert(0, '[${error.code}] ${error.message}');
    });
  }

  void _onCompletionEvent(PuzzleCompletionEvent event) {
    if (!mounted) {
      return;
    }
    setState(() {
      _lastCompletionEvent = event;
      _gateStates[event.levelId] = event.isCorrect
          ? CheckpointGateState.unlocked
          : CheckpointGateState.retryNeeded;
      _feedbackLog.insert(
        0,
        'Completed ${event.levelId}: isCorrect=${event.isCorrect}, score=${event.score ?? 0}',
      );
    });
  }

  String _prettyJson(Map<String, dynamic> map) =>
      const JsonEncoder.withIndent('  ').convert(map);

  @override
  Widget build(BuildContext context) {
    final baseTheme = AngkorPuzzleTheme.storybookThemeData();
    final encoder = _prettyJson;

    return Theme(
      data: baseTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('M3 Integration Example'),
          backgroundColor: AngkorPuzzleTheme.light().stoneTile,
          foregroundColor: AngkorPuzzleTheme.light().inkText,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilterChip(
                label: Text(_useDialogMode ? 'Dialog Mode' : 'Route Mode'),
                selected: _useDialogMode,
                onSelected: (value) => setState(() => _useDialogMode = value),
              ),
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscapeWide = constraints.maxWidth >= 680;
            final checkpointsPanel = GamePanel(
              title: 'Flame Maze Checkpoints (M1/M2)',
              khmerSubtitle: 'គំរូការតភ្ជាប់ M3 • Request Triggers',
              leadingIcon: Icons.temple_hindu_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final config in _sampleCheckpointConfigs)
                        _CheckpointTriggerCard(
                          levelId: config['levelId'] as String,
                          title:
                              _checkpointTitles[config['levelId']] ??
                              config['levelId'] as String,
                          subtitle:
                              '${config['puzzleType']} • ${config['difficulty']}',
                          gateState:
                              _gateStates[config['levelId']] ??
                              CheckpointGateState.locked,
                          onTap: () => _launchCheckpointConfig(config),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: _triggerInvalidRequest,
                      icon: const Icon(Icons.error_outline_rounded),
                      label: const Text('Test Invalid Request'),
                    ),
                  ),
                ],
              ),
            );

            final telemetryPanel = GamePanel(
              title: 'Live Request, Feedback & Event Output',
              khmerSubtitle: 'លទ្ធផល និង មតិត្រឡប់',
              leadingIcon: Icons.sync_alt_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_lastError != null) ...[
                    GameNotificationBanner(
                      title: 'Structured Error (${_lastError!.code})',
                      message: _lastError!.message,
                      tone: GameBannerTone.caution,
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (_lastCompletionEvent != null) ...[
                    GameNotificationBanner(
                      title: _lastCompletionEvent!.isCorrect
                          ? 'Checkpoint Unlocked!'
                          : 'Checkpoint Retry Needed',
                      khmerBadge: _lastCompletionEvent!.levelId,
                      message:
                          'score=${_lastCompletionEvent!.score ?? 'null'} • attempts=${_lastCompletionEvent!.attempts} • hints=${_lastCompletionEvent!.hintsUsed}',
                      tone: _lastCompletionEvent!.isCorrect
                          ? GameBannerTone.reward
                          : GameBannerTone.caution,
                    ),
                    const SizedBox(height: 10),
                    SelectableText(
                      encoder(_lastCompletionEvent!.toJson()),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (_activeRequest != null) ...[
                    Text(
                      'Last PuzzleRequest JSON',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      encoder(_activeRequest!.toJson()),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                    ),
                    const SizedBox(height: 10),
                  ],
                  Text(
                    'Answer & Hint Feedback Feed',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (_feedbackLog.isEmpty)
                    const Text(
                      'Select any checkpoint to launch a Khmer puzzle and inspect events.',
                    )
                  else
                    for (final entry in _feedbackLog.take(6))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('• $entry'),
                      ),
                ],
              ),
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: isLandscapeWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: checkpointsPanel),
                        const SizedBox(width: 14),
                        Expanded(flex: 5, child: telemetryPanel),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        checkpointsPanel,
                        const SizedBox(height: 14),
                        telemetryPanel,
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}

class _CheckpointTriggerCard extends StatelessWidget {
  const _CheckpointTriggerCard({
    required this.levelId,
    required this.title,
    required this.subtitle,
    required this.gateState,
    required this.onTap,
  });

  final String levelId;
  final String title;
  final String subtitle;
  final CheckpointGateState gateState;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AngkorPuzzleTheme.of(context);
    final (String badgeText, Color badgeColor) = switch (gateState) {
      CheckpointGateState.locked => ('Locked', palette.mutedInk),
      CheckpointGateState.unlocked => ('Unlocked', palette.mossAccent),
      CheckpointGateState.retryNeeded => (
        'Retry Needed',
        palette.terracottaAccent,
      ),
    };

    return GameCard(
      onTap: onTap,
      isHighlighted: gateState == CheckpointGateState.unlocked,
      accentColor: badgeColor,
      semanticLabel: '$title ($badgeText)',
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 180, maxWidth: 260),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: palette.inkText,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badgeText,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: badgeColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: palette.mutedInk),
            ),
          ],
        ),
      ),
    );
  }
}
