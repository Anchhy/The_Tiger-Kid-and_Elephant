import 'package:flutter/material.dart';

import '../utils/khmer_text_utils.dart';
import 'angkor_puzzle_theme.dart';

/// Reusable banner displaying answer correctness and educational notes.
class PuzzleFeedbackBanner extends StatelessWidget {
  const PuzzleFeedbackBanner({
    super.key,
    required this.message,
    required this.isCorrect,
    this.educationalNote = '',
  });

  final String message;
  final bool isCorrect;
  final String educationalNote;

  @override
  Widget build(BuildContext context) {
    final angkor = AngkorPuzzleTheme.of(context);
    final accent = isCorrect ? angkor.mossAccent : angkor.terracottaAccent;
    final containerColor = isCorrect
        ? angkor.stoneMatched
        : angkor.terracottaAccent.withValues(alpha: 0.13);
    final foregroundColor = angkor.inkText;

    return Semantics(
      liveRegion: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withValues(alpha: 0.75), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.16),
              offset: const Offset(0, 2),
              blurRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isCorrect ? Icons.check_circle_outline : Icons.info_outline,
              color: accent,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: KhmerTextUtils.khmerTextStyle(
                      Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: foregroundColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (educationalNote.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      educationalNote,
                      style: KhmerTextUtils.khmerTextStyle(
                        Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: angkor.mutedInk),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
