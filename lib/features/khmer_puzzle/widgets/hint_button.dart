import 'package:flutter/material.dart';

import '../utils/khmer_puzzle_assets.dart';
import '../utils/khmer_text_utils.dart';
import 'angkor_puzzle_theme.dart';

/// Reusable button for requesting progressive educational hints.
class HintButton extends StatelessWidget {
  const HintButton({
    super.key,
    required this.remainingHints,
    required this.maxHints,
    required this.onPressed,
    this.enabled = true,
  });

  final int remainingHints;
  final int maxHints;
  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final canTap = enabled && remainingHints > 0 && onPressed != null;
    final angkor = AngkorPuzzleTheme.of(context);

    return Semantics(
      button: true,
      enabled: canTap,
      label: 'Hint, $remainingHints of $maxHints remaining',
      child: OutlinedButton.icon(
        onPressed: canTap ? onPressed : null,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          backgroundColor: angkor.stoneTile,
          foregroundColor: angkor.inkText,
          side: BorderSide(color: angkor.sandstoneBorder, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Opacity(
          opacity: canTap ? 1.0 : 0.45,
          child: Image.asset(
            KhmerPuzzleAssets.hintLanternIcon,
            width: 22,
            height: 22,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.lightbulb_outline,
              color: canTap ? angkor.goldAccent : angkor.mutedInk,
            ),
          ),
        ),
        label: Text('Hint ($remainingHints/$maxHints)'),
      ),
    );
  }
}

/// Reusable card displaying active hint text with Khmer-safe line height.
class PuzzleHintBanner extends StatelessWidget {
  const PuzzleHintBanner({super.key, required this.hintText});

  final String hintText;

  @override
  Widget build(BuildContext context) {
    final angkor = AngkorPuzzleTheme.of(context);
    return Semantics(
      liveRegion: true,
      child: Container(
        decoration: BoxDecoration(
          color: angkor.stoneSelected.withValues(alpha: 0.48),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: angkor.goldAccent.withValues(alpha: 0.7),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              KhmerPuzzleAssets.hintLanternIcon,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.lightbulb, color: angkor.goldAccent),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hintText,
                style: KhmerTextUtils.khmerTextStyle(
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: angkor.inkText,
                    fontWeight: FontWeight.w500,
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
