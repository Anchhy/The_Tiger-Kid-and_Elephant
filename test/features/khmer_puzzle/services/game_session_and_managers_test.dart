import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiger_kid_elephant/features/khmer_puzzle/khmer_puzzle.dart';

class _InMemoryBundle extends CachingAssetBundle {
  _InMemoryBundle(this._payload);

  final String _payload;

  @override
  Future<ByteData> load(String key) async => ByteData(0);

  @override
  Future<String> loadString(String key, {bool cache = true}) async => _payload;
}

void main() {
  group('GameScoreManager', () {
    test('awards +10 without hints, +8 with hint once, and streak bonuses', () {
      final score = GameScoreManager();

      // Q1: correct without hint -> +10 (streak 1)
      expect(score.recordAnswer(isCorrect: true), 10);
      expect(score.totalScore, 10);
      expect(score.currentStreak, 1);

      // Q2: request hint twice on same question, solve -> +8 (only -2 once)
      expect(score.recordHintUsed(), 2);
      expect(score.recordHintUsed(), 0);
      expect(score.recordAnswer(isCorrect: true), 8);
      expect(score.totalScore, 18);
      expect(score.currentStreak, 2);

      // Q3: next question without hint -> 3-streak bonus (+10 + 5 = 15)
      score.startNewQuestion();
      expect(score.recordAnswer(isCorrect: true), 15);
      expect(score.totalScore, 33);
      expect(score.currentStreak, 3);

      // Q4 -> +10 (streak 4)
      score.startNewQuestion();
      expect(score.recordAnswer(isCorrect: true), 10);

      // Q5 -> 5-streak bonus (+10 + 10 = 20)
      score.startNewQuestion();
      expect(score.recordAnswer(isCorrect: true), 20);
      expect(score.totalScore, 63);
      expect(score.maxStreak, 5);

      // Incorrect answer awards 0, resets current streak, keeps maxStreak = 5
      score.startNewQuestion();
      expect(score.recordAnswer(isCorrect: false), 0);
      expect(score.currentStreak, 0);
      expect(score.maxStreak, 5);
      expect(score.totalScore, 63);
    });

    test('never allows negative score even on zero score wrong answer', () {
      final score = GameScoreManager();
      expect(score.recordAnswer(isCorrect: false), 0);
      expect(score.totalScore, greaterThanOrEqualTo(0));
    });
  });

  group('LivesManager', () {
    test(
      'tracks initial lives, decrements only on wrong answers, and triggers game over at 0',
      () {
        final lives = LivesManager(initialLives: 3, maxLives: 3);
        expect(lives.remainingLives, 3);
        expect(lives.isGameOver, isFalse);

        expect(lives.recordCorrectAnswer(), 3);
        expect(lives.recordHintUsed(), 3);

        expect(lives.recordIncorrectAnswer(), 2);
        expect(lives.recordIncorrectAnswer(), 1);
        expect(lives.isGameOver, isFalse);

        expect(lives.recordIncorrectAnswer(), 0);
        expect(lives.isGameOver, isTrue);

        // Does not fall below zero or exceed maxLives.
        expect(lives.recordIncorrectAnswer(), 0);
        expect(lives.restoreLife(10), 3);
      },
    );
  });

  group('KhmerTextUtils normalization & accepted answers', () {
    test(
      'normalizes whitespace while preserving Khmer Unicode and checks accepted meanings',
      () {
        const kid = VocabularyItem(
          id: 'kid',
          khmerWord: 'កូនក្មេង',
          syllables: ['កូន', 'ក្មេង'],
          englishMeaning: 'Kid / Child',
          acceptedAnswers: ['Kid', 'Child'],
          difficulty: PuzzleDifficulty.easy,
        );

        expect(KhmerTextUtils.normalizeKhmerText('  កូនក្មេង   '), 'កូនក្មេង');
        expect(KhmerTextUtils.matchesAcceptedAnswer('  kid ', kid), isTrue);
        expect(KhmerTextUtils.matchesAcceptedAnswer('Child', kid), isTrue);
        expect(KhmerTextUtils.matchesAcceptedAnswer('កូនក្មេង', kid), isTrue);
        expect(KhmerTextUtils.matchesAcceptedAnswer('Tiger', kid), isFalse);
      },
    );
  });

  group('GameSessionManager', () {
    final dataset = List<Map<String, dynamic>>.generate(5, (i) {
      final words = [
        ('tiger', 'ខ្លា', ['ខ្លា'], 'Tiger', 'animals'),
        ('water', 'ទឹក', ['ទឹក'], 'Water', 'food'),
        ('elephant', 'ដំរី', ['ដំ', 'រី'], 'Elephant', 'animals'),
        ('kid', 'កូនក្មេង', ['កូន', 'ក្មេង'], 'Kid / Child', 'family'),
        ('flower', 'ផ្កា', ['ផ្កា'], 'Flower', 'nature'),
      ];
      final entry = words[i];
      return {
        'id': entry.$1,
        'khmerWord': entry.$2,
        'syllables': entry.$3,
        'englishMeaning': entry.$4,
        'acceptedAnswers': [entry.$4],
        'category': entry.$5,
        'difficulty': 'easy',
        'imagePath': 'assets/images/vocabulary/${entry.$1}.png',
        'hints': ['Hint 1 for ${entry.$4}', 'Hint 2 for ${entry.$4}'],
        'verified': true,
      };
    });

    GameSessionManager createSessionManager([int seed = 11]) {
      final repo = KhmerPuzzleRepository(
        loader: KhmerVocabularyLoader(
          assetBundle: _InMemoryBundle(jsonEncode(dataset)),
        ),
      );
      return GameSessionManager(
        repository: repo,
        generator: PuzzleGenerator(repository: repo, random: Random(seed)),
      );
    }

    test(
      'runs full 10-question Picture Matching session with non-repeating pool and accurate GameResult',
      () async {
        final manager = createSessionManager(7);
        await manager.startSession(
          const GameConfig(
            questionsPerSession: 10,
            initialLives: 3,
            difficulty: PuzzleDifficulty.easy,
            puzzleType: PuzzleType.pictureMatching,
          ),
        );

        expect(manager.status, GameSessionStatus.ready);
        manager.beginPlaying();
        expect(manager.status, GameSessionStatus.playing);

        final firstCycleTargets = <String>[];

        for (var q = 0; q < 10; q++) {
          final puzzle = manager.currentQuestion!;
          if (q < 5) {
            firstCycleTargets.add(puzzle.targetVocabulary.id);
          }

          // Empty submission yields invalidInput without costing a life or advancing.
          final invalid = manager.submitAnswer(selectedOptionId: '');
          expect(
            invalid?.validationStatus,
            AnswerValidationStatus.invalidInput,
          );
          expect(manager.remainingLives, 3);
          expect(manager.status, GameSessionStatus.playing);

          // Request 1 hint on first question cleanly.
          if (q == 0) {
            final hint = manager.requestHint();
            expect(hint?.hasHint, isTrue);
          }

          final submitted = manager.submitAnswer(
            selectedOptionId: puzzle.answerKey.correctOptionId,
          );
          expect(submitted?.isSolved, isTrue);
          expect(manager.status, GameSessionStatus.answerFeedback);

          // Duplicate submission while in answerFeedback is rejected.
          expect(
            manager.submitAnswer(
              selectedOptionId: puzzle.answerKey.correctOptionId,
            ),
            isNull,
          );

          final hasNext = await manager.nextQuestion();
          expect(hasNext, q < 9);
        }

        // First 5 questions cover all 5 distinct pool items before cycling!
        expect(firstCycleTargets.toSet().length, 5);
        expect(manager.status, GameSessionStatus.completed);

        final result = manager.buildResult();
        expect(result.questionsAttempted, 10);
        expect(result.correctAnswers, 10);
        expect(result.incorrectAnswers, 0);
        expect(result.accuracyPercentage, 100.0);
        expect(result.starRating, 3);
        expect(result.hintsUsed, 1);
        expect(result.livesRemaining, 3);
        expect(result.completionStatus, GameSessionStatus.completed);

        final roundTrip = GameResult.fromJson(result.toJson());
        expect(roundTrip.totalScore, result.totalScore);
        expect(roundTrip.starRating, 3);
      },
    );

    test(
      'supports pause/resume and transitions to gameOver after 3 wrong answers',
      () async {
        final manager = createSessionManager(3);
        await manager.startSession(
          const GameConfig(
            questionsPerSession: 5,
            initialLives: 3,
            difficulty: PuzzleDifficulty.easy,
            puzzleType: PuzzleType.pictureMatching,
          ),
        );
        manager.beginPlaying();

        manager.pauseSession();
        expect(manager.status, GameSessionStatus.paused);
        expect(
          manager.submitAnswer(
            selectedOptionId: manager.currentQuestion!.prompt.options.first.id,
          ),
          isNull,
        );

        manager.resumeSession();
        expect(manager.status, GameSessionStatus.playing);

        for (var i = 0; i < 3; i++) {
          final puzzle = manager.currentQuestion!;
          final wrongOption = puzzle.prompt.options.firstWhere(
            (o) => o.id != puzzle.answerKey.correctOptionId,
          );
          final res = manager.submitAnswer(selectedOptionId: wrongOption.id);
          expect(res?.isSolved, isFalse);
          if (i < 2) {
            expect(manager.status, GameSessionStatus.answerFeedback);
            await manager.nextQuestion();
          }
        }

        expect(manager.remainingLives, 0);
        expect(manager.status, GameSessionStatus.gameOver);

        final gameOverResult = manager.buildResult();
        expect(gameOverResult.completionStatus, GameSessionStatus.gameOver);
        expect(gameOverResult.accuracyPercentage, 0.0);
        expect(gameOverResult.starRating, 0);
      },
    );

    test(
      'computes star ratings accurately and handles zero-attempt division safety',
      () {
        expect(
          GameResult.calculateAccuracy(
            correctAnswers: 0,
            questionsAttempted: 0,
          ),
          0.0,
        );

        const twoStar = GameResult(
          totalScore: 80,
          correctAnswers: 7,
          incorrectAnswers: 3,
          questionsAttempted: 10,
          accuracyPercentage: 70.0,
          hintsUsed: 0,
          maxStreak: 4,
          livesRemaining: 1,
          completionStatus: GameSessionStatus.completed,
        );
        expect(twoStar.starRating, 2);

        const oneStar = GameResult(
          totalScore: 50,
          correctAnswers: 5,
          incorrectAnswers: 5,
          questionsAttempted: 10,
          accuracyPercentage: 50.0,
          hintsUsed: 2,
          maxStreak: 2,
          livesRemaining: 1,
          completionStatus: GameSessionStatus.completed,
        );
        expect(oneStar.starRating, 1);
      },
    );
  });
}
