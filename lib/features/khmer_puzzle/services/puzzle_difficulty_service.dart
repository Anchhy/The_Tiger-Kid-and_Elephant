import '../models/puzzle_enums.dart';

/// Configurable difficulty rules controlling puzzle complexity and support.
class DifficultySettings {
  const DifficultySettings({
    required this.optionCount,
    required this.matchingPairCount,
    required this.maxAttempts,
    required this.maxHints,
    required this.allowDirectClue,
    required this.allowedVocabularyTiers,
  });

  /// Number of choices in Picture Matching.
  final int optionCount;

  /// Number of pairs in Word Matching.
  final int matchingPairCount;

  /// Maximum incorrect attempts allowed in a puzzle round.
  final int maxAttempts;

  /// Maximum progressive hints available in a puzzle round.
  final int maxHints;

  /// Whether direct descriptive clues may be shown on the first hint.
  final bool allowDirectClue;

  /// Vocabulary difficulty tiers eligible for selection at this level.
  final Set<PuzzleDifficulty> allowedVocabularyTiers;
}

/// Centralized, configurable difficulty manager for all M3 puzzle modes.
class PuzzleDifficultyService {
  const PuzzleDifficultyService({this.customSettings});

  final Map<PuzzleDifficulty, DifficultySettings>? customSettings;

  static const Map<PuzzleDifficulty, DifficultySettings> defaultSettings = {
    PuzzleDifficulty.easy: DifficultySettings(
      optionCount: 3,
      matchingPairCount: 3,
      maxAttempts: 4,
      maxHints: 3,
      allowDirectClue: true,
      allowedVocabularyTiers: {PuzzleDifficulty.easy},
    ),
    PuzzleDifficulty.medium: DifficultySettings(
      optionCount: 4,
      matchingPairCount: 4,
      maxAttempts: 3,
      maxHints: 2,
      allowDirectClue: true,
      allowedVocabularyTiers: {PuzzleDifficulty.easy, PuzzleDifficulty.medium},
    ),
    PuzzleDifficulty.hard: DifficultySettings(
      optionCount: 5,
      matchingPairCount: 5,
      maxAttempts: 2,
      maxHints: 1,
      allowDirectClue: false,
      allowedVocabularyTiers: {PuzzleDifficulty.medium, PuzzleDifficulty.hard},
    ),
  };

  /// Returns the configured [DifficultySettings] for [difficulty].
  DifficultySettings getSettings(PuzzleDifficulty difficulty) {
    final override = customSettings?[difficulty];
    if (override != null) {
      return override;
    }
    return defaultSettings[difficulty]!;
  }
}
