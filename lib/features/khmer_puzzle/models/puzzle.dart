import 'puzzle_enums.dart';
import 'vocabulary_item.dart';

/// Exception thrown when a puzzle cannot be generated from available data.
class PuzzleGenerationException implements Exception {
  const PuzzleGenerationException(this.message);

  final String message;

  @override
  String toString() => 'PuzzleGenerationException: $message';
}

/// Validates a generator input pool by skipping incomplete records and
/// rejecting duplicate vocabulary IDs.
List<VocabularyItem> sanitizeVocabularyPool(
  List<VocabularyItem> pool, {
  bool requireEnglish = false,
}) {
  final seenIds = <String>{};
  final result = <VocabularyItem>[];
  for (final item in pool) {
    if (item.id.trim().isEmpty || item.khmerWord.trim().isEmpty) {
      continue;
    }
    if (requireEnglish && item.englishMeaning.trim().isEmpty) {
      continue;
    }
    if (!seenIds.add(item.id)) {
      throw PuzzleGenerationException(
        'Duplicate vocabulary id "${item.id}" in pool.',
      );
    }
    result.add(item);
  }
  return result;
}

/// UI-safe option item displayed to the player without answer flags.
class PuzzleOption {
  const PuzzleOption({
    required this.id,
    required this.label,
    this.imagePath = '',
  });

  final String id;
  final String label;
  final String imagePath;
}

/// Public puzzle presentation data safe for UI widgets (M4/M5) to render.
///
/// Intentionally omits correct answer keys so UI code cannot leak answers.
class PuzzlePrompt {
  const PuzzlePrompt({
    required this.puzzleId,
    required this.type,
    required this.difficulty,
    required this.instruction,
    this.promptText = '',
    this.promptImagePath = '',
    this.options = const [],
    this.rightOptions = const [],
    this.syllableChips = const [],
    this.maxAttempts = 3,
    this.maxHints = 2,
  });

  final String puzzleId;
  final PuzzleType type;
  final PuzzleDifficulty difficulty;
  final String instruction;
  final String promptText;
  final String promptImagePath;

  /// Answer choices (Picture Matching) or left-column items (Word Matching).
  final List<PuzzleOption> options;

  /// Right-column items for Word Matching.
  final List<PuzzleOption> rightOptions;

  /// Shuffled Khmer syllable segments for Syllable Ordering.
  final List<String> syllableChips;

  final int maxAttempts;
  final int maxHints;
}

/// Internal expected answer data used only by [PuzzleValidationService].
class PuzzleAnswerKey {
  const PuzzleAnswerKey({
    required this.targetVocabularyId,
    this.correctOptionId = '',
    this.expectedPairs = const {},
    this.expectedSyllables = const [],
    this.expectedKhmerWord = '',
    this.itemsByOptionId = const {},
  });

  final String targetVocabularyId;
  final String correctOptionId;

  /// Maps left option ID -> expected right option ID for Word Matching.
  final Map<String, String> expectedPairs;

  final List<String> expectedSyllables;
  final String expectedKhmerWord;

  /// Maps option IDs back to their underlying [VocabularyItem] for feedback.
  final Map<String, VocabularyItem> itemsByOptionId;
}

/// Complete generated puzzle containing public [prompt] and internal [answerKey].
class Puzzle {
  const Puzzle({
    required this.prompt,
    required this.targetVocabulary,
    required this.answerKey,
  });

  final PuzzlePrompt prompt;
  final VocabularyItem targetVocabulary;
  final PuzzleAnswerKey answerKey;

  String get id => prompt.puzzleId;
  PuzzleType get type => prompt.type;
  PuzzleDifficulty get difficulty => prompt.difficulty;
}
