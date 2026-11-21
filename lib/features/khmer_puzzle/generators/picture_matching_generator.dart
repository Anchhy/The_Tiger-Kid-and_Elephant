import 'dart:math';

import '../models/puzzle.dart';
import '../models/puzzle_enums.dart';
import '../models/vocabulary_item.dart';
import '../services/puzzle_difficulty_service.dart';

/// Generates Picture Matching puzzles (one picture prompt, multiple Khmer words).
class PictureMatchingGenerator {
  PictureMatchingGenerator({
    PuzzleDifficultyService? difficultyService,
    Random? random,
  }) : _difficultyService =
           difficultyService ?? const PuzzleDifficultyService(),
       _random = random ?? Random();

  final PuzzleDifficultyService _difficultyService;
  final Random _random;

  /// Builds a Picture Matching [Puzzle] from [vocabularyPool].
  ///
  /// Throws [PuzzleGenerationException] if [vocabularyPool] does not contain
  /// enough distinct valid items for the requested option count.
  Puzzle generate({
    required List<VocabularyItem> vocabularyPool,
    required PuzzleDifficulty difficulty,
    int? optionCountOverride,
    String? targetVocabularyId,
    Set<String> excludeVocabularyIds = const {},
    bool requireImage = true,
    String? puzzleId,
  }) {
    final settings = _difficultyService.getSettings(difficulty);
    final optionCount = optionCountOverride ?? settings.optionCount;
    if (optionCount < 2) {
      throw const PuzzleGenerationException(
        'Picture Matching requires at least 2 options.',
      );
    }

    final candidates = sanitizeVocabularyPool(
      vocabularyPool,
    ).where((item) => !requireImage || item.hasImage).toList(growable: false);

    final VocabularyItem target;
    if (targetVocabularyId != null) {
      target = candidates.firstWhere(
        (item) => item.id == targetVocabularyId,
        orElse: () => throw PuzzleGenerationException(
          'Target vocabulary "$targetVocabularyId" is unavailable for Picture Matching.',
        ),
      );
    } else {
      final preferred = candidates
          .where((item) => item.difficulty == difficulty)
          .toList(growable: false);
      final basePool = preferred.isNotEmpty
          ? preferred
          : candidates
                .where(
                  (item) =>
                      settings.allowedVocabularyTiers.contains(item.difficulty),
                )
                .toList(growable: false);
      final nonExcluded = basePool
          .where((item) => !excludeVocabularyIds.contains(item.id))
          .toList(growable: false);
      final targetPool = nonExcluded.isNotEmpty ? nonExcluded : basePool;
      if (targetPool.isEmpty) {
        throw PuzzleGenerationException(
          'No valid Picture Matching target vocabulary found for ${difficulty.name}.',
        );
      }
      target = targetPool[_random.nextInt(targetPool.length)];
    }

    final distractors = <VocabularyItem>[];
    final usedIds = <String>{target.id};
    final usedKhmer = <String>{target.khmerWord};
    final usedImages = <String>{if (requireImage) target.imagePath.trim()};

    final shuffledPool = List<VocabularyItem>.of(candidates)..shuffle(_random);
    final prioritizedPool = target.category.trim().isNotEmpty
        ? <VocabularyItem>[
            ...shuffledPool.where(
              (item) => item.category.trim() == target.category.trim(),
            ),
            ...shuffledPool.where(
              (item) => item.category.trim() != target.category.trim(),
            ),
          ]
        : shuffledPool;

    for (final item in prioritizedPool) {
      if (distractors.length >= optionCount - 1) {
        break;
      }
      final trimmedImage = item.imagePath.trim();
      if (requireImage && usedImages.contains(trimmedImage)) {
        continue;
      }
      if (usedIds.add(item.id) && usedKhmer.add(item.khmerWord)) {
        if (requireImage) {
          usedImages.add(trimmedImage);
        }
        distractors.add(item);
      }
    }

    if (distractors.length < optionCount - 1) {
      throw PuzzleGenerationException(
        'Insufficient distinct choices for Picture Matching: needed $optionCount, found ${distractors.length + 1}.',
      );
    }

    final selectedItems = <VocabularyItem>[target, ...distractors]
      ..shuffle(_random);
    final options = <PuzzleOption>[];
    final itemsByOptionId = <String, VocabularyItem>{};
    var correctOptionId = '';

    for (var i = 0; i < selectedItems.length; i++) {
      final item = selectedItems[i];
      final optionId = 'opt_$i';
      options.add(
        PuzzleOption(
          id: optionId,
          label: item.khmerWord,
          imagePath: item.imagePath,
        ),
      );
      itemsByOptionId[optionId] = item;
      if (item.id == target.id) {
        correctOptionId = optionId;
      }
    }

    final resolvedId =
        puzzleId ?? 'pic_${target.id}_${_random.nextInt(100000)}';

    return Puzzle(
      prompt: PuzzlePrompt(
        puzzleId: resolvedId,
        type: PuzzleType.pictureMatching,
        difficulty: difficulty,
        instruction: 'Choose the Khmer word that matches this picture.',
        promptImagePath: target.imagePath,
        options: List<PuzzleOption>.unmodifiable(options),
        maxAttempts: settings.maxAttempts,
        maxHints: settings.maxHints,
      ),
      targetVocabulary: target,
      answerKey: PuzzleAnswerKey(
        targetVocabularyId: target.id,
        correctOptionId: correctOptionId,
        itemsByOptionId: Map<String, VocabularyItem>.unmodifiable(
          itemsByOptionId,
        ),
      ),
    );
  }
}
