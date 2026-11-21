import 'package:flutter/material.dart';

import '../utils/khmer_puzzle_assets.dart';
import '../utils/khmer_text_utils.dart';
import 'angkor_puzzle_theme.dart';
import 'puzzle_tactile_motion.dart';

/// Playable story character types for M3/M4 reusable avatar widgets.
enum PuzzleCharacterType { kid, tiger, elephant }

/// Displays the atmospheric Angkor temple-jungle backdrop behind puzzle cards
/// with a warm parchment scrim so Khmer script remains crisp and legible.
class PuzzleGameBackground extends StatelessWidget {
  const PuzzleGameBackground({
    super.key,
    required this.child,
    this.backgroundAsset = KhmerPuzzleAssets.angkorMazeBackground,
    this.scrimOpacity = 0.84,
  });

  final Widget child;
  final String backgroundAsset;
  final double scrimOpacity;

  @override
  Widget build(BuildContext context) {
    final angkor = AngkorPuzzleTheme.of(context);
    final clampedScrim = scrimOpacity.clamp(0.0, 1.0);

    return ColoredBox(
      color: angkor.parchmentSurface,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: Image.asset(
                backgroundAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    ColoredBox(color: angkor.parchmentSurface),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: ColoredBox(
                color: angkor.parchmentSurface.withValues(alpha: clampedScrim),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Renders an extracted Kid, Tiger, or Elephant transparent PNG pose sprite.
class PuzzleCharacterAvatar extends StatelessWidget {
  const PuzzleCharacterAvatar({
    super.key,
    required this.type,
    this.poseIndex = 0,
    this.size = 84,
    this.isHighlighted = false,
    this.semanticLabel,
  });

  final PuzzleCharacterType type;
  final int poseIndex;
  final double size;
  final bool isHighlighted;
  final String? semanticLabel;

  String get _assetPath {
    final frames = switch (type) {
      PuzzleCharacterType.kid => const [
        KhmerPuzzleAssets.kidHero,
        KhmerPuzzleAssets.kidIdleMap,
        KhmerPuzzleAssets.kidWalkMap,
        KhmerPuzzleAssets.kidRun,
        KhmerPuzzleAssets.kidStartled,
      ],
      PuzzleCharacterType.tiger => [
        KhmerPuzzleAssets.tigerHero,
        ...KhmerPuzzleAssets.tigerWalkFrames,
      ],
      PuzzleCharacterType.elephant => [
        KhmerPuzzleAssets.elephantHero,
        ...KhmerPuzzleAssets.elephantWalkFrames,
      ],
    };
    final safeIndex = poseIndex.clamp(0, frames.length - 1);
    return frames[safeIndex];
  }

  String get _defaultLabel => switch (type) {
    PuzzleCharacterType.kid => 'Cambodian kid explorer character',
    PuzzleCharacterType.tiger => 'Tiger character',
    PuzzleCharacterType.elephant => 'Kind elephant character',
  };

  @override
  Widget build(BuildContext context) {
    final angkor = AngkorPuzzleTheme.of(context);
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return Semantics(
      image: true,
      label: semanticLabel ?? _defaultLabel,
      child: AnimatedScale(
        scale: isHighlighted ? 1.06 : 1.0,
        duration: disableAnimations
            ? Duration.zero
            : const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: SizedBox(
          width: size,
          height: size,
          child: Image.asset(
            _assetPath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => DecoratedBox(
              decoration: BoxDecoration(
                color: angkor.stoneTile,
                shape: BoxShape.circle,
                border: Border.all(color: angkor.sandstoneBorder),
              ),
              child: Icon(Icons.pets, size: size * 0.45, color: angkor.inkText),
            ),
          ),
        ),
      ),
    );
  }
}

/// Large kid-friendly carved Angkor sandstone action button (`>= 52dp` height).
class AngkorGameButton extends StatelessWidget {
  const AngkorGameButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isPrimary = true,
    this.icon,
    this.assetIconPath,
    this.minWidth = 140,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final IconData? icon;
  final String? assetIconPath;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    final angkor = AngkorPuzzleTheme.of(context);
    final enabled = onPressed != null;

    final backgroundColor = !enabled
        ? angkor.recessedTray
        : (isPrimary ? angkor.goldAccent : angkor.stoneTile);
    final foregroundColor = !enabled ? angkor.mutedInk : angkor.inkText;
    final borderColor = !enabled
        ? angkor.sandstoneBorder.withValues(alpha: 0.45)
        : (isPrimary ? angkor.inkText : angkor.sandstoneBorder);

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: TactilePressScale(
        enabled: enabled,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: minWidth, minHeight: 52),
              child: Ink(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor, width: 2),
                  boxShadow: enabled
                      ? [
                          BoxShadow(
                            color: angkor.stoneShadow.withValues(alpha: 0.35),
                            offset: const Offset(0, 3),
                            blurRadius: 0,
                          ),
                        ]
                      : null,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (assetIconPath != null) ...[
                      Image.asset(
                        assetIconPath!,
                        width: 22,
                        height: 22,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          icon ?? Icons.auto_awesome,
                          size: 20,
                          color: foregroundColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ] else if (icon != null) ...[
                      Icon(icon, size: 20, color: foregroundColor),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: KhmerTextUtils.khmerTextStyle(
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: foregroundColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
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

/// Circular stone navigation/utility button using extracted button artwork
/// with a `>= 48dp` touch target and Material icon fallback.
class AngkorIconButton extends StatelessWidget {
  const AngkorIconButton({
    super.key,
    required this.tooltip,
    required this.onPressed,
    this.assetPath,
    this.fallbackIcon = Icons.circle_outlined,
    this.size = 52,
  });

  final String tooltip;
  final VoidCallback? onPressed;
  final String? assetPath;
  final IconData fallbackIcon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final angkor = AngkorPuzzleTheme.of(context);
    final enabled = onPressed != null;
    final clampedSize = size.clamp(48.0, 96.0);

    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        enabled: enabled,
        label: tooltip,
        child: TactilePressScale(
          enabled: enabled,
          child: Opacity(
            opacity: enabled ? 1.0 : 0.45,
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onPressed,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: clampedSize,
                  height: clampedSize,
                  child: assetPath != null
                      ? Image.asset(
                          assetPath!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              _fallbackCircle(angkor),
                        )
                      : _fallbackCircle(angkor),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fallbackCircle(AngkorPuzzleTheme angkor) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: angkor.stoneTile,
        shape: BoxShape.circle,
        border: Border.all(color: angkor.sandstoneBorder, width: 2),
      ),
      child: Center(child: Icon(fallbackIcon, color: angkor.inkText)),
    );
  }
}

/// Kid-friendly hearts / remaining-lives indicator for maze & puzzle HUDs.
class PuzzleHeartsBar extends StatelessWidget {
  const PuzzleHeartsBar({
    super.key,
    required this.remainingLives,
    required this.maxLives,
  });

  final int remainingLives;
  final int maxLives;

  @override
  Widget build(BuildContext context) {
    final angkor = AngkorPuzzleTheme.of(context);
    final total = maxLives.clamp(1, 8);
    final active = remainingLives.clamp(0, total);

    return Semantics(
      label: '$active of $total lives remaining',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: angkor.stoneTile,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: angkor.sandstoneBorder, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < total; i++) ...[
              Icon(
                i < active ? Icons.favorite : Icons.favorite_border,
                size: 20,
                color: i < active
                    ? angkor.terracottaAccent
                    : angkor.sandstoneBorder,
              ),
              if (i < total - 1) const SizedBox(width: 3),
            ],
          ],
        ),
      ),
    );
  }
}

/// HUD pill displaying gold score/coins with the extracted Angkor coin emblem.
class PuzzleCoinsBadge extends StatelessWidget {
  const PuzzleCoinsBadge({super.key, required this.coins, this.label});

  final int coins;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final angkor = AngkorPuzzleTheme.of(context);
    final displayText = label == null ? '$coins' : '$label: $coins';

    return Semantics(
      label: '$coins Angkor coins',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: angkor.stoneTile,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: angkor.goldAccent, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              KhmerPuzzleAssets.angkorCoinIcon,
              width: 22,
              height: 22,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.monetization_on,
                size: 20,
                color: angkor.goldAccent,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              displayText,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: angkor.inkText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders 1..[maxStars] golden Angkor reward stars with subtle entrance scale.
class PuzzleStarsRow extends StatelessWidget {
  const PuzzleStarsRow({
    super.key,
    required this.earnedStars,
    this.maxStars = 3,
    this.starSize = 32,
  });

  final int earnedStars;
  final int maxStars;
  final double starSize;

  @override
  Widget build(BuildContext context) {
    final angkor = AngkorPuzzleTheme.of(context);
    final total = maxStars.clamp(1, 5);
    final earned = earnedStars.clamp(0, total);
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return Semantics(
      label: '$earned of $total stars earned',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < total; i++) ...[
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.85, end: 1.0),
              duration: disableAnimations
                  ? Duration.zero
                  : Duration(milliseconds: 180 + (i * 60)),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Opacity(
                opacity: i < earned ? 1.0 : 0.28,
                child: Image.asset(
                  KhmerPuzzleAssets.singleStar,
                  width: starSize,
                  height: starSize,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    i < earned ? Icons.star : Icons.star_border,
                    size: starSize,
                    color: i < earned ? angkor.goldAccent : angkor.mutedInk,
                  ),
                ),
              ),
            ),
            if (i < total - 1) SizedBox(width: starSize * 0.2),
          ],
        ],
      ),
    );
  }
}

/// Reusable carved sandstone card for displaying learner vocabulary badges.
class AchievementBadgeCard extends StatelessWidget {
  const AchievementBadgeCard({
    super.key,
    required this.title,
    required this.description,
    this.khmerTitle = '',
    this.unlocked = true,
    this.iconAssetPath = KhmerPuzzleAssets.checkpointSteleIcon,
  });

  final String title;
  final String description;
  final String khmerTitle;
  final bool unlocked;
  final String iconAssetPath;

  @override
  Widget build(BuildContext context) {
    final angkor = AngkorPuzzleTheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: unlocked ? angkor.stoneSelected : angkor.recessedTray,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: unlocked ? angkor.goldAccent : angkor.sandstoneBorder,
          width: unlocked ? 2 : 1.5,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Opacity(
            opacity: unlocked ? 1.0 : 0.4,
            child: Image.asset(
              iconAssetPath,
              width: 44,
              height: 44,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                unlocked ? Icons.emoji_events : Icons.lock_outline,
                size: 36,
                color: unlocked ? angkor.goldAccent : angkor.mutedInk,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (khmerTitle.isNotEmpty)
                  Text(
                    khmerTitle,
                    style: KhmerTextUtils.khmerTextStyle(
                      textTheme.titleSmall?.copyWith(
                        color: angkor.inkText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    color: angkor.inkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: textTheme.bodySmall?.copyWith(color: angkor.mutedInk),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Interactive temple-level card displaying extracted Angkor level sprites.
class PuzzleLevelCard extends StatelessWidget {
  const PuzzleLevelCard({
    super.key,
    required this.levelNumber,
    required this.title,
    this.khmerSubtitle = '',
    this.starsEarned = 0,
    this.isUnlocked = true,
    this.isCurrent = false,
    this.onTap,
  });

  final int levelNumber;
  final String title;
  final String khmerSubtitle;
  final int starsEarned;
  final bool isUnlocked;
  final bool isCurrent;
  final VoidCallback? onTap;

  String get _levelSprite {
    if (!isUnlocked) {
      return KhmerPuzzleAssets.levelLocked;
    }
    if (isCurrent) {
      return KhmerPuzzleAssets.levelActive;
    }
    return KhmerPuzzleAssets.levelCompleted;
  }

  @override
  Widget build(BuildContext context) {
    final angkor = AngkorPuzzleTheme.of(context);
    final canTap = isUnlocked && onTap != null;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      enabled: canTap,
      label:
          'Level $levelNumber: $title, ${isUnlocked ? 'unlocked' : 'locked'}',
      child: TactilePressScale(
        enabled: canTap,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: canTap ? onTap : null,
            borderRadius: BorderRadius.circular(14),
            child: Ink(
              decoration: BoxDecoration(
                color: isCurrent
                    ? angkor.stoneSelected
                    : (isUnlocked ? angkor.stoneTile : angkor.recessedTray),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isCurrent ? angkor.goldAccent : angkor.sandstoneBorder,
                  width: isCurrent ? 2 : 1.5,
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: Image.asset(
                      _levelSprite,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          CircleAvatar(
                            backgroundColor: angkor.goldAccent.withValues(
                              alpha: 0.2,
                            ),
                            child: Text(
                              '$levelNumber',
                              style: textTheme.titleMedium?.copyWith(
                                color: angkor.inkText,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Level $levelNumber • $title',
                          style: textTheme.titleSmall?.copyWith(
                            color: isUnlocked
                                ? angkor.inkText
                                : angkor.mutedInk,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (khmerSubtitle.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            khmerSubtitle,
                            style: KhmerTextUtils.khmerTextStyle(
                              textTheme.bodyMedium?.copyWith(
                                color: angkor.mutedInk,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        if (isUnlocked)
                          PuzzleStarsRow(earnedStars: starsEarned, starSize: 20)
                        else
                          Text(
                            'Complete previous level to unlock',
                            style: textTheme.bodySmall?.copyWith(
                              color: angkor.mutedInk,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
