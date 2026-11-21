import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tiger_kid_elephant/features/khmer_puzzle/khmer_puzzle.dart';

void main() {
  // Unverified test fixture for generator mechanics only.
  const oneSyllableTiger = VocabularyItem(
    id: 'tiger',
    khmerWord: 'ខ្លា',
    syllables: ['ខ្លា'],
    englishMeaning: 'Tiger',
    difficulty: PuzzleDifficulty.easy,
    verification: VocabularyVerification(
      spelling: VerificationStatus.verified,
      meaning: VerificationStatus.verified,
      syllables: VerificationStatus.verified,
    ),
  );

  const unverifiedElephant = VocabularyItem(
    id: 'elephant',
    khmerWord: 'ដំរី',
    syllables: ['ដំ', 'រី'],
    englishMeaning: 'Elephant',
    difficulty: PuzzleDifficulty.easy,
    verification: VocabularyVerification(
      spelling: VerificationStatus.verified,
      meaning: VerificationStatus.verified,
      syllables: VerificationStatus.needsReview,
    ),
  );

  const verifiedSchool = VocabularyItem(
    id: 'school',
    khmerWord: 'សាលារៀន',
    syllables: ['សា', 'លា', 'រៀន'],
    englishMeaning: 'School',
    difficulty: PuzzleDifficulty.hard,
    verification: VocabularyVerification(
      spelling: VerificationStatus.verified,
      meaning: VerificationStatus.verified,
      syllables: VerificationStatus.verified,
    ),
  );

  const missingSegmentation = VocabularyItem(
    id: 'env',
    khmerWord: 'បរិស្ថាន',
    syllables: [],
    englishMeaning: 'Environment',
    difficulty: PuzzleDifficulty.hard,
  );

  group('SyllableOrderingGenerator', () {
    test(
      'only accepts verified multi-syllable entries and reconstructs word',
      () {
        final generator = SyllableOrderingGenerator(random: Random(5));
        const validator = PuzzleValidationService();

        final puzzle = generator.generate(
          vocabularyPool: const [
            oneSyllableTiger,
            unverifiedElephant,
            verifiedSchool,
            missingSegmentation,
          ],
          difficulty: PuzzleDifficulty.hard,
        );

        expect(puzzle.targetVocabulary.id, 'school');
        expect(puzzle.prompt.syllableChips.length, 3);
        expect(puzzle.prompt.syllableChips, containsAll(['សា', 'លា', 'រៀន']));
        // Shuffled puzzle should not trivially start in original order.
        expect(puzzle.prompt.syllableChips, isNot(['សា', 'លា', 'រៀន']));

        final result = validator.validateSubmission(
          puzzle: puzzle,
          selectedSyllables: const ['សា', 'លា', 'រៀន'],
        );
        expect(result.isSolved, isTrue);
        expect(result.feedbackMessage, contains('សាលារៀន'));
      },
    );

    test(
      'rejects one-syllable, unverified, and missing segmentation entries',
      () {
        final generator = SyllableOrderingGenerator(random: Random(1));

        expect(
          () => generator.generate(
            vocabularyPool: const [oneSyllableTiger],
            difficulty: PuzzleDifficulty.easy,
            targetVocabularyId: 'tiger',
          ),
          throwsA(isA<PuzzleGenerationException>()),
        );

        expect(
          () => generator.generate(
            vocabularyPool: const [unverifiedElephant],
            difficulty: PuzzleDifficulty.easy,
            targetVocabularyId: 'elephant',
          ),
          throwsA(isA<PuzzleGenerationException>()),
        );

        expect(
          () => generator.generate(
            vocabularyPool: const [missingSegmentation],
            difficulty: PuzzleDifficulty.hard,
            targetVocabularyId: 'env',
            requireVerifiedSyllables: false,
          ),
          throwsA(isA<PuzzleGenerationException>()),
        );
      },
    );
  });
}
