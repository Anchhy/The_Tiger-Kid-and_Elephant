import 'dart:math';

import '../generators/picture_matching_generator.dart';
import '../generators/syllable_ordering_generator.dart';
import '../generators/word_matching_generator.dart';
import '../models/puzzle.dart';
import '../models/puzzle_enums.dart';
import '../repositories/khmer_puzzle_repository.dart';
import 'puzzle_difficulty_service.dart';

/// Unified puzzle generator facade used by M3 screens and external callers (M5).
class PuzzleGenerator {
  PuzzleGenerator({
    required this.repository,
    PuzzleDifficultyService? difficultyService,
    Random? random,
  }) : _pictureMatchingGenerator = PictureMatchingGenerator(
         difficultyService: difficultyService,
         random: random,
       ),
       _wordMatchingGenerator = WordMatchingGenerator(
         difficultyService: difficultyService,
         random: random,
       ),
       _syllableOrderingGenerator = SyllableOrderingGenerator(
         difficultyService: difficultyService,
         random: random,
       );

  final KhmerPuzzleRepository repository;
  final PictureMatchingGenerator _pictureMatchingGenerator;
  final WordMatchingGenerator _wordMatchingGenerator;
  final SyllableOrderingGenerator _syllableOrderingGenerator;

  /// Generates a [Puzzle] of [type] and [difficulty] from repository data.
  Future<Puzzle> generate({
    required PuzzleType type,
    required PuzzleDifficulty difficulty,
    String? category,
    String? targetVocabularyId,
    Set<String> excludeVocabularyIds = const {},
    bool onlyVerifiedSpelling = false,
    bool onlyVerifiedMeaning = false,
    bool requireVerifiedSyllables = true,
    bool requireImage = true,
  }) async {
    final pool = await repository.queryVocabulary(
      VocabularyQuery(
        category: category,
        onlyVerifiedSpelling: onlyVerifiedSpelling,
        onlyVerifiedMeaning: onlyVerifiedMeaning,
      ),
    );

    return switch (type) {
      PuzzleType.pictureMatching => _pictureMatchingGenerator.generate(
        vocabularyPool: pool,
        difficulty: difficulty,
        targetVocabularyId: targetVocabularyId,
        excludeVocabularyIds: excludeVocabularyIds,
        requireImage: requireImage,
      ),
      PuzzleType.wordMatching => _wordMatchingGenerator.generate(
        vocabularyPool: pool,
        difficulty: difficulty,
        excludeVocabularyIds: excludeVocabularyIds,
      ),
      PuzzleType.syllableOrdering => _syllableOrderingGenerator.generate(
        vocabularyPool: pool,
        difficulty: difficulty,
        targetVocabularyId: targetVocabularyId,
        excludeVocabularyIds: excludeVocabularyIds,
        requireVerifiedSyllables: requireVerifiedSyllables,
      ),
    };
  }
}
