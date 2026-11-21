import 'package:flutter_test/flutter_test.dart';
import 'package:tiger_kid_elephant/features/khmer_puzzle/khmer_puzzle.dart';

void main() {
  const elephant = VocabularyItem(
    id: 'elephant',
    khmerWord: 'ដំរី',
    syllables: ['ដំ', 'រី'],
    englishMeaning: 'Elephant',
    difficulty: PuzzleDifficulty.easy,
    imagePath: 'assets/images/vocabulary/elephant.png',
    hints: VocabularyHints(
      easy: 'A very large animal.',
      medium: 'Has a long trunk.',
      strong: 'Starts with ដំ.',
    ),
    educationalNote: 'ដំរី (damrei) has two syllables: ដំ and រី.',
  );

  const tiger = VocabularyItem(
    id: 'tiger',
    khmerWord: 'ខ្លា',
    syllables: ['ខ្លា'],
    englishMeaning: 'Tiger',
    difficulty: PuzzleDifficulty.easy,
    imagePath: 'assets/images/vocabulary/tiger.png',
    hint: 'A wild striped cat.',
    educationalNote: 'ខ្លា (klaa) means tiger.',
  );

  const school = VocabularyItem(
    id: 'school',
    khmerWord: 'សាលារៀន',
    syllables: ['សា', 'លា', 'រៀន'],
    englishMeaning: 'School',
    difficulty: PuzzleDifficulty.hard,
    imagePath: 'assets/images/vocabulary/school.png',
    hint: 'A place where students go to learn.',
    educationalNote: 'សាលារៀន has three syllables: សា, លា, and រៀន.',
  );

  const noHintWord = VocabularyItem(
    id: 'water',
    khmerWord: 'ទឹក',
    syllables: ['ទឹក'],
    englishMeaning: 'Water',
    difficulty: PuzzleDifficulty.easy,
  );

  group('PuzzleDifficultyService', () {
    const difficultyService = PuzzleDifficultyService();

    test('scales options, pairs, attempts, and hints across levels', () {
      final easy = difficultyService.getSettings(PuzzleDifficulty.easy);
      final medium = difficultyService.getSettings(PuzzleDifficulty.medium);
      final hard = difficultyService.getSettings(PuzzleDifficulty.hard);

      expect(easy.optionCount, 3);
      expect(medium.optionCount, 4);
      expect(hard.optionCount, 5);

      expect(easy.matchingPairCount, 3);
      expect(medium.matchingPairCount, 4);
      expect(hard.matchingPairCount, 5);

      expect(easy.maxHints, greaterThan(medium.maxHints));
      expect(medium.maxHints, greaterThan(hard.maxHints));
      expect(easy.maxAttempts, greaterThan(hard.maxAttempts));
      expect(easy.allowDirectClue, isTrue);
      expect(hard.allowDirectClue, isFalse);
    });
  });

  group('PuzzleHintService & HintSession', () {
    const hintService = PuzzleHintService();

    test('delivers progressive non-repeating hints and respects limits', () {
      final session = hintService.startSession(
        target: elephant,
        puzzleType: PuzzleType.pictureMatching,
        difficulty: PuzzleDifficulty.easy,
      );

      final first = session.requestNextHint();
      final second = session.requestNextHint();
      final third = session.requestNextHint();
      final fourth = session.requestNextHint();

      expect(first.hasHint, isTrue);
      expect(second.hasHint, isTrue);
      expect(third.hasHint, isTrue);
      expect(fourth.hasHint, isFalse);

      expect({first.text, second.text, third.text}.length, 3);
      expect(session.hintsUsed, 3);
      expect(fourth.remainingHints, 0);
    });

    test('handles missing hints safely without exposing answer', () {
      final session = hintService.startSession(
        target: noHintWord,
        puzzleType: PuzzleType.pictureMatching,
        difficulty: PuzzleDifficulty.easy,
      );

      final first = session.requestNextHint();
      expect(first.hasHint, isTrue);
      expect(first.text, isNot(contains('ទឹក')));
    });

    test('gives less direct hints on hard difficulty', () {
      final hardHint = hintService.getHint(
        target: school,
        puzzleType: PuzzleType.pictureMatching,
        difficulty: PuzzleDifficulty.hard,
        hintIndex: 0,
      );

      expect(hardHint, contains('3 syllable'));
      expect(hardHint, isNot(contains(school.hint)));
    });
  });

  group('PuzzleValidationService', () {
    const validationService = PuzzleValidationService();

    test(
      'validates Puzzle submissions including unknown puzzle ID and empty answer',
      () {
        const puzzle = Puzzle(
          prompt: PuzzlePrompt(
            puzzleId: 'pic_001',
            type: PuzzleType.pictureMatching,
            difficulty: PuzzleDifficulty.easy,
            instruction: 'Match',
            options: [
              PuzzleOption(id: 'opt_0', label: 'ដំរី'),
              PuzzleOption(id: 'opt_1', label: 'ខ្លា'),
            ],
          ),
          targetVocabulary: elephant,
          answerKey: PuzzleAnswerKey(
            targetVocabularyId: 'elephant',
            correctOptionId: 'opt_0',
          ),
        );

        final solved = validationService.validateSubmission(
          puzzle: puzzle,
          selectedOptionId: 'opt_0',
        );
        expect(solved.isSolved, isTrue);
        expect(solved.puzzleId, 'pic_001');

        final wrong = validationService.validateSubmission(
          puzzle: puzzle,
          selectedOptionId: 'opt_1',
        );
        expect(wrong.isSolved, isFalse);

        final empty = validationService.validateSubmission(
          puzzle: puzzle,
          selectedOptionId: '  ',
        );
        expect(empty.isSolved, isFalse);

        const unknownPuzzle = Puzzle(
          prompt: PuzzlePrompt(
            puzzleId: '',
            type: PuzzleType.pictureMatching,
            difficulty: PuzzleDifficulty.easy,
            instruction: 'Match',
          ),
          targetVocabulary: elephant,
          answerKey: PuzzleAnswerKey(targetVocabularyId: 'elephant'),
        );
        final unknown = validationService.validateSubmission(
          puzzle: unknownPuzzle,
          selectedOptionId: 'opt_0',
        );
        expect(unknown.isSolved, isFalse);
        expect(unknown.feedbackMessage, contains('Unknown puzzle ID'));
      },
    );

    test('validates Word Matching pairs and completed pair tracking', () {
      final byId = {'elephant': elephant, 'tiger': tiger};
      final roundIds = {'elephant', 'tiger'};

      final correctPair = validationService.validatePair(
        leftVocabularyId: 'elephant',
        rightVocabularyId: 'elephant',
        vocabularyById: byId,
        availableIds: roundIds,
      );
      expect(correctPair.isCorrect, isTrue);

      final incorrectPair = validationService.validatePair(
        leftVocabularyId: 'elephant',
        rightVocabularyId: 'tiger',
        vocabularyById: byId,
        availableIds: roundIds,
      );
      expect(incorrectPair.isCorrect, isFalse);
      expect(incorrectPair.isDuplicate, isFalse);

      final completedPairRetry = validationService.validatePair(
        leftVocabularyId: 'elephant',
        rightVocabularyId: 'elephant',
        vocabularyById: byId,
        completedPairIds: {'elephant'},
        availableIds: roundIds,
      );
      expect(completedPairRetry.isCorrect, isFalse);
      expect(completedPairRetry.isDuplicate, isTrue);
    });

    test('validates Syllable Ordering sequence, duplicates, and Unicode', () {
      final correct = validationService.validateSyllableOrder(
        target: school,
        selectedSyllables: const ['សា', 'លា', 'រៀន'],
        availableSyllables: const ['រៀន', 'សា', 'លា'],
      );
      expect(correct.isCorrect, isTrue);
      expect(correct.feedbackMessage, contains('សាលារៀន'));

      final wrongOrder = validationService.validateSyllableOrder(
        target: school,
        selectedSyllables: const ['លា', 'សា', 'រៀន'],
        availableSyllables: const ['រៀន', 'សា', 'លា'],
      );
      expect(wrongOrder.isCorrect, isFalse);

      final incomplete = validationService.validateSyllableOrder(
        target: school,
        selectedSyllables: const ['សា', 'លា'],
        availableSyllables: const ['រៀន', 'សា', 'លា'],
      );
      expect(incomplete.isCorrect, isFalse);

      final empty = validationService.validateSyllableOrder(
        target: school,
        selectedSyllables: const [],
      );
      expect(empty.isCorrect, isFalse);

      final duplicatedSegment = validationService.validateSyllableOrder(
        target: school,
        selectedSyllables: const ['សា', 'សា', 'រៀន'],
        availableSyllables: const ['រៀន', 'សា', 'លា'],
      );
      expect(duplicatedSegment.isCorrect, isFalse);
      expect(duplicatedSegment.isDuplicate, isTrue);
    });
  });
}
