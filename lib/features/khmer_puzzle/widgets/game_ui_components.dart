import 'package:flutter/material.dart';

import '../models/vocabulary_item.dart';
import '../utils/khmer_puzzle_assets.dart';
import '../utils/khmer_text_utils.dart';
import 'angkor_puzzle_theme.dart';
import 'game_asset_widgets.dart';
import 'puzzle_tactile_motion.dart';

/// Visual hierarchy tiers for icons in *The Tiger, Kid, and Elephant*.
enum GameIconTier {
  /// Tier 1 (20-28dp): Rounded Material Symbols/Icons inside stone chrome.
  functional,

  /// Tier 2 (28-40dp): Hand-drawn HUD status emblems (hearts, coins, danger).
  hudEmblem,

  /// Tier 3 (32-64dp): Collectible rewards and achievement badges.
  collectible,

  /// Tier 4 (48-128dp): Cambodian temple landmarks and character tokens.
  cultural,
}

/// Semantic tone for [GameNotificationBanner].
enum GameBannerTone { reward, info, caution }

/// Unified 4-tier icon renderer combining Flutter built-in rounded vector
/// icons (Tier 1) and illustrated RGBA sprite assets (Tiers 2-4).
class GameIcon extends StatelessWidget {
  const GameIcon({
    super.key,
    this.icon,
    this.assetPath,
    this.tier = GameIconTier.functional,
    this.size,
    this.color,
    this.semanticLabel,
    this.fallbackIcon = Icons.auto_awesome_rounded,
  }) : assert(
         icon != null || assetPath != null,
         'Either icon or assetPath must be provided.',
       );

  final IconData? icon;
  final String? assetPath;
  final GameIconTier tier;
  final double? size;
  final Color? color;
  final String? semanticLabel;
  final IconData fallbackIcon;

  double get _defaultSize {
    switch (tier) {
      case GameIconTier.functional:
        return 22;
      case GameIconTier.hudEmblem:
        return 30;
      case GameIconTier.collectible:
        return 36;
      case GameIconTier.cultural:
        return 52;
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = AngkorPuzzleTheme.of(context);
    final resolvedSize = size ?? _defaultSize;
    final resolvedColor = color ?? palette.inkText;

    Widget visual;
    if (assetPath != null) {
      visual = Image.asset(
        assetPath!,
        width: resolvedSize,
        height: resolvedSize,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, _, _) => Icon(
          icon ?? fallbackIcon,
          size: resolvedSize * 0.86,
          color: resolvedColor,
        ),
      );
    } else {
      visual = Icon(icon, size: resolvedSize, color: resolvedColor);
    }

    final sized = SizedBox(
      width: resolvedSize,
      height: resolvedSize,
      child: Center(child: visual),
    );

    if (semanticLabel == null || semanticLabel!.trim().isEmpty) {
      return sized;
    }
    return Semantics(label: semanticLabel, image: true, child: sized);
  }
}

/// Carved parchment & sandstone panel container used across puzzle modals,
/// exploration sheets, and dictionary views.
class GamePanel extends StatelessWidget {
  const GamePanel({
    super.key,
    required this.child,
    this.title,
    this.khmerSubtitle,
    this.leadingAssetPath,
    this.leadingIcon,
    this.headerTrailing,
    this.padding = const EdgeInsets.all(16),
    this.elevated = true,
  });

  final Widget child;
  final String? title;
  final String? khmerSubtitle;
  final String? leadingAssetPath;
  final IconData? leadingIcon;
  final Widget? headerTrailing;
  final EdgeInsetsGeometry padding;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final palette = AngkorPuzzleTheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final hasHeader = title != null || khmerSubtitle != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.parchmentSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.sandstoneBorder, width: 1.6),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: palette.stoneShadow,
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasHeader) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (leadingAssetPath != null || leadingIcon != null) ...[
                    GameIcon(
                      assetPath: leadingAssetPath,
                      icon: leadingIcon,
                      tier: leadingAssetPath != null
                          ? GameIconTier.hudEmblem
                          : GameIconTier.functional,
                      color: palette.inkText,
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (title != null)
                          Text(
                            title!,
                            style: textTheme.titleMedium?.copyWith(
                              color: palette.inkText,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        if (khmerSubtitle != null)
                          Text(
                            khmerSubtitle!,
                            style: KhmerTextUtils.khmerTextStyle(
                              textTheme.bodyMedium?.copyWith(
                                color: palette.mutedInk,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (headerTrailing != null) ...[
                    const SizedBox(width: 8),
                    headerTrailing!,
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Divider(
                height: 1,
                thickness: 1,
                color: palette.sandstoneBorder.withValues(alpha: 0.45),
              ),
              const SizedBox(height: 12),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

/// Tactile carved-stone card container with optional tap behavior and selection
/// highlight. Enforces comfortable spacing and non-punitive focus cues.
class GameCard extends StatelessWidget {
  const GameCard({
    super.key,
    required this.child,
    this.onTap,
    this.isSelected = false,
    this.isHighlighted = false,
    this.accentColor,
    this.padding = const EdgeInsets.all(14),
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isHighlighted;
  final Color? accentColor;
  final EdgeInsetsGeometry padding;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final palette = AngkorPuzzleTheme.of(context);
    final activeBorder = accentColor ?? palette.goldAccent;
    final fillColor = isSelected ? palette.stoneSelected : palette.stoneTile;
    final borderColor = (isSelected || isHighlighted)
        ? activeBorder
        : palette.sandstoneBorder;

    final cardBody = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: (isSelected || isHighlighted) ? 2.2 : 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: palette.stoneShadow,
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );

    final interactive = onTap != null
        ? TactilePressScale(enabled: true, child: cardBody)
        : cardBody;

    if (semanticLabel == null || semanticLabel!.trim().isEmpty) {
      return interactive;
    }
    return Semantics(
      button: onTap != null,
      selected: isSelected,
      label: semanticLabel,
      child: interactive,
    );
  }
}

/// Visual progress bar for level milestones, word mastery, or puzzle rounds.
class PuzzleProgressBar extends StatelessWidget {
  const PuzzleProgressBar({
    super.key,
    required this.current,
    required this.total,
    this.label,
    this.khmerLabel,
    this.accentColor,
    this.height = 12,
  });

  final int current;
  final int total;
  final String? label;
  final String? khmerLabel;
  final Color? accentColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final palette = AngkorPuzzleTheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final safeTotal = total <= 0 ? 1 : total;
    final clampedCurrent = current.clamp(0, safeTotal);
    final ratio = clampedCurrent / safeTotal;
    final fillColor = accentColor ?? palette.mossAccent;

    return Semantics(
      label: label ?? 'Progress',
      value: '$clampedCurrent of $safeTotal',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null || khmerLabel != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    khmerLabel ?? label!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: khmerLabel != null
                        ? KhmerTextUtils.khmerTextStyle(
                            textTheme.bodyMedium?.copyWith(
                              color: palette.inkText,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : textTheme.bodyMedium?.copyWith(
                            color: palette.inkText,
                            fontWeight: FontWeight.w700,
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$clampedCurrent/$safeTotal',
                  style: textTheme.labelLarge?.copyWith(
                    color: palette.mutedInk,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          Container(
            height: height,
            decoration: BoxDecoration(
              color: palette.recessedTray,
              borderRadius: BorderRadius.circular(height),
              border: Border.all(color: palette.sandstoneBorder, width: 1.2),
            ),
            clipBehavior: Clip.antiAlias,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: ratio,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    color: fillColor,
                    borderRadius: BorderRadius.circular(height),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact HUD counter badge displaying earned temple stars.
class PuzzleStarCounter extends StatelessWidget {
  const PuzzleStarCounter({
    super.key,
    required this.earnedStars,
    this.maxStars,
  });

  final int earnedStars;
  final int? maxStars;

  @override
  Widget build(BuildContext context) {
    final palette = AngkorPuzzleTheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final label = maxStars != null ? '$earnedStars/$maxStars' : '$earnedStars';

    return Semantics(
      label: maxStars != null
          ? '$earnedStars out of $maxStars stars earned'
          : '$earnedStars stars earned',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: palette.parchmentSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: palette.sandstoneBorder, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GameIcon(
              assetPath: KhmerPuzzleAssets.singleStar,
              icon: Icons.star_rounded,
              tier: GameIconTier.hudEmblem,
              size: 20,
              color: Color(0xFFD4921D),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: textTheme.labelLarge?.copyWith(
                color: palette.inkText,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Carved stone answer or syllable tile with enforced >= 48dp touch target,
/// Khmer line-height safety (`height: 1.5`), and explicit visual state feedback.
class PuzzleAnswerTile extends StatelessWidget {
  const PuzzleAnswerTile({
    super.key,
    required this.label,
    required this.onTap,
    this.isSelected = false,
    this.isMatched = false,
    this.isIncorrect = false,
    this.isDisabled = false,
    this.leading,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isMatched;
  final bool isIncorrect;
  final bool isDisabled;
  final Widget? leading;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final palette = AngkorPuzzleTheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final canTap = !isDisabled && !isMatched && onTap != null;

    Color fill = palette.stoneTile;
    Color border = palette.sandstoneBorder;
    IconData? stateIcon;
    Color? stateIconColor;

    if (isMatched) {
      fill = palette.stoneMatched;
      border = palette.mossAccent;
      stateIcon = Icons.check_circle_rounded;
      stateIconColor = palette.mossAccent;
    } else if (isIncorrect) {
      fill = palette.terracottaAccent.withValues(alpha: 0.14);
      border = palette.terracottaAccent;
      stateIcon = Icons.refresh_rounded;
      stateIconColor = palette.terracottaAccent;
    } else if (isSelected) {
      fill = palette.stoneSelected;
      border = palette.goldAccent;
    } else if (isDisabled) {
      fill = palette.recessedTray;
      border = palette.sandstoneBorder.withValues(alpha: 0.55);
    }

    final textColor = isDisabled ? palette.mutedInk : palette.inkText;
    final textStyle = KhmerTextUtils.containsKhmer(label)
        ? KhmerTextUtils.khmerTextStyle(
            textTheme.titleMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          )
        : textTheme.titleMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w700,
          );

    return Semantics(
      button: canTap,
      enabled: !isDisabled,
      selected: isSelected || isMatched,
      label: semanticLabel ?? label,
      child: TactilePressScale(
        enabled: canTap,
        child: Material(
          color: fill,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: canTap ? onTap : null,
            borderRadius: BorderRadius.circular(14),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: border,
                    width: (isSelected || isMatched || isIncorrect) ? 2.0 : 1.3,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: textStyle,
                      ),
                    ),
                    if (stateIcon != null) ...[
                      const SizedBox(width: 6),
                      Icon(stateIcon, size: 18, color: stateIconColor),
                    ],
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

/// Dictionary / review card presenting a single Khmer vocabulary item with its
/// illustration thumbnail, Khmer script, English translation, and difficulty.
class VocabularyCard extends StatelessWidget {
  const VocabularyCard({
    super.key,
    required this.item,
    this.onTap,
    this.showExample = false,
    this.trailing,
  });

  final VocabularyItem item;
  final VoidCallback? onTap;
  final bool showExample;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = AngkorPuzzleTheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return GameCard(
      onTap: onTap,
      semanticLabel: '${item.khmerWord}, ${item.englishMeaning}',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: palette.parchmentSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: palette.sandstoneBorder),
            ),
            padding: const EdgeInsets.all(4),
            child: Image.asset(
              item.imagePath,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) =>
                  Icon(Icons.image_outlined, color: palette.mutedInk, size: 28),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      item.khmerWord,
                      style: KhmerTextUtils.khmerTextStyle(
                        textTheme.titleMedium?.copyWith(
                          color: palette.inkText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: palette.recessedTray,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        item.difficulty.name.toUpperCase(),
                        style: textTheme.labelSmall?.copyWith(
                          color: palette.mutedInk,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.englishMeaning,
                  style: textTheme.bodyMedium?.copyWith(
                    color: palette.mutedInk,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (showExample && item.exampleKm.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.exampleKm,
                    style: KhmerTextUtils.khmerTextStyle(
                      textTheme.bodySmall?.copyWith(color: palette.inkText),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

/// Interactive temple waypoint pin used on Cambodian exploration maps (Village,
/// Tonle Sap floating market, Angkor Wat gate, Bayon stele).
class WorldMapMarker extends StatelessWidget {
  const WorldMapMarker({
    super.key,
    required this.label,
    this.khmerLabel,
    this.isUnlocked = true,
    this.isCompleted = false,
    this.isActive = false,
    this.starsEarned = 0,
    this.onTap,
  });

  final String label;
  final String? khmerLabel;
  final bool isUnlocked;
  final bool isCompleted;
  final bool isActive;
  final int starsEarned;
  final VoidCallback? onTap;

  String get _markerAsset {
    if (!isUnlocked) {
      return KhmerPuzzleAssets.levelLocked;
    }
    if (isCompleted) {
      return KhmerPuzzleAssets.levelCompleted;
    }
    if (isActive) {
      return KhmerPuzzleAssets.levelActive;
    }
    return KhmerPuzzleAssets.checkpointStele;
  }

  @override
  Widget build(BuildContext context) {
    final palette = AngkorPuzzleTheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final canTap = isUnlocked && onTap != null;

    return Semantics(
      button: canTap,
      enabled: isUnlocked,
      label: '$label ${isUnlocked ? 'unlocked' : 'locked'}',
      child: TactilePressScale(
        enabled: canTap,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: canTap ? onTap : null,
            borderRadius: BorderRadius.circular(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 72, minHeight: 72),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? palette.stoneSelected
                            : palette.parchmentSurface,
                        border: Border.all(
                          color: isActive
                              ? palette.goldAccent
                              : palette.sandstoneBorder,
                          width: isActive ? 2.2 : 1.4,
                        ),
                      ),
                      child: GameIcon(
                        assetPath: _markerAsset,
                        icon: isUnlocked
                            ? Icons.location_on_rounded
                            : Icons.lock_rounded,
                        tier: GameIconTier.cultural,
                        size: 40,
                        color: isUnlocked ? palette.inkText : palette.mutedInk,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isCompleted || starsEarned > 0)
                      PuzzleStarsRow(
                        earnedStars: starsEarned.clamp(0, 3),
                        starSize: 14,
                      ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: textTheme.labelMedium?.copyWith(
                        color: isUnlocked ? palette.inkText : palette.mutedInk,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (khmerLabel != null)
                      Text(
                        khmerLabel!,
                        textAlign: TextAlign.center,
                        style: KhmerTextUtils.khmerTextStyle(
                          textTheme.labelSmall?.copyWith(
                            color: palette.mutedInk,
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

/// Compact exploration prompt shown when approaching an NPC, temple stele,
/// or vocabulary object in the top-down maze world.
class InteractionPrompt extends StatelessWidget {
  const InteractionPrompt({
    super.key,
    required this.title,
    this.khmerPrompt,
    this.assetPath = KhmerPuzzleAssets.checkpointSteleIcon,
    this.icon = Icons.chat_bubble_rounded,
    this.onTap,
  });

  final String title;
  final String? khmerPrompt;
  final String? assetPath;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AngkorPuzzleTheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      button: onTap != null,
      label: title,
      child: TactilePressScale(
        enabled: onTap != null,
        child: Material(
          color: palette.parchmentSurface,
          borderRadius: BorderRadius.circular(24),
          elevation: 2,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: palette.goldAccent, width: 1.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GameIcon(
                      assetPath: assetPath,
                      icon: icon,
                      tier: GameIconTier.hudEmblem,
                      size: 26,
                      color: palette.inkText,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: textTheme.labelLarge?.copyWith(
                              color: palette.inkText,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (khmerPrompt != null)
                            Text(
                              khmerPrompt!,
                              style: KhmerTextUtils.khmerTextStyle(
                                textTheme.bodySmall?.copyWith(
                                  color: palette.mutedInk,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (onTap != null) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 20,
                        color: palette.inkText,
                      ),
                    ],
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

/// Child-friendly storybook confirmation modal dialog for exiting a level,
/// resetting progress, or unlocking temple areas.
class GameConfirmationDialog extends StatelessWidget {
  const GameConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.khmerTitle,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Keep Playing',
    this.isDestructive = false,
    this.onConfirm,
    this.onCancel,
  });

  final String title;
  final String message;
  final String? khmerTitle;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String? khmerTitle,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Keep Playing',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => GameConfirmationDialog(
        title: title,
        khmerTitle: khmerTitle,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        onConfirm: () => Navigator.of(dialogContext).pop(true),
        onCancel: () => Navigator.of(dialogContext).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = AngkorPuzzleTheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: GamePanel(
          title: title,
          khmerSubtitle: khmerTitle,
          leadingIcon: isDestructive
              ? Icons.warning_amber_rounded
              : Icons.help_outline_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                style: KhmerTextUtils.khmerTextStyle(
                  textTheme.bodyMedium?.copyWith(color: palette.inkText),
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed:
                        onCancel ?? () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(88, 48),
                      foregroundColor: palette.inkText,
                      side: BorderSide(color: palette.sandstoneBorder),
                    ),
                    child: Text(cancelLabel),
                  ),
                  ElevatedButton(
                    onPressed:
                        onConfirm ?? () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(88, 48),
                      backgroundColor: isDestructive
                          ? palette.terracottaAccent
                          : palette.goldAccent,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(confirmLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reward, encouragement, or guidance notification banner in the Angkor theme.
class GameNotificationBanner extends StatelessWidget {
  const GameNotificationBanner({
    super.key,
    required this.title,
    required this.message,
    this.khmerBadge,
    this.tone = GameBannerTone.reward,
    this.assetPath,
    this.icon,
    this.onDismiss,
  });

  final String title;
  final String message;
  final String? khmerBadge;
  final GameBannerTone tone;
  final String? assetPath;
  final IconData? icon;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final palette = AngkorPuzzleTheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    final Color borderColor;
    final IconData defaultIcon;
    final String? defaultAsset;
    switch (tone) {
      case GameBannerTone.reward:
        borderColor = palette.goldAccent;
        defaultIcon = Icons.emoji_events_rounded;
        defaultAsset = KhmerPuzzleAssets.angkorCoinIcon;
      case GameBannerTone.info:
        borderColor = palette.mossAccent;
        defaultIcon = Icons.lightbulb_rounded;
        defaultAsset = KhmerPuzzleAssets.hintLanternIcon;
      case GameBannerTone.caution:
        borderColor = palette.terracottaAccent;
        defaultIcon = Icons.info_outline_rounded;
        defaultAsset = KhmerPuzzleAssets.tigerThreatIcon;
    }

    return Semantics(
      liveRegion: true,
      label: '$title: $message',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: palette.parchmentSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.8),
          boxShadow: [
            BoxShadow(
              color: palette.stoneShadow,
              offset: const Offset(0, 3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GameIcon(
              assetPath: assetPath ?? defaultAsset,
              icon: icon ?? defaultIcon,
              tier: GameIconTier.hudEmblem,
              size: 32,
              color: borderColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleSmall?.copyWith(
                          color: palette.inkText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (khmerBadge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: borderColor.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            khmerBadge!,
                            style: KhmerTextUtils.khmerTextStyle(
                              textTheme.labelSmall?.copyWith(
                                color: palette.inkText,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: KhmerTextUtils.khmerTextStyle(
                      textTheme.bodySmall?.copyWith(color: palette.mutedInk),
                    ),
                  ),
                ],
              ),
            ),
            if (onDismiss != null)
              IconButton(
                onPressed: onDismiss,
                tooltip: 'Dismiss notice',
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                icon: Icon(Icons.close_rounded, color: palette.mutedInk),
              ),
          ],
        ),
      ),
    );
  }
}
