import 'package:flutter/material.dart';

import '../models/puzzle_result.dart';
import '../utils/khmer_puzzle_assets.dart';
import '../utils/khmer_text_utils.dart';
import 'angkor_puzzle_theme.dart';
import 'game_asset_widgets.dart';

/// Celebratory M3 puzzle victory view featuring the Kid & Elephant artwork,
/// golden Angkor star rating, earned score badge, and learned Khmer word card.
class PuzzleVictoryView extends StatelessWidget {
  const PuzzleVictoryView({
    super.key,
    required this.result,
    this.khmerWord = '',
    this.englishMeaning = '',
    this.starsEarned,
    this.onReplay,
    this.onContinue,
  });

  final PuzzleResult result;
  final String khmerWord;
  final String englishMeaning;
  final int? starsEarned;
  final VoidCallback? onReplay;
  final VoidCallback? onContinue;

  int get _resolvedStars {
    if (starsEarned != null) {
      return starsEarned!.clamp(1, 3);
    }
    if (!result.isSolved) {
      return 0;
    }
    if (result.attempts <= 1 && result.hintsUsed == 0) {
      return 3;
    }
    if (result.attempts <= 2 && result.hintsUsed <= 1) {
      return 2;
    }
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final angkor = AngkorPuzzleTheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: angkor.parchmentSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: angkor.goldAccent, width: 2),
              boxShadow: [
                BoxShadow(
                  color: angkor.stoneShadow.withValues(alpha: 0.25),
                  offset: const Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PuzzleStarsRow(earnedStars: _resolvedStars, starSize: 38),
                const SizedBox(height: 12),
                SizedBox(
                  height: 148,
                  child: Image.asset(
                    KhmerPuzzleAssets.victoryDuo,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const PuzzleCharacterAvatar(
                          type: PuzzleCharacterType.elephant,
                          size: 120,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'រួចរាល់! Great Job!',
                  textAlign: TextAlign.center,
                  style: KhmerTextUtils.khmerTextStyle(
                    textTheme.headlineSmall?.copyWith(
                      color: angkor.inkText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                PuzzleCoinsBadge(coins: result.score, label: 'Score'),
                if (khmerWord.isNotEmpty || englishMeaning.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: angkor.stoneTile,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: angkor.sandstoneBorder),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        if (khmerWord.isNotEmpty)
                          Text(
                            khmerWord,
                            textAlign: TextAlign.center,
                            style: KhmerTextUtils.khmerTextStyle(
                              textTheme.headlineMedium?.copyWith(
                                color: angkor.inkText,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        if (englishMeaning.isNotEmpty)
                          Text(
                            englishMeaning,
                            textAlign: TextAlign.center,
                            style: textTheme.titleMedium?.copyWith(
                              color: angkor.mutedInk,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                if (result.educationalNote.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    result.educationalNote,
                    textAlign: TextAlign.center,
                    style: KhmerTextUtils.khmerTextStyle(
                      textTheme.bodyMedium?.copyWith(color: angkor.mutedInk),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    if (onReplay != null)
                      AngkorGameButton(
                        label: 'Replay',
                        isPrimary: false,
                        icon: Icons.refresh,
                        onPressed: onReplay,
                      ),
                    if (onContinue != null)
                      AngkorGameButton(
                        label: 'Next Temple',
                        isPrimary: true,
                        icon: Icons.arrow_forward,
                        onPressed: onContinue,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Encouraging, child-friendly recovery view when attempts run out or the
/// tiger blocks the path.
class PuzzleGameOverView extends StatelessWidget {
  const PuzzleGameOverView({
    super.key,
    this.title = 'កុំបោះបង់! Keep Going!',
    this.message =
        'You ran out of tries on this temple stele. Take a breath and try a fresh word!',
    this.onRetry,
    this.onBack,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final angkor = AngkorPuzzleTheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: angkor.parchmentSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: angkor.terracottaAccent, width: 2),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PuzzleCharacterAvatar(
                      type: PuzzleCharacterType.kid,
                      poseIndex: 4,
                      size: 96,
                    ),
                    SizedBox(width: 12),
                    PuzzleCharacterAvatar(
                      type: PuzzleCharacterType.tiger,
                      poseIndex: 0,
                      size: 96,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: KhmerTextUtils.khmerTextStyle(
                    textTheme.headlineSmall?.copyWith(
                      color: angkor.inkText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: KhmerTextUtils.khmerTextStyle(
                    textTheme.bodyMedium?.copyWith(color: angkor.mutedInk),
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    if (onBack != null)
                      AngkorGameButton(
                        label: 'Back',
                        isPrimary: false,
                        icon: Icons.arrow_back,
                        onPressed: onBack,
                      ),
                    if (onRetry != null)
                      AngkorGameButton(
                        label: 'Try Again',
                        isPrimary: true,
                        icon: Icons.refresh,
                        onPressed: onRetry,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
