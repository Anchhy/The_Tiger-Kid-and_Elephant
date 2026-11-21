import 'package:flutter/material.dart';

import 'angkor_puzzle_theme.dart';

/// Reusable progress and remaining-attempts indicator for M3 puzzles.
class PuzzleProgress extends StatelessWidget {
  const PuzzleProgress({
    super.key,
    required this.attemptsUsed,
    required this.maxAttempts,
    this.completedSteps,
    this.totalSteps,
    this.stepLabel = 'Pairs matched',
  });

  final int attemptsUsed;
  final int maxAttempts;
  final int? completedSteps;
  final int? totalSteps;
  final String stepLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final angkor = AngkorPuzzleTheme.of(context);
    final remaining = (maxAttempts - attemptsUsed).clamp(0, maxAttempts);
    final hasSteps =
        completedSteps != null && totalSteps != null && totalSteps! > 0;
    final progressValue = hasSteps
        ? (completedSteps! / totalSteps!).clamp(0.0, 1.0)
        : (maxAttempts > 0 ? (remaining / maxAttempts).clamp(0.0, 1.0) : 0.0);
    final lowAttempts = remaining <= 1;
    final fillColor = hasSteps
        ? angkor.mossAccent
        : (lowAttempts ? angkor.terracottaAccent : angkor.goldAccent);

    return Semantics(
      label: hasSteps
          ? '$stepLabel: $completedSteps of $totalSteps. Attempts left: $remaining of $maxAttempts.'
          : 'Attempts left: $remaining of $maxAttempts.',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 12,
              runSpacing: 4,
              children: [
                if (hasSteps)
                  Text(
                    '$stepLabel: $completedSteps/$totalSteps',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: angkor.inkText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                Text(
                  'Attempts left: $remaining/$maxAttempts',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: lowAttempts ? FontWeight.w700 : FontWeight.w500,
                    color: lowAttempts
                        ? angkor.terracottaAccent
                        : angkor.mutedInk,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: angkor.recessedTray,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: angkor.sandstoneBorder.withValues(alpha: 0.7),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progressValue,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    color: fillColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
