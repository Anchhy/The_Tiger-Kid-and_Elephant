import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiger_kid_elephant/features/khmer_puzzle/khmer_puzzle.dart';

class _FixtureAssetBundle extends CachingAssetBundle {
  _FixtureAssetBundle(this._content);

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
  final sampleJson = jsonEncode([
    {
      'id': 'tiger',
      'khmer': 'ខ្លា',
      'verified_syllables': ['ខ្លា'],
      'english': 'Tiger',
      'category': 'animals',
      'difficulty': 'easy',
      'image': 'assets/images/vocabulary/tiger.png',
      'hints': {'easy': 'Striped wild cat.'},
      'verification': {
        'spelling': 'verified',
        'meaning': 'verified',
        'syllables': 'verified',
        'example': 'needs_review',
      },
    },
    {
      'id': 'elephant',
      'khmer': 'ដំរី',
      'verified_syllables': ['ដំ', 'រី'],
      'english': 'Elephant',
      'category': 'animals',
      'difficulty': 'easy',
      'image': 'assets/images/vocabulary/elephant.png',
      'hints': {'easy': 'Big animal with a trunk.'},
      'verification': {
        'spelling': 'verified',
        'meaning': 'verified',
        'syllables': 'verified',
        'example': 'needs_review',
      },
    },
    {
      'id': 'water',
      'khmer': 'ទឹក',
      'verified_syllables': ['ទឹក'],
      'english': 'Water',
      'category': 'food',
      'difficulty': 'easy',
      'image': 'assets/images/vocabulary/water.png',
      'verification': {
        'spelling': 'verified',
        'meaning': 'verified',
        'syllables': 'verified',
        'example': 'needs_review',
      },
    },
    {
      'id': 'school',
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

  PuzzleSessionController createController() {
    final repo = KhmerPuzzleRepository(
      loader: KhmerVocabularyLoader(
        assetBundle: _FixtureAssetBundle(sampleJson),
      ),
    );
    return PuzzleSessionController(
      adapter: PuzzleIntegrationAdapter(
        repository: repo,
        generator: PuzzleGenerator(repository: repo, random: Random(11)),
      ),
    );
  }

  group('PuzzleSessionController Game States & Guards', () {
    test('blocks submissions before loading (initial state)', () {
      final controller = createController();

      expect(controller.state, PuzzleGameState.initial);
      expect(controller.canSubmit, isFalse);
      expect(controller.submitAnswer(selectedOptionId: 'opt_0'), isNull);
      expect(controller.requestHint(), isNull);
    });

    test('transitions through loading -> error on invalid request', () async {
      final controller = createController();

      await controller.loadPuzzle(
        const PuzzleRequest(
          levelId: 'level_1',
          puzzleType: PuzzleType.pictureMatching,
          difficulty: PuzzleDifficulty.easy,
          category: 'missing_category',
        ),
      );

      expect(controller.state, PuzzleGameState.error);
      expect(controller.error?.code, 'INSUFFICIENT_VOCABULARY');
      expect(controller.canSubmit, isFalse);
      expect(controller.stateHistory, [
        PuzzleGameState.initial,
        PuzzleGameState.loading,
        PuzzleGameState.error,
      ]);
    });

    test(
      'tracks incorrect -> ready/retry -> correct -> completed with score and blocks post-completion submissions',
      () async {
        final controller = createController();

        await controller.loadPuzzle(
          const PuzzleRequest(
            levelId: 'level_1',
            puzzleType: PuzzleType.pictureMatching,
            difficulty: PuzzleDifficulty.easy,
          ),
        );
        expect(controller.state, PuzzleGameState.ready);

        final puzzle = controller.puzzle!;
        final wrongOption = puzzle.prompt.options.firstWhere(
          (o) => o.id != puzzle.answerKey.correctOptionId,
        );

        // Hint request.
        final hint = controller.requestHint();
        expect(hint?.hasHint, isTrue);
        expect(controller.hintsUsed, 1);

        // Wrong attempt transitions to incorrect.
        final wrongResult = controller.submitAnswer(
          selectedOptionId: wrongOption.id,
        );
        expect(wrongResult?.isSolved, isFalse);
        expect(controller.state, PuzzleGameState.incorrect);
        expect(controller.attemptsUsed, 1);

        // Duplicate wrong option is rejected without incrementing attempts.
        final duplicateWrong = controller.submitAnswer(
          selectedOptionId: wrongOption.id,
        );
        expect(duplicateWrong?.isDuplicate, isTrue);
        expect(controller.attemptsUsed, 1);

        // Correct answer transitions to correct -> completed with score.
        final correctResult = controller.submitAnswer(
          selectedOptionId: puzzle.answerKey.correctOptionId,
        );
        expect(correctResult?.isSolved, isTrue);
        expect(controller.state, PuzzleGameState.completed);
        // Easy (100) - 1 extra attempt (20) - 1 hint (10) = 70.
        expect(controller.score, 70);
        expect(controller.completionEvent?.score, 70);

        // Post-completion submissions are blocked.
        expect(controller.canSubmit, isFalse);
        expect(
          controller.submitAnswer(
            selectedOptionId: puzzle.answerKey.correctOptionId,
          ),
          isNull,
        );
      },
    );

    test('handles multi-pair Word Matching transitions cleanly', () async {
      final controller = createController();

      await controller.loadPuzzle(
        const PuzzleRequest(
          levelId: 'level_2',
          puzzleType: PuzzleType.wordMatching,
          difficulty: PuzzleDifficulty.easy,
        ),
      );

      final puzzle = controller.puzzle!;
      for (var i = 0; i < puzzle.prompt.options.length; i++) {
        final left = puzzle.prompt.options[i];
        final rightId = puzzle.answerKey.expectedPairs[left.id]!;
        final result = controller.submitAnswer(
          leftOptionId: left.id,
          rightOptionId: rightId,
        );
        expect(result?.isSolved, isTrue);
        if (i < puzzle.prompt.options.length - 1) {
          expect(controller.state, PuzzleGameState.correct);
          expect(controller.canSubmit, isTrue);
        } else {
          expect(controller.state, PuzzleGameState.completed);
          expect(controller.canSubmit, isFalse);
          expect(controller.score, 100);
        }
      }
    });

    test(
      'excludeVocabularyIds avoids repeating targets across consecutive puzzles',
      () async {
        final repo = KhmerPuzzleRepository(
          loader: KhmerVocabularyLoader(
            assetBundle: _FixtureAssetBundle(sampleJson),
          ),
        );
        final generator = PuzzleGenerator(repository: repo, random: Random(99));

        final first = await generator.generate(
          type: PuzzleType.pictureMatching,
          difficulty: PuzzleDifficulty.easy,
        );
        final second = await generator.generate(
          type: PuzzleType.pictureMatching,
          difficulty: PuzzleDifficulty.easy,
          excludeVocabularyIds: {first.targetVocabulary.id},
        );

        expect(second.targetVocabulary.id, isNot(first.targetVocabulary.id));
      },
    );
  });
}
