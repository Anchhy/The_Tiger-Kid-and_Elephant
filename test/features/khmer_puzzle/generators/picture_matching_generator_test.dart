import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tiger_kid_elephant/features/khmer_puzzle/khmer_puzzle.dart';

// Unverified test fixture for generator mechanics only.
List<VocabularyItem> _fixturePool() => const [
  VocabularyItem(
    id: 'animals_tiger',
    khmerWord: 'ខ្លា',
    syllables: ['ខ្លា'],
    englishMeaning: 'Tiger',
    difficulty: PuzzleDifficulty.easy,
    imagePath: 'assets/images/vocabulary/tiger.png',
  ),
  VocabularyItem(
    id: 'animals_elephant',
    khmerWord: 'ដំរី',
    syllables: ['ដំ', 'រី'],
    englishMeaning: 'Elephant',
    difficulty: PuzzleDifficulty.easy,
    imagePath: 'assets/images/vocabulary/elephant.png',
  ),
  VocabularyItem(
    id: 'food_water',
    khmerWord: 'ទឹក',
    syllables: ['ទឹក'],
    englishMeaning: 'Water',
    difficulty: PuzzleDifficulty.easy,
    imagePath: 'assets/images/vocabulary/water.png',
  ),
  VocabularyItem(
    id: 'nature_flower',
    khmerWord: 'ផ្កា',
    syllables: ['ផ្កា'],
    englishMeaning: 'Flower',
    difficulty: PuzzleDifficulty.easy,
    imagePath: 'assets/images/vocabulary/flower.png',
  ),
];

void main() {
  group('PictureMatchingGenerator', () {
    test('generates unique options with exactly one correct answer', () {
      final generator = PictureMatchingGenerator(random: Random(7));
      const validator = PuzzleValidationService();

      final puzzle = generator.generate(
        vocabularyPool: _fixturePool(),
        difficulty: PuzzleDifficulty.easy,
      );

      expect(puzzle.type, PuzzleType.pictureMatching);
      expect(puzzle.prompt.options.length, 3);
      expect(puzzle.prompt.promptImagePath, isNotEmpty);

      // Unique option IDs and labels.
      expect(
        puzzle.prompt.options.map((o) => o.id).toSet().length,
        puzzle.prompt.options.length,
      );
      expect(
        puzzle.prompt.options.map((o) => o.label).toSet().length,
        puzzle.prompt.options.length,
      );

      // Exactly one option validates as solved.
      final solvedCount = puzzle.prompt.options
          .where(
            (opt) => validator
                .validateSubmission(puzzle: puzzle, selectedOptionId: opt.id)
                .isSolved,
          )
          .length;
      expect(solvedCount, 1);
    });

    test(
      'throws PuzzleGenerationException when vocabulary is insufficient',
      () {
        final generator = PictureMatchingGenerator(random: Random(1));

        expect(
          () => generator.generate(
            vocabularyPool: _fixturePool().take(2).toList(),
            difficulty: PuzzleDifficulty.easy,
          ),
          throwsA(isA<PuzzleGenerationException>()),
        );
      },
    );
  });
}
