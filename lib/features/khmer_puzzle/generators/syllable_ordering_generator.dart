import 'dart:math';

import '../models/puzzle.dart';
import '../models/puzzle_enums.dart';
import '../models/vocabulary_item.dart';
import '../services/puzzle_difficulty_service.dart';
import '../utils/khmer_text_utils.dart';

/// Generates Syllable Ordering puzzles using explicitly verified syllables only.
class SyllableOrderingGenerator {
  SyllableOrderingGenerator({
    PuzzleDifficultyService? difficultyService,
    Random? random,
  }) : _difficultyService =
           difficultyService ?? const PuzzleDifficultyService(),
       _random = random ?? Random();

  final PuzzleDifficultyService _difficultyService;
  final Random _random;

  /// Builds a Syllable Ordering [Puzzle] from [vocabularyPool].
  ///
  /// Rejects one-syllable words, missing/invalid segmentation, and unverified
  /// syllables when [requireVerifiedSyllables] is `true`.
  Puzzle generate({
    required List<VocabularyItem> vocabularyPool,
    required PuzzleDifficulty difficulty,
    String? targetVocabularyId,
    Set<String> excludeVocabularyIds = const {},
    bool requireVerifiedSyllables = true,
    String? puzzleId,
  }) {
    final settings = _difficultyService.getSettings(difficulty);

    final cleanPool = sanitizeVocabularyPool(vocabularyPool);
    final VocabularyItem target;
    if (targetVocabularyId != null) {
      final found = cleanPool.where((i) => i.id == targetVocabularyId);
      if (found.isEmpty) {
        throw PuzzleGenerationException(
          'Target vocabulary "$targetVocabularyId" was not found.',
        );
      }
      target = found.first;
      _assertEligible(
        target,
        requireVerifiedSyllables: requireVerifiedSyllables,
      );
    } else {
      final eligible = cleanPool
          .where(
            (item) => _isEligible(
              item,
              requireVerifiedSyllables: requireVerifiedSyllables,
            ),
          )
          .toList(growable: false);

      final preferred = eligible
          .where((item) => item.difficulty == difficulty)
          .toList(growable: false);
      final basePool = preferred.isNotEmpty
          ? preferred
          : eligible
                .where(
                  (item) =>
                      settings.allowedVocabularyTiers.contains(item.difficulty),
                )
                .toList(growable: false);
      final nonExcluded = basePool
          .where((item) => !excludeVocabularyIds.contains(item.id))
          .toList(growable: false);
      final allowed = nonExcluded.isNotEmpty ? nonExcluded : basePool;

      if (allowed.isEmpty) {
        throw PuzzleGenerationException(
          'No eligible multi-syllable verified vocabulary found for ${difficulty.name}.',
        );
      }
      target = allowed[_random.nextInt(allowed.length)];
    }

    final shuffledChips = _shuffleDistinct(target.syllables);
    final resolvedId =
        puzzleId ?? 'syl_${target.id}_${_random.nextInt(100000)}';

    return Puzzle(
      prompt: PuzzlePrompt(
        puzzleId: resolvedId,
        type: PuzzleType.syllableOrdering,
        difficulty: difficulty,
        instruction: 'Arrange the Khmer syllables to form the word.',
        promptText: target.englishMeaning,
        promptImagePath: target.imagePath,
        syllableChips: List<String>.unmodifiable(shuffledChips),
        maxAttempts: settings.maxAttempts,
        maxHints: settings.maxHints,
      ),
      targetVocabulary: target,
      answerKey: PuzzleAnswerKey(
        targetVocabularyId: target.id,
        expectedSyllables: target.syllables,
        expectedKhmerWord: target.khmerWord,
      ),
    );
  }

  bool _isEligible(
    VocabularyItem item, {
    required bool requireVerifiedSyllables,
  }) {
    if (requireVerifiedSyllables && !item.verification.areSyllablesVerified) {
      return false;
    }
    if (!item.supportsSyllableOrdering) {
      return false;
    }
    return KhmerTextUtils.hasValidSyllableSegments(
      item.khmerWord,
      item.syllables,
    );
  }

  void _assertEligible(
    VocabularyItem item, {
    required bool requireVerifiedSyllables,
  }) {
    if (requireVerifiedSyllables && !item.verification.areSyllablesVerified) {
      throw PuzzleGenerationException(
        'Vocabulary "${item.id}" does not have verified syllables.',
      );
    }
    if (!item.supportsSyllableOrdering) {
      throw PuzzleGenerationException(
        'Vocabulary "${item.id}" requires at least 2 syllables for Syllable Ordering.',
      );
    }
    if (!KhmerTextUtils.hasValidSyllableSegments(
      item.khmerWord,
      item.syllables,
    )) {
      throw PuzzleGenerationException(
        'Vocabulary "${item.id}" has invalid syllable segmentation.',
      );
    }
  }

  List<String> _shuffleDistinct(List<String> original) {
    final copy = List<String>.of(original);
    if (original.toSet().length <= 1) {
      return copy;
    }

    for (var attempt = 0; attempt < 10; attempt++) {
      copy.shuffle(_random);
      if (!_listsEqual(copy, original)) {
        return copy;
      }
    }

    // Deterministic fallback swap of two non-equal elements so puzzle starts unsolved.
    for (var i = 1; i < copy.length; i++) {
      if (copy[i] != copy[0]) {
        final tmp = copy[0];
        copy[0] = copy[i];
        copy[i] = tmp;
        break;
      }
    }
    return copy;
  }

  bool _listsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}
