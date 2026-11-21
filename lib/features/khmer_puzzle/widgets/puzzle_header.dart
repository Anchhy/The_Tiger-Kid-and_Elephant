import 'package:flutter/material.dart';

import '../models/puzzle_enums.dart';
import 'angkor_puzzle_theme.dart';

/// Reusable top header shared across Khmer puzzle widgets and screens.
class PuzzleHeader extends StatelessWidget {
  const PuzzleHeader({
    super.key,
    required this.title,
    required this.difficulty,
    this.instruction = '',
    this.onHintPressed,
    this.onClosePressed,
  });

  final String title;
  final PuzzleDifficulty difficulty;
  final String instruction;
  final VoidCallback? onHintPressed;
  final VoidCallback? onClosePressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final angkor = AngkorPuzzleTheme.of(context);
    final (difficultyLabel, badgeColor) = switch (difficulty) {
      PuzzleDifficulty.easy => ('Easy', angkor.mossAccent),
      PuzzleDifficulty.medium => ('Medium', angkor.goldAccent),
      PuzzleDifficulty.hard => ('Hard', angkor.terracottaAccent),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: angkor.inkText,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: badgeColor.withValues(alpha: 0.55),
                        ),
                      ),
                      child: Text(
                        difficultyLabel,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: badgeColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (onHintPressed != null)
                IconButton(
                  onPressed: onHintPressed,
                  icon: Icon(Icons.lightbulb_outline, color: angkor.goldAccent),
                  tooltip: 'Hint',
                ),
              if (onClosePressed != null)
                IconButton(
                  onPressed: onClosePressed,
                  icon: Icon(Icons.close, color: angkor.mutedInk),
                  tooltip: 'Close',
                ),
            ],
          ),
          if (instruction.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              instruction,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: angkor.mutedInk,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
