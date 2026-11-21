import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiger_kid_elephant/features/khmer_puzzle/khmer_puzzle.dart';

class _TestAssetBundle extends CachingAssetBundle {
  _TestAssetBundle(this._content);

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
      'difficulty': 'easy',
      'image': 'assets/images/vocabulary/tiger.png',
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
      'difficulty': 'easy',
      'image': 'assets/images/vocabulary/elephant.png',
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
      'id': 'book',
      'khmer': 'សៀវភៅ',
      'verified_syllables': ['សៀវ', 'ភៅ'],
      'english': 'Book',
      'difficulty': 'medium',
      'image': 'assets/images/vocabulary/book.png',
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

  KhmerPuzzleRepository createTestRepository() => KhmerPuzzleRepository(
    loader: KhmerVocabularyLoader(assetBundle: _TestAssetBundle(sampleJson)),
  );

  group('KhmerPuzzleScreen integration smoke tests', () {
    testWidgets('loads and renders Picture Matching screen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: KhmerPuzzleScreen(
            puzzleType: PuzzleType.pictureMatching,
            difficulty: PuzzleDifficulty.easy,
            repository: createTestRepository(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();

      expect(find.text('Picture Matching'), findsOneWidget);
      expect(find.text('Easy'), findsOneWidget);
      expect(find.text('Submit Answer'), findsOneWidget);
    });

    testWidgets('loads and renders Word Matching screen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: KhmerPuzzleScreen(
            puzzleType: PuzzleType.wordMatching,
            difficulty: PuzzleDifficulty.easy,
            repository: createTestRepository(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Word Matching'), findsOneWidget);
      expect(find.text('Khmer Words'), findsOneWidget);
      expect(find.text('Meanings'), findsOneWidget);
    });

    testWidgets('loads and renders Syllable Ordering screen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: KhmerPuzzleScreen(
            puzzleType: PuzzleType.syllableOrdering,
            difficulty: PuzzleDifficulty.hard,
            repository: createTestRepository(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Syllable Ordering'), findsOneWidget);
      expect(find.text('Check Answer'), findsOneWidget);
    });

    testWidgets('PuzzlePreviewScreen switches puzzle types', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PuzzlePreviewScreen(repository: createTestRepository()),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('M3 Puzzle Preview'), findsOneWidget);
      expect(find.text('Picture Matching'), findsOneWidget);
    });
  });
}
