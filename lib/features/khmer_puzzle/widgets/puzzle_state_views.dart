import 'package:flutter/material.dart';

import 'angkor_puzzle_theme.dart';

/// Signature allowing M4 to supply custom vocabulary image rendering.
typedef VocabularyImageBuilder =
    Widget Function(BuildContext context, String imagePath);

/// Shared loading placeholder for puzzle widgets.
class PuzzleLoadingView extends StatelessWidget {
  const PuzzleLoadingView({
    super.key,
    this.message = 'Loading Khmer puzzle...',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final angkor = AngkorPuzzleTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: angkor.goldAccent),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: angkor.mutedInk),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared error placeholder with optional retry action for puzzle widgets.
class PuzzleErrorView extends StatelessWidget {
  const PuzzleErrorView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final angkor = AngkorPuzzleTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 40, color: angkor.terracottaAccent),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(color: angkor.inkText),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(120, 48),
                  backgroundColor: angkor.inkText,
                  foregroundColor: angkor.parchmentSurface,
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Displays a vocabulary asset image inside a carved Angkor parchment frame.
class VocabularyImageFrame extends StatelessWidget {
  const VocabularyImageFrame({
    super.key,
    required this.imagePath,
    this.semanticLabel = 'Vocabulary illustration',
    this.imageBuilder,
  });

  final String imagePath;
  final String semanticLabel;
  final VocabularyImageBuilder? imageBuilder;

  @override
  Widget build(BuildContext context) {
    final angkor = AngkorPuzzleTheme.of(context);

    return Semantics(
      image: true,
      label: semanticLabel,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 158, minHeight: 114),
        width: double.infinity,
        decoration: BoxDecoration(
          color: angkor.recessedTray,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: angkor.sandstoneBorder, width: 2),
          boxShadow: [
            BoxShadow(
              color: angkor.stoneShadow.withValues(alpha: 0.25),
              offset: const Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              radius: 0.9,
              colors: [
                Color.lerp(angkor.parchmentSurface, Colors.white, 0.35)!,
                angkor.parchmentSurface,
                angkor.recessedTray.withValues(alpha: 0.65),
              ],
              stops: const [0.0, 0.72, 1.0],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: angkor.inkText.withValues(alpha: 0.18),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(6),
          clipBehavior: Clip.antiAlias,
          child: imageBuilder != null
              ? imageBuilder!(context, imagePath)
              : _buildDefaultAssetImage(context, angkor),
        ),
      ),
    );
  }

  Widget _buildDefaultAssetImage(
    BuildContext context,
    AngkorPuzzleTheme angkor,
  ) {
    if (imagePath.trim().isEmpty) {
      return _buildFallback(context, angkor);
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          _buildFallback(context, angkor),
    );
  }

  Widget _buildFallback(BuildContext context, AngkorPuzzleTheme angkor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_outlined, size: 40, color: angkor.mutedInk),
            const SizedBox(height: 8),
            Text(
              'Image unavailable',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: angkor.mutedInk),
            ),
          ],
        ),
      ),
    );
  }
}
