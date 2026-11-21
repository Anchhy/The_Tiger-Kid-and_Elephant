import 'package:flutter_test/flutter_test.dart';
import 'package:tiger_kid_elephant/features/khmer_puzzle/khmer_puzzle.dart';

void main() {
  group('ScoreCalculator', () {
    const calculator = ScoreCalculator();

    test('returns 0 when puzzle is not solved', () {
      expect(
        calculator.calculateScore(
          difficulty: PuzzleDifficulty.hard,
          isSolved: false,
          attempts: 1,
          hintsUsed: 0,
        ),
        0,
      );
    });

    test(
      'scales base score by difficulty and deducts attempt/hint penalties',
      () {
        expect(
          calculator.calculateScore(
            difficulty: PuzzleDifficulty.easy,
            isSolved: true,
            attempts: 1,
            hintsUsed: 0,
          ),
          100,
        );
        expect(
          calculator.calculateScore(
            difficulty: PuzzleDifficulty.medium,
            isSolved: true,
            attempts: 2,
            hintsUsed: 1,
          ),
          120,
        );
        expect(
          calculator.calculateScore(
            difficulty: PuzzleDifficulty.hard,
            isSolved: true,
            attempts: 1,
            hintsUsed: 1,
          ),
          190,
        );
      },
    );

    test('clamps solved score to minimum floor', () {
      expect(
        calculator.calculateScore(
          difficulty: PuzzleDifficulty.easy,
          isSolved: true,
          attempts: 10,
          hintsUsed: 5,
        ),
        10,
      );
    });

    test('calculates score directly from PuzzleResult', () {
      const solvedResult = PuzzleResult(
        puzzleType: PuzzleType.syllableOrdering,
        difficulty: PuzzleDifficulty.medium,
        vocabularyId: 'book',
        isSolved: true,
        attempts: 1,
        hintsUsed: 2,
      );
      expect(calculator.calculateForResult(solvedResult), 130);
    });
  });
}
