import 'dart:math';

import '../models/puzzle.dart';
import '../models/puzzle_enums.dart';
import '../models/vocabulary_item.dart';
import '../services/puzzle_difficulty_service.dart';

/// Generates Word Matching puzzles (shuffled Khmer words paired with English).
class WordMatchingGenerator {
  WordMatchingGenerator({
    PuzzleDifficultyService? difficultyService,
    Random? random,
  }) : _difficultyService =
           difficultyService ?? const PuzzleDifficultyService(),
       _random = random ?? Random();

  final PuzzleDifficultyService _difficultyService;
  final Random _random;

  /// Builds a Word Matching [Puzzle] from [vocabularyPool].
  ///
  /// Ensures unique vocabulary IDs, unique Khmer words, and unambiguous
  /// English meanings within the generated round.
  Puzzle generate({
    required List<VocabularyItem> vocabularyPool,
    required PuzzleDifficulty difficulty,
    int? pairCountOverride,
    Set<String> excludeVocabularyIds = const {},
    String? puzzleId,
  }) {
    final settings = _difficultyService.getSettings(difficulty);
    final pairCount = pairCountOverride ?? settings.matchingPairCount;
    if (pairCount < 2) {
      throw const PuzzleGenerationException(
        'Word Matching requires at least 2 pairs.',
      );
    }

    final cleanPool = sanitizeVocabularyPool(
      vocabularyPool,
      requireEnglish: true,
    );
    final preferred = cleanPool
        .where(
          (item) => settings.allowedVocabularyTiers.contains(item.difficulty),
        )
        .toList(growable: false);
    final freshPreferred = preferred
        .where((item) => !excludeVocabularyIds.contains(item.id))
        .toList(growable: false);
    final freshAny = cleanPool
        .where((item) => !excludeVocabularyIds.contains(item.id))
        .toList(growable: false);
    final sourceOrder = <VocabularyItem>[
      ...(List<VocabularyItem>.of(freshPreferred)..shuffle(_random)),
      ...(List<VocabularyItem>.of(freshAny)..shuffle(_random)),
      ...(List<VocabularyItem>.of(preferred)..shuffle(_random)),
      ...(List<VocabularyItem>.of(cleanPool)..shuffle(_random)),
    ];

    final chosen = <VocabularyItem>[];
    final usedIds = <String>{};
    final usedKhmer = <String>{};
    final usedEnglish = <String>{};

    for (final item in sourceOrder) {
      if (chosen.length >= pairCount) {
        break;
      }
      final englishKey = item.englishMeaning.trim().toLowerCase();
      if (usedIds.contains(item.id) ||
          usedKhmer.contains(item.khmerWord) ||
          usedEnglish.contains(englishKey)) {
        continue;
      }
      usedIds.add(item.id);
      usedKhmer.add(item.khmerWord);
      usedEnglish.add(englishKey);
      chosen.add(item);
    }

    if (chosen.length < pairCount) {
      throw PuzzleGenerationException(
        'Insufficient unambiguous vocabulary for Word Matching: needed $pairCount pairs, found ${chosen.length}.',
      );
    }

    final leftItems = List<VocabularyItem>.of(chosen)..shuffle(_random);
    final rightItems = List<VocabularyItem>.of(chosen)..shuffle(_random);

    final leftOptions = <PuzzleOption>[];
    final rightOptions = <PuzzleOption>[];
    final rightOptionIdByVocabId = <String, String>{};
    final itemsByOptionId = <String, VocabularyItem>{};

    for (var i = 0; i < rightItems.length; i++) {
      final item = rightItems[i];
      final rightId = 'right_$i';
      rightOptions.add(
        PuzzleOption(
          id: rightId,
          label: item.englishMeaning,
          imagePath: item.imagePath,
        ),
      );
      rightOptionIdByVocabId[item.id] = rightId;
      itemsByOptionId[rightId] = item;
    }

    final expectedPairs = <String, String>{};
    for (var i = 0; i < leftItems.length; i++) {
      final item = leftItems[i];
      final leftId = 'left_$i';
      leftOptions.add(PuzzleOption(id: leftId, label: item.khmerWord));
      itemsByOptionId[leftId] = item;
      expectedPairs[leftId] = rightOptionIdByVocabId[item.id]!;
    }

    final resolvedId =
        puzzleId ?? 'word_${chosen.first.id}_${_random.nextInt(100000)}';

    return Puzzle(
      prompt: PuzzlePrompt(
        puzzleId: resolvedId,
        type: PuzzleType.wordMatching,
        difficulty: difficulty,
        instruction: 'Match each Khmer word with its English meaning.',
        options: List<PuzzleOption>.unmodifiable(leftOptions),
        rightOptions: List<PuzzleOption>.unmodifiable(rightOptions),
        maxAttempts: settings.maxAttempts,
        maxHints: settings.maxHints,
      ),
      targetVocabulary: chosen.first,
      answerKey: PuzzleAnswerKey(
        targetVocabularyId: chosen.first.id,
        expectedPairs: Map<String, String>.unmodifiable(expectedPairs),
        itemsByOptionId: Map<String, VocabularyItem>.unmodifiable(
          itemsByOptionId,
        ),
      ),
    );
  }
}
