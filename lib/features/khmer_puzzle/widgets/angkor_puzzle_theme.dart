import 'package:flutter/material.dart';

/// Optional Angkor sandstone & palm-leaf parchment design tokens for M3.
///
/// M4 can override every token cleanly via:
/// `ThemeData(extensions: [AngkorPuzzleTheme(...)])`.
/// When omitted, M3 resolves warm storybook defaults calibrated to the
/// Angkor maze, Kid, Tiger, and Elephant art sheets.
@immutable
class AngkorPuzzleTheme extends ThemeExtension<AngkorPuzzleTheme> {
  const AngkorPuzzleTheme({
    required this.parchmentSurface,
    required this.recessedTray,
    required this.stoneTile,
    required this.stoneSelected,
    required this.stoneMatched,
    required this.inkText,
    required this.mutedInk,
    required this.sandstoneBorder,
    required this.stoneShadow,
    required this.goldAccent,
    required this.mossAccent,
    required this.terracottaAccent,
  });

  /// Default warm palm-leaf parchment and carved Angkor sandstone palette.
  const AngkorPuzzleTheme.light()
    : parchmentSurface = const Color(0xFFFBF4E4),
      recessedTray = const Color(0xFFEDE0C8),
      stoneTile = const Color(0xFFF5EAD4),
      stoneSelected = const Color(0xFFF9E09E),
      stoneMatched = const Color(0xFFDDE9D2),
      inkText = const Color(0xFF4A3525),
      mutedInk = const Color(0xFF705642),
      sandstoneBorder = const Color(0xFFC5AC82),
      stoneShadow = const Color(0xFF9E8259),
      goldAccent = const Color(0xFFD4921D),
      mossAccent = const Color(0xFF4D7741),
      terracottaAccent = const Color(0xFFB94A2F);

  /// Deep temple twilight palette when a host app requests dark brightness.
  const AngkorPuzzleTheme.dark()
    : parchmentSurface = const Color(0xFF231D17),
      recessedTray = const Color(0xFF1A1510),
      stoneTile = const Color(0xFF2F261E),
      stoneSelected = const Color(0xFF4A3A1B),
      stoneMatched = const Color(0xFF263824),
      inkText = const Color(0xFFF5EAD4),
      mutedInk = const Color(0xFFC7B69E),
      sandstoneBorder = const Color(0xFF6B583E),
      stoneShadow = const Color(0xFF120E0B),
      goldAccent = const Color(0xFFE7B24B),
      mossAccent = const Color(0xFF79A86A),
      terracottaAccent = const Color(0xFFE07558);

  final Color parchmentSurface;
  final Color recessedTray;
  final Color stoneTile;
  final Color stoneSelected;
  final Color stoneMatched;
  final Color inkText;
  final Color mutedInk;
  final Color sandstoneBorder;
  final Color stoneShadow;
  final Color goldAccent;
  final Color mossAccent;
  final Color terracottaAccent;

  /// Resolves [AngkorPuzzleTheme] from the nearest [Theme], falling back to
  /// calibrated Angkor defaults for light or dark brightness.
  static AngkorPuzzleTheme of(BuildContext context) {
    final theme = Theme.of(context);
    final extension = theme.extension<AngkorPuzzleTheme>();
    if (extension != null) {
      return extension;
    }
    return theme.brightness == Brightness.dark
        ? const AngkorPuzzleTheme.dark()
        : const AngkorPuzzleTheme.light();
  }

  /// Convenience [ThemeData] preset showcasing the Angkor Storybook styling
  /// used in `PuzzlePreviewScreen` and available for M4 to adopt or override.
  static ThemeData storybookThemeData({
    Brightness brightness = Brightness.light,
  }) {
    final tokens = brightness == Brightness.dark
        ? const AngkorPuzzleTheme.dark()
        : const AngkorPuzzleTheme.light();

    final colorScheme = ColorScheme.fromSeed(
      seedColor: tokens.goldAccent,
      brightness: brightness,
      surface: tokens.parchmentSurface,
      primary: tokens.goldAccent,
      secondary: tokens.mossAccent,
      error: tokens.terracottaAccent,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: tokens.parchmentSurface,
      cardTheme: CardThemeData(
        color: tokens.stoneTile,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: tokens.sandstoneBorder),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: tokens.inkText,
          foregroundColor: tokens.parchmentSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: tokens.inkText,
          side: BorderSide(color: tokens.sandstoneBorder, width: 1.5),
          backgroundColor: tokens.stoneTile,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      extensions: [tokens],
    );
  }

  @override
  AngkorPuzzleTheme copyWith({
    Color? parchmentSurface,
    Color? recessedTray,
    Color? stoneTile,
    Color? stoneSelected,
    Color? stoneMatched,
    Color? inkText,
    Color? mutedInk,
    Color? sandstoneBorder,
    Color? stoneShadow,
    Color? goldAccent,
    Color? mossAccent,
    Color? terracottaAccent,
  }) {
    return AngkorPuzzleTheme(
      parchmentSurface: parchmentSurface ?? this.parchmentSurface,
      recessedTray: recessedTray ?? this.recessedTray,
      stoneTile: stoneTile ?? this.stoneTile,
      stoneSelected: stoneSelected ?? this.stoneSelected,
      stoneMatched: stoneMatched ?? this.stoneMatched,
      inkText: inkText ?? this.inkText,
      mutedInk: mutedInk ?? this.mutedInk,
      sandstoneBorder: sandstoneBorder ?? this.sandstoneBorder,
      stoneShadow: stoneShadow ?? this.stoneShadow,
      goldAccent: goldAccent ?? this.goldAccent,
      mossAccent: mossAccent ?? this.mossAccent,
      terracottaAccent: terracottaAccent ?? this.terracottaAccent,
    );
  }

  @override
  AngkorPuzzleTheme lerp(
    covariant ThemeExtension<AngkorPuzzleTheme>? other,
    double t,
  ) {
    if (other is! AngkorPuzzleTheme) {
      return this;
    }
    return AngkorPuzzleTheme(
      parchmentSurface: Color.lerp(
        parchmentSurface,
        other.parchmentSurface,
        t,
      )!,
      recessedTray: Color.lerp(recessedTray, other.recessedTray, t)!,
      stoneTile: Color.lerp(stoneTile, other.stoneTile, t)!,
      stoneSelected: Color.lerp(stoneSelected, other.stoneSelected, t)!,
      stoneMatched: Color.lerp(stoneMatched, other.stoneMatched, t)!,
      inkText: Color.lerp(inkText, other.inkText, t)!,
      mutedInk: Color.lerp(mutedInk, other.mutedInk, t)!,
      sandstoneBorder: Color.lerp(sandstoneBorder, other.sandstoneBorder, t)!,
      stoneShadow: Color.lerp(stoneShadow, other.stoneShadow, t)!,
      goldAccent: Color.lerp(goldAccent, other.goldAccent, t)!,
      mossAccent: Color.lerp(mossAccent, other.mossAccent, t)!,
      terracottaAccent: Color.lerp(
        terracottaAccent,
        other.terracottaAccent,
        t,
      )!,
    );
  }
}
