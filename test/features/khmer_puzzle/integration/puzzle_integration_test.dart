import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiger_kid_elephant/features/khmer_puzzle/khmer_puzzle.dart';

class _MockLevelAssetBundle extends CachingAssetBundle {
  _MockLevelAssetBundle(this._content);

  final String _content;

  @override
  Future<ByteData> load(String key) async {
    throw UnimplementedError();
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return _content;
  }
}

void main() {
  // Mock vocabulary fixture simulating M1/M5 integration until real M1/M4/M5 modules exist.
  final mockDatasetJson = jsonEncode([
    {
      'id': 'animals_tiger_001',
      'khmer': 'ខ្លា',
      'verified_syllables': ['ខ្លា'],
      'english': 'Tiger',
      'category': 'animals',
      'difficulty': 'easy',
      'image': 'assets/images/vocabulary/tiger.png',
      'hints': {
        'easy': 'A wild striped cat.',
        'medium': 'Orange fur with black stripes.',
        'strong': 'Chases the kid in the maze.',
      },
      'verification': {
        'spelling': 'verified',
        'meaning': 'verified',
        'syllables': 'verified',
        'example': 'needs_review',
      },
    },
    {
      'id': 'animals_elephant_002',
      'khmer': 'ដំរី',
      'verified_syllables': ['ដំ', 'រី'],
      'english': 'Elephant',
      'category': 'animals',
      'difficulty': 'easy',
      'image': 'assets/images/vocabulary/elephant.png',
      'hints': {
        'easy': 'A very big animal.',
        'medium': 'Has a long trunk.',
        'strong': 'Starts with ដំ.',
      },
      'verification': {
        'spelling': 'verified',
        'meaning': 'verified',
        'syllables': 'verified',
        'example': 'needs_review',
      },
    },
    {
      'id': 'food_water_019',
      'khmer': 'ទឹក',
      'verified_syllables': ['ទឹក'],
      'english': 'Water',
      'category': 'food',
      'difficulty': 'easy',
      'image': '',
      'verification': {
        'spelling': 'verified',
        'meaning': 'verified',
        'syllables': 'verified',
        'example': 'needs_review',
      },
    },
    {
      'id': 'education_school_036',
      'khmer': 'សាលារៀន',
      'verified_syllables': ['សា', 'លា', 'រៀន'],
      'english': 'School',
      'category': 'education',
      'difficulty': 'hard',
      'image': 'assets/images/vocabulary/school.png',
      'verification': {
        'spelling': 'verified',
        'meaning': 'verified',
        'syllables': 'verified',
        'example': 'needs_review',
      },
    },
  ]);

  PuzzleIntegrationAdapter createAdapter({String? jsonOverride}) {
    final repo = KhmerPuzzleRepository(
      loader: KhmerVocabularyLoader(
        assetBundle: _MockLevelAssetBundle(jsonOverride ?? mockDatasetJson),
      ),
    );
    return PuzzleIntegrationAdapter(
      repository: repo,
      scoreCalculator: (result) =>
          (100 - (result.attempts - 1) * 20 - result.hintsUsed * 10).clamp(
            10,
            100,
          ),
    );
  }

  group('M3 Mock Integration Tests (M1/M4/M5 boundary simulation)', () {
    test(
      'handles valid requests across all three puzzle types and emits completion events',
      () async {
        final adapter = createAdapter();

        // 1. Picture Matching from M1-style JSON config.
        final picLoad = await adapter.loadPuzzleFromJson({
          'levelId': 'level_1_checkpoint_a',
          'puzzleType': 'picture_matching',
          'difficulty': 'easy',
          'configuration': {
            'targetVocabularyId': 'animals_elephant_002',
            'requireImage': true,
          },
        });
        expect(picLoad.isSuccess, isTrue);
        final picPuzzle = picLoad.puzzle!;
        expect(picLoad.presentation?.puzzleId, picPuzzle.id);

        final picOutcome = adapter.submitAnswer(
          request: PuzzleRequest.fromJson({
            'levelId': 'level_1_checkpoint_a',
            'puzzleType': 'picture_matching',
            'difficulty': 'easy',
          }),
          puzzle: picPuzzle,
          selectedOptionId: picPuzzle.answerKey.correctOptionId,
          attempts: 1,
          hintsUsed: 0,
        );
        expect(picOutcome.isSuccess, isTrue);
        expect(picOutcome.completionEvent?.isCompleted, isTrue);
        expect(picOutcome.completionEvent?.isCorrect, isTrue);
        expect(picOutcome.completionEvent?.score, 100);
        expect(
          picOutcome.completionEvent?.toJson()['levelId'],
          'level_1_checkpoint_a',
        );

        // 2. Word Matching (multi-pair completion only emits event on final pair).
        const wordRequest = PuzzleRequest(
          levelId: 'level_2_checkpoint_b',
          puzzleType: PuzzleType.wordMatching,
          difficulty: PuzzleDifficulty.easy,
        );
        final wordLoad = await adapter.loadPuzzle(wordRequest);
        expect(wordLoad.isSuccess, isTrue);
        final wordPuzzle = wordLoad.puzzle!;

        final matchedIds = <String>{};
        PuzzleCompletionEvent? finalWordEvent;
        for (var i = 0; i < wordPuzzle.prompt.options.length; i++) {
          final left = wordPuzzle.prompt.options[i];
          final rightId = wordPuzzle.answerKey.expectedPairs[left.id]!;
          final outcome = adapter.submitAnswer(
            request: wordRequest,
            puzzle: wordPuzzle,
            leftOptionId: left.id,
            rightOptionId: rightId,
            completedPairIds: Set<String>.from(matchedIds),
          );
          expect(outcome.result?.isSolved, isTrue);
          matchedIds
            ..add(left.id)
            ..add(rightId);
          if (i < wordPuzzle.prompt.options.length - 1) {
            expect(outcome.completionEvent, isNull);
          } else {
            finalWordEvent = outcome.completionEvent;
          }
        }
        expect(finalWordEvent?.isCompleted, isTrue);
        expect(finalWordEvent?.isCorrect, isTrue);

        // 3. Syllable Ordering preserves Khmer Unicode and validates order.
        const sylRequest = PuzzleRequest(
          levelId: 'level_3_checkpoint_c',
          puzzleType: PuzzleType.syllableOrdering,
          difficulty: PuzzleDifficulty.hard,
          category: 'education',
        );
        final sylLoad = await adapter.loadPuzzle(sylRequest);
        expect(sylLoad.isSuccess, isTrue);
        final sylPuzzle = sylLoad.puzzle!;
        expect(sylPuzzle.targetVocabulary.khmerWord, 'សាលារៀន');

        final hintSession = adapter.startHintSession(sylPuzzle);
        final hint = adapter.requestHint(hintSession);
        expect(hint.hasHint, isTrue);

        final sylOutcome = adapter.submitAnswer(
          request: sylRequest,
          puzzle: sylPuzzle,
          selectedSyllables: const ['សា', 'លា', 'រៀន'],
          attempts: 1,
          hintsUsed: hintSession.hintsUsed,
        );
        expect(sylOutcome.completionEvent?.isCorrect, isTrue);
        expect(sylOutcome.completionEvent?.hintsUsed, 1);
        expect(sylOutcome.completionEvent?.score, 90);
        expect(
          sylOutcome.completionEvent?.feedbackMessage,
          contains('សាលារៀន'),
        );
      },
    );

    test(
      'handles invalid requests, unsupported types, and empty/missing datasets',
      () async {
        final adapter = createAdapter();

        final emptyLevel = await adapter.loadPuzzleFromJson({
          'levelId': '  ',
          'puzzleType': 'picture_matching',
          'difficulty': 'easy',
        });
        expect(emptyLevel.isSuccess, isFalse);
        expect(emptyLevel.error?.code, 'INVALID_REQUEST');

        final unsupportedType = await adapter.loadPuzzleFromJson({
          'levelId': 'level_1',
          'puzzleType': 'crossword_puzzle',
          'difficulty': 'easy',
        });
        expect(unsupportedType.isSuccess, isFalse);
        expect(unsupportedType.error?.code, 'UNSUPPORTED_PUZZLE_TYPE');

        final unsupportedConfig = await adapter.loadPuzzle(
          const PuzzleRequest(
            levelId: 'level_1',
            puzzleType: PuzzleType.pictureMatching,
            difficulty: PuzzleDifficulty.easy,
            category: 'nonexistent_category',
          ),
        );
        expect(unsupportedConfig.isSuccess, isFalse);
        expect(unsupportedConfig.error?.code, 'INSUFFICIENT_VOCABULARY');

        // Missing image asset filtering when requireImage is true.
        final missingImage = await adapter.loadPuzzle(
          const PuzzleRequest(
            levelId: 'level_1',
            puzzleType: PuzzleType.pictureMatching,
            difficulty: PuzzleDifficulty.easy,
            configuration: PuzzleRequestConfig(
              targetVocabularyId: 'food_water_019',
              requireImage: true,
            ),
          ),
        );
        expect(missingImage.isSuccess, isFalse);
        expect(missingImage.error?.code, 'INSUFFICIENT_VOCABULARY');

        // Empty vocabulary dataset returns structured VOCABULARY_LOAD_ERROR.
        final emptyAdapter = createAdapter(jsonOverride: '[]');
        final emptyLoad = await emptyAdapter.loadPuzzle(
          const PuzzleRequest(
            levelId: 'level_1',
            puzzleType: PuzzleType.wordMatching,
            difficulty: PuzzleDifficulty.easy,
          ),
        );
        expect(emptyLoad.isSuccess, isFalse);
        expect(emptyLoad.error?.code, 'VOCABULARY_LOAD_ERROR');
      },
    );

    test(
      'handles incorrect answers, max attempts termination, and repeated completion submissions',
      () async {
        final adapter = createAdapter();
        const request = PuzzleRequest(
          levelId: 'level_1_checkpoint_b',
          puzzleType: PuzzleType.pictureMatching,
          difficulty: PuzzleDifficulty.easy,
        );
        final load = await adapter.loadPuzzle(request);
        final puzzle = load.puzzle!;
        final wrongOption = puzzle.prompt.options.firstWhere(
          (o) => o.id != puzzle.answerKey.correctOptionId,
        );

        // Incorrect intermediate attempt: not terminal yet.
        final firstWrong = adapter.submitAnswer(
          request: request,
          puzzle: puzzle,
          selectedOptionId: wrongOption.id,
          attempts: 1,
        );
        expect(firstWrong.result?.isSolved, isFalse);
        expect(firstWrong.completionEvent, isNull);

        // Exhausting maxAttempts emits terminal failure completion event.
        final finalWrong = adapter.submitAnswer(
          request: request,
          puzzle: puzzle,
          selectedOptionId: wrongOption.id,
          attempts: puzzle.prompt.maxAttempts,
        );
        expect(finalWrong.completionEvent?.isCompleted, isTrue);
        expect(finalWrong.completionEvent?.isCorrect, isFalse);
        expect(finalWrong.completionEvent?.score, isNull);

        // Repeated completion submission does not emit another completion event.
        final repeat = adapter.submitAnswer(
          request: request,
          puzzle: puzzle,
          selectedOptionId: puzzle.answerKey.correctOptionId,
          alreadyCompleted: true,
        );
        expect(repeat.result?.isSolved, isFalse);
        expect(repeat.result?.isDuplicate, isTrue);
        expect(repeat.completionEvent, isNull);
      },
    );
  });
}
