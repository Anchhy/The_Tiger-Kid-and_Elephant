import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiger_kid_elephant/features/khmer_puzzle/khmer_puzzle.dart';

class _FakeAssetBundle extends CachingAssetBundle {
  _FakeAssetBundle(this._content);

  final String _content;
  int loadCount = 0;

  @override
  Future<ByteData> load(String key) async {
    throw UnimplementedError();
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    loadCount++;
    return _content;
  }
}

void main() {
  group('KhmerPuzzleRepository', () {
    final sampleJson = jsonEncode([
      {
        'id': 'tiger',
        'khmer': 'ខ្លា',
        'syllables': ['ខ្លា'],
        'english': 'Tiger',
        'category': 'animals',
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
        'syllables': ['ដំ', 'រី'],
        'english': 'Elephant',
        'category': 'animals',
        'difficulty': 'easy',
        'image': 'assets/images/vocabulary/elephant.png',
        'verification': {
          'spelling': 'verified',
          'meaning': 'verified',
          'syllables': 'needs_review',
          'example': 'needs_review',
        },
      },
      {
        'id': 'school',
        'khmer': 'សាលារៀន',
        'syllables': ['សា', 'លា', 'រៀន'],
        'english': 'School',
        'category': 'education',
        'difficulty': 'hard',
        'image': '',
        'verification': {
          'spelling': 'needs_review',
          'meaning': 'verified',
          'syllables': 'verified',
          'example': 'needs_review',
        },
      },
    ]);

    test('caches loaded vocabulary and filters by difficulty', () async {
      final bundle = _FakeAssetBundle(sampleJson);
      final repository = KhmerPuzzleRepository(
        loader: KhmerVocabularyLoader(assetBundle: bundle),
      );

      final easyItems = await repository.getVocabularyByDifficulty(
        PuzzleDifficulty.easy,
      );
      final hardItems = await repository.getVocabularyByDifficulty(
        PuzzleDifficulty.hard,
      );

      expect(bundle.loadCount, 1);
      expect(easyItems.map((item) => item.id), ['tiger', 'elephant']);
      expect(hardItems.map((item) => item.id), ['school']);
    });

    test(
      'filters by category, lookup by ID, and excludes unverified entries',
      () async {
        final bundle = _FakeAssetBundle(sampleJson);
        final repository = KhmerPuzzleRepository(
          loader: KhmerVocabularyLoader(assetBundle: bundle),
        );

        final animals = await repository.getVocabularyByCategory('animals');
        expect(animals.map((item) => item.id), ['tiger', 'elephant']);

        final found = await repository.findById('school');
        expect(found?.khmerWord, 'សាលារៀន');
        await expectLater(
          repository.getByIdOrThrow('missing_id'),
          throwsStateError,
        );

        final verifiedSyllableOnly = await repository.queryVocabulary(
          const VocabularyQuery(
            onlyVerifiedSpelling: true,
            onlyVerifiedSyllables: true,
            requireMultiSyllable: true,
          ),
        );
        expect(verifiedSyllableOnly, isEmpty);

        final withImageAndVerifiedSpelling = await repository.queryVocabulary(
          const VocabularyQuery(onlyVerifiedSpelling: true, requireImage: true),
        );
        expect(withImageAndVerifiedSpelling.map((item) => item.id), [
          'tiger',
          'elephant',
        ]);
      },
    );

    test('filters multi-syllable entries for syllable ordering', () async {
      final bundle = _FakeAssetBundle(sampleJson);
      final repository = KhmerPuzzleRepository(
        loader: KhmerVocabularyLoader(assetBundle: bundle),
      );

      final syllableItems = await repository.getSyllableOrderingVocabulary(
        PuzzleDifficulty.easy,
      );
      expect(syllableItems.map((item) => item.id), ['elephant']);

      final verifiedOnly = await repository.getSyllableOrderingVocabulary(
        PuzzleDifficulty.easy,
        requireVerifiedSyllables: true,
      );
      expect(verifiedOnly, isEmpty);
    });
  });
}
