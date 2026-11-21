import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tiger_kid_elephant/features/khmer_puzzle/khmer_puzzle.dart';

// Unverified test fixtures used strictly for QA invariant and edge-case checks.
List<VocabularyItem> _qaPool() => const [
  VocabularyItem(
    id: 'easy_1',
    khmerWord: 'ខ្លា',
    syllables: ['ខ្លា'],
    englishMeaning: 'Tiger',
    difficulty: PuzzleDifficulty.easy,
    imagePath: 'assets/images/vocabulary/tiger.png',
    category: 'animals',
    verification: VocabularyVerification(
      spelling: VerificationStatus.verified,
      meaning: VerificationStatus.verified,
      syllables: VerificationStatus.verified,
    ),
  ),
  VocabularyItem(
    id: 'easy_2',
    khmerWord: 'ដំរី',
    syllables: ['ដំ', 'រី'],
    englishMeaning: 'Elephant',
    difficulty: PuzzleDifficulty.easy,
    imagePath: 'assets/images/vocabulary/elephant.png',
    category: 'animals',
    verification: VocabularyVerification(
      spelling: VerificationStatus.verified,
      meaning: VerificationStatus.verified,
      syllables: VerificationStatus.verified,
    ),
  ),
  VocabularyItem(
    id: 'easy_3',
    khmerWord: 'ទឹក',
    syllables: ['ទឹក'],
    englishMeaning: 'Water',
    difficulty: PuzzleDifficulty.easy,
    imagePath: 'assets/images/vocabulary/water.png',
    category: 'food',
    verification: VocabularyVerification(
      spelling: VerificationStatus.verified,
      meaning: VerificationStatus.verified,
      syllables: VerificationStatus.verified,
    ),
  ),
  VocabularyItem(
    id: 'med_1',
    khmerWord: 'សៀវភៅ',
    syllables: ['សៀវ', 'ភៅ'],
    englishMeaning: 'Book',
    difficulty: PuzzleDifficulty.medium,
    imagePath: 'assets/images/vocabulary/book.png',
    category: 'education',
    verification: VocabularyVerification(
      spelling: VerificationStatus.verified,
      meaning: VerificationStatus.verified,
      syllables: VerificationStatus.verified,
    ),
  ),
  VocabularyItem(
    id: 'med_2',
    khmerWord: 'ផ្លែឈើ',
    syllables: ['ផ្លែ', 'ឈើ'],
    englishMeaning: 'Fruit',
    difficulty: PuzzleDifficulty.medium,
    imagePath: 'assets/images/vocabulary/fruit.png',
    category: 'food',
    verification: VocabularyVerification(
      spelling: VerificationStatus.verified,
      meaning: VerificationStatus.verified,
      syllables: VerificationStatus.verified,
    ),
  ),
  VocabularyItem(
    id: 'hard_1',
    khmerWord: 'សាលារៀន',
    syllables: ['សា', 'លា', 'រៀន'],
    englishMeaning: 'School',
    difficulty: PuzzleDifficulty.hard,
    imagePath: 'assets/images/vocabulary/school.png',
    category: 'education',
    verification: VocabularyVerification(
      spelling: VerificationStatus.verified,
      meaning: VerificationStatus.verified,
      syllables: VerificationStatus.verified,
    ),
  ),
  VocabularyItem(
    id: 'hard_2',
    khmerWord: 'មេអំបៅ',
    syllables: ['មេ', 'អំ', 'បៅ'],
    englishMeaning: 'Butterfly',
    difficulty: PuzzleDifficulty.hard,
    imagePath: 'assets/images/vocabulary/butterfly.png',
    category: 'animals',
    verification: VocabularyVerification(
      spelling: VerificationStatus.verified,
      meaning: VerificationStatus.verified,
      syllables: VerificationStatus.verified,
    ),
  ),
  VocabularyItem(
    id: 'hard_3',
    khmerWord: 'កសិករ',
    syllables: ['ក', 'សិ', 'ករ'],
    englishMeaning: 'Farmer',
    difficulty: PuzzleDifficulty.hard,
    imagePath: 'assets/images/vocabulary/farmer.png',
    category: 'daily_life',
    verification: VocabularyVerification(
      spelling: VerificationStatus.verified,
      meaning: VerificationStatus.verified,
      syllables: VerificationStatus.verified,
    ),
  ),
];

void main() {
  group('Phase 6 Regression Tests', () {
    test('Word Matching hint does not leak 1-syllable Khmer word', () {
      const hintService = PuzzleHintService();
      const tiger = VocabularyItem(
        id: 'tiger',
        khmerWord: 'ខ្លា',
        syllables: ['ខ្លា'],
        englishMeaning: 'Tiger',
        difficulty: PuzzleDifficulty.easy,
        category: 'animals',
      );

      final hint0 = hintService.getHint(
        target: tiger,
        puzzleType: PuzzleType.wordMatching,
        difficulty: PuzzleDifficulty.easy,
        hintIndex: 0,
      );
      final hint1 = hintService.getHint(
        target: tiger,
        puzzleType: PuzzleType.wordMatching,
        difficulty: PuzzleDifficulty.easy,
        hintIndex: 1,
      );
      final hint2 = hintService.getHint(
        target: tiger,
        puzzleType: PuzzleType.wordMatching,
        difficulty: PuzzleDifficulty.easy,
        hintIndex: 2,
      );

      expect(hint0, isNot(contains('ខ្លា')));
      expect(hint1, isNot(contains('ខ្លា')));
      expect(hint2, isNot(contains('ខ្លា')));
    });

    test('Syllable Ordering hints do not reveal full 2-syllable word', () {
      const hintService = PuzzleHintService();
      const elephant = VocabularyItem(
        id: 'elephant',
        khmerWord: 'ដំរី',
        syllables: ['ដំ', 'រី'],
        englishMeaning: 'Elephant',
        difficulty: PuzzleDifficulty.easy,
      );

      final session = hintService.startSession(
        target: elephant,
        puzzleType: PuzzleType.syllableOrdering,
        difficulty: PuzzleDifficulty.easy,
      );

      final hints = [
        session.requestNextHint().text,
        session.requestNextHint().text,
        session.requestNextHint().text,
      ];

      expect(hints.join(' '), isNot(contains('ដំរី')));
      // Must not reveal the second/last syllable on a 2-syllable word.
      expect(hints[2], isNot(contains('រី')));
    });

    test(
      'validateSubmission rejects repeated submissions when alreadySolved',
      () {
        const validator = PuzzleValidationService();
        final picPuzzle = PictureMatchingGenerator(random: Random(1)).generate(
          vocabularyPool: _qaPool(),
          difficulty: PuzzleDifficulty.easy,
        );
        final wordPuzzle = WordMatchingGenerator(random: Random(1)).generate(
          vocabularyPool: _qaPool(),
          difficulty: PuzzleDifficulty.easy,
        );
        final sylPuzzle = SyllableOrderingGenerator(random: Random(1)).generate(
          vocabularyPool: _qaPool(),
          difficulty: PuzzleDifficulty.easy,
        );

        final picRepeat = validator.validateSubmission(
          puzzle: picPuzzle,
          selectedOptionId: picPuzzle.answerKey.correctOptionId,
          alreadySolved: true,
        );
        final wordRepeat = validator.validateSubmission(
          puzzle: wordPuzzle,
          leftOptionId: wordPuzzle.prompt.options.first.id,
          rightOptionId: wordPuzzle
              .answerKey
              .expectedPairs[wordPuzzle.prompt.options.first.id],
          alreadySolved: true,
        );
        final sylRepeat = validator.validateSubmission(
          puzzle: sylPuzzle,
          selectedSyllables: sylPuzzle.targetVocabulary.syllables,
          alreadySolved: true,
        );

        for (final result in [picRepeat, wordRepeat, sylRepeat]) {
          expect(result.isSolved, isFalse);
          expect(result.isDuplicate, isTrue);
        }
      },
    );

    test('generators reject duplicate vocabulary IDs in pool', () {
      final duplicatePool = [
        _qaPool()[0],
        _qaPool()[0],
        _qaPool()[1],
        _qaPool()[2],
      ];

      expect(
        () => PictureMatchingGenerator().generate(
          vocabularyPool: duplicatePool,
          difficulty: PuzzleDifficulty.easy,
        ),
        throwsA(isA<PuzzleGenerationException>()),
      );
      expect(
        () => WordMatchingGenerator().generate(
          vocabularyPool: duplicatePool,
          difficulty: PuzzleDifficulty.easy,
        ),
        throwsA(isA<PuzzleGenerationException>()),
      );
      expect(
        () => SyllableOrderingGenerator().generate(
          vocabularyPool: duplicatePool,
          difficulty: PuzzleDifficulty.easy,
        ),
        throwsA(isA<PuzzleGenerationException>()),
      );
    });

    test(
      'rejects broken Coeng syllable splits even on direct VocabularyItem',
      () {
        const brokenRiver = VocabularyItem(
          id: 'broken_river',
          khmerWord: 'ទន្លេ',
          syllables: ['ទន', '្លេ'],
          englishMeaning: 'River',
          difficulty: PuzzleDifficulty.medium,
          verification: VocabularyVerification(
            syllables: VerificationStatus.verified,
          ),
        );

        expect(
          KhmerTextUtils.hasValidSyllableSegments(
            brokenRiver.khmerWord,
            brokenRiver.syllables,
          ),
          isFalse,
        );
        expect(
          () => SyllableOrderingGenerator().generate(
            vocabularyPool: const [brokenRiver],
            difficulty: PuzzleDifficulty.medium,
            targetVocabularyId: 'broken_river',
          ),
          throwsA(isA<PuzzleGenerationException>()),
        );
      },
    );

    test('VocabularyItem.fromJson preserves exact Khmer without trimming', () {
      // Whitespace around khmer causes explicit mismatch against syllables.
      expect(
        () => VocabularyItem.fromJson({
          'id': 'ws_test',
          'khmer': ' ដំរី ',
          'english': 'Elephant',
          'verified_syllables': ['ដំ', 'រី'],
          'difficulty': 'easy',
        }),
        throwsFormatException,
      );
    });
  });

  group('Phase 6 Edge Cases & Stress Tests', () {
    test('handles empty and single-entry pools cleanly across generators', () {
      const emptyPool = <VocabularyItem>[];
      final singlePool = [_qaPool().first];

      expect(
        () => PictureMatchingGenerator().generate(
          vocabularyPool: emptyPool,
          difficulty: PuzzleDifficulty.easy,
        ),
        throwsA(isA<PuzzleGenerationException>()),
      );
      expect(
        () => WordMatchingGenerator().generate(
          vocabularyPool: singlePool,
          difficulty: PuzzleDifficulty.easy,
        ),
        throwsA(isA<PuzzleGenerationException>()),
      );
      expect(
        () => SyllableOrderingGenerator().generate(
          vocabularyPool: singlePool,
          difficulty: PuzzleDifficulty.easy,
        ),
        throwsA(isA<PuzzleGenerationException>()),
      );
    });

    test('handles missing image paths and repeated syllable segments safely', () {
      // Unverified synthetic fixture with repeated segment to test multiset preservation.
      const repeatedSegments = VocabularyItem(
        id: 'synthetic_repeat',
        khmerWord: 'សាសាប',
        syllables: ['សា', 'សា', 'ប'],
        englishMeaning: 'Synthetic test',
        difficulty: PuzzleDifficulty.medium,
        imagePath: '',
        verification: VocabularyVerification(
          syllables: VerificationStatus.verified,
        ),
      );

      expect(
        () => PictureMatchingGenerator().generate(
          vocabularyPool: const [repeatedSegments, ...[]],
          difficulty: PuzzleDifficulty.easy,
          requireImage: true,
        ),
        throwsA(isA<PuzzleGenerationException>()),
      );

      final puzzle = SyllableOrderingGenerator(random: Random(9)).generate(
        vocabularyPool: const [repeatedSegments],
        difficulty: PuzzleDifficulty.medium,
      );
      expect(puzzle.prompt.syllableChips.length, 3);
      expect(puzzle.prompt.syllableChips.where((s) => s == 'សា').length, 2);

      const validator = PuzzleValidationService();
      expect(
        validator
            .validateSubmission(
              puzzle: puzzle,
              selectedSyllables: const ['សា', 'សា', 'ប'],
            )
            .isSolved,
        isTrue,
      );
      expect(
        validator
            .validateSubmission(
              puzzle: puzzle,
              selectedSyllables: const ['សា', 'សា', 'សា'],
            )
            .isSolved,
        isFalse,
      );
    });

    test('distinguishes visually similar Khmer combining marks strictly', () {
      const validator = PuzzleValidationService();
      const target = VocabularyItem(
        id: 'ba_muusikatoan',
        khmerWord: 'ប៉ា',
        syllables: ['ប៉ា'],
        englishMeaning: 'Dad',
        difficulty: PuzzleDifficulty.easy,
      );

      // U+17C9 (៉) vs U+17CA (៊) must never match.
      final wrong = validator.validateSyllableOrder(
        target: target,
        selectedSyllables: const ['ប៊ា'],
        availableSyllables: const ['ប៊ា', 'ប៉ា'],
      );
      expect(wrong.isCorrect, isFalse);
    });
  });

  group('Phase 6 Randomized Invariant Tests (Seeded)', () {
    test(
      'maintains invariants across 100 seeded iterations per puzzle type',
      () {
        final random = Random(20261118);
        final pool = _qaPool();
        const difficultyService = PuzzleDifficultyService();
        const validator = PuzzleValidationService();
        final picGen = PictureMatchingGenerator(random: random);
        final wordGen = WordMatchingGenerator(random: random);
        final sylGen = SyllableOrderingGenerator(random: random);

        for (final difficulty in PuzzleDifficulty.values) {
          final settings = difficultyService.getSettings(difficulty);

          for (var i = 0; i < 100; i++) {
            // Picture Matching invariants.
            final pic = picGen.generate(
              vocabularyPool: pool,
              difficulty: difficulty,
            );
            expect(pic.prompt.options.length, settings.optionCount);
            expect(pic.prompt.promptImagePath, pic.targetVocabulary.imagePath);
            expect(
              pic.prompt.options.map((o) => o.id).toSet().length,
              settings.optionCount,
            );
            expect(
              pic.prompt.options.map((o) => o.label).toSet().length,
              settings.optionCount,
            );
            final solvedOptions = pic.prompt.options
                .where(
                  (opt) => validator
                      .validateSubmission(puzzle: pic, selectedOptionId: opt.id)
                      .isSolved,
                )
                .length;
            expect(solvedOptions, 1);

            // Word Matching invariants.
            final word = wordGen.generate(
              vocabularyPool: pool,
              difficulty: difficulty,
            );
            expect(word.prompt.options.length, settings.matchingPairCount);
            expect(word.prompt.rightOptions.length, settings.matchingPairCount);
            for (final left in word.prompt.options) {
              final matches = word.prompt.rightOptions
                  .where(
                    (right) => validator
                        .validateSubmission(
                          puzzle: word,
                          leftOptionId: left.id,
                          rightOptionId: right.id,
                        )
                        .isSolved,
                  )
                  .length;
              expect(matches, 1);
            }

            // Syllable Ordering invariants.
            final syl = sylGen.generate(
              vocabularyPool: pool,
              difficulty: difficulty,
            );
            final expected = List<String>.of(syl.targetVocabulary.syllables);
            final chips = List<String>.of(syl.prompt.syllableChips);
            expect(chips.length, expected.length);
            expect(
              List<String>.of(chips)..sort(),
              List<String>.of(expected)..sort(),
            );
            expect(
              validator
                  .validateSubmission(puzzle: syl, selectedSyllables: expected)
                  .isSolved,
              isTrue,
            );
          }
        }
      },
    );
  });
}
