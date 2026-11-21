import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tiger_kid_elephant/features/khmer_puzzle/khmer_puzzle.dart';

void main() {
  // Unverified test fixture for generator mechanics only.
  const pool = [
    VocabularyItem(
      id: 'tiger',
      khmerWord: 'ខ្លា',
      syllables: ['ខ្លា'],
      englishMeaning: 'Tiger',
      difficulty: PuzzleDifficulty.easy,
    ),
    VocabularyItem(
      id: 'elephant',
      khmerWord: 'ដំរី',
      syllables: ['ដំ', 'រី'],
      englishMeaning: 'Elephant',
      difficulty: PuzzleDifficulty.easy,
    ),
    VocabularyItem(
      id: 'water',
      khmerWord: 'ទឹក',
      syllables: ['ទឹក'],
      englishMeaning: 'Water',
      difficulty: PuzzleDifficulty.easy,
    ),
    // Ambiguous duplicate English translation should not break pair uniqueness.
    VocabularyItem(
      id: 'water_dup',
      khmerWord: 'ជល',
      syllables: ['ជល'],
      englishMeaning: 'water',
      difficulty: PuzzleDifficulty.easy,
    ),
  ];

  group('WordMatchingGenerator', () {
    test(
      'creates unique pair IDs and preserves matching despite shuffling',
      () {
        final generator = WordMatchingGenerator(random: Random(42));
        const validator = PuzzleValidationService();

        final puzzle = generator.generate(
          vocabularyPool: pool,
          difficulty: PuzzleDifficulty.easy,
        );

        expect(puzzle.type, PuzzleType.wordMatching);
        expect(puzzle.prompt.options.length, 3);
        expect(puzzle.prompt.rightOptions.length, 3);

        // Unique left and right option IDs and labels.
        expect(puzzle.prompt.options.map((o) => o.id).toSet().length, 3);
        expect(puzzle.prompt.rightOptions.map((o) => o.id).toSet().length, 3);
        expect(
          puzzle.prompt.rightOptions
              .map((o) => o.label.toLowerCase())
              .toSet()
              .length,
          3,
        );

        // Every left option maps to exactly one matching right option.
        for (final left in puzzle.prompt.options) {
          final matchingRights = puzzle.prompt.rightOptions.where(
            (right) => validator
                .validateSubmission(
                  puzzle: puzzle,
                  leftOptionId: left.id,
                  rightOptionId: right.id,
                )
                .isSolved,
          );
          expect(matchingRights.length, 1);
        }
      },
    );
  });
}
