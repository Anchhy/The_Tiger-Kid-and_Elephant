/// Supported Khmer puzzle modes in the M3 module.
enum PuzzleType { pictureMatching, wordMatching, syllableOrdering }

/// Validation outcome classification across all Khmer puzzle modes.
enum AnswerValidationStatus { correct, incorrect, invalidInput }

/// Difficulty levels shared across all Khmer puzzle modes.
enum PuzzleDifficulty {
  easy,
  medium,
  hard;

  /// Parses a difficulty string from JSON (case-insensitive).
  static PuzzleDifficulty fromString(String value) {
    final normalized = value.trim().toLowerCase();
    return PuzzleDifficulty.values.firstWhere(
      (level) => level.name == normalized,
      orElse: () => throw FormatException('Unknown difficulty level: $value'),
    );
  }
}
