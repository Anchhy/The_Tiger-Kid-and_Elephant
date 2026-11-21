import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiger_kid_elephant/features/khmer_puzzle/khmer_puzzle.dart';

class _StringAssetBundle extends CachingAssetBundle {
  _StringAssetBundle(this._content);

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
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Khmer vocabulary dataset', () {
    test(
      'loads valid Khmer Unicode words and verified syllable segments',
      () async {
        final loader = KhmerVocabularyLoader();
        final items = await loader.loadVocabulary();

        expect(items, isNotEmpty);

        final ids = <String>{};
        for (final item in items) {
          expect(ids.add(item.id), isTrue, reason: 'Duplicate id: ${item.id}');
          expect(item.englishMeaning.trim(), isNotEmpty);
          expect(item.imagePath, startsWith('assets/images/vocabulary/'));
          expect(
            KhmerTextUtils.containsKhmer(item.khmerWord),
            isTrue,
            reason: '${item.id} must contain Khmer Unicode characters',
          );
          expect(
            KhmerTextUtils.hasValidSyllableSegments(
              item.khmerWord,
              item.syllables,
            ),
            isTrue,
            reason:
                '${item.id} syllables ${item.syllables} do not join to ${item.khmerWord}',
          );
        }
      },
    );

    test('includes enough items across all difficulty levels', () async {
      final loader = KhmerVocabularyLoader();
      final items = await loader.loadVocabulary();

      for (final level in PuzzleDifficulty.values) {
        expect(
          items.where((item) => item.difficulty == level).length,
          greaterThanOrEqualTo(20),
          reason: 'Need at least 20 items for difficulty: ${level.name}',
        );
      }

      expect(
        items.any((item) => item.supportsSyllableOrdering),
        isTrue,
        reason: 'At least one multi-syllable word is required',
      );
    });

    test('all 60 bundled vocabulary PNG image assets load cleanly', () async {
      final loader = KhmerVocabularyLoader();
      final items = await loader.loadVocabulary();
      expect(items.length, greaterThanOrEqualTo(60));

      for (final item in items) {
        final bytes = await rootBundle.load(item.imagePath);
        expect(
          bytes.lengthInBytes,
          greaterThan(0),
          reason: '${item.id} image asset ${item.imagePath} must not be empty',
        );
      }
    });

    test(
      'all extracted character, UI, reward, level, and categorized assets load cleanly',
      () async {
        expect(
          KhmerPuzzleAssets.categorizedVocabularyPath('tiger'),
          'assets/images/vocabulary/animals/tiger.png',
        );
        expect(
          KhmerPuzzleAssets.categorizedVocabularyPath('boat'),
          'assets/images/vocabulary/transportation/boat.png',
        );
        expect(
          KhmerPuzzleAssets.vocabularyPath('school'),
          'assets/images/vocabulary/school.png',
        );

        for (final assetPath in KhmerPuzzleAssets.allRegisteredImageAssets) {
          final bytes = await rootBundle.load(assetPath);
          expect(
            bytes.lengthInBytes,
            greaterThan(0),
            reason: 'Registered asset $assetPath must exist and be non-empty',
          );
        }
      },
    );

    test('preserves Khmer Unicode on JSON round-trip and alias keys', () {
      final item = VocabularyItem.fromJson({
        'id': 'khmer_001',
        'khmer': 'ដំរី',
        'english': 'Elephant',
        'syllables': ['ដំ', 'រី'],
        'difficulty': 'easy',
        'image': 'assets/images/vocabulary/elephant.png',
        'hint': 'សត្វធំ',
      });

      expect(item.khmerWord, 'ដំរី');
      expect(item.syllables, ['ដំ', 'រី']);
      final serialized = VocabularyItem.fromJson(item.toJson());
      expect(serialized.khmerWord, 'ដំរី');
      expect(serialized.syllables, ['ដំ', 'រី']);
    });

    test(
      'rejects empty, malformed, missing, or invalid Khmer JSON data',
      () async {
        final emptyLoader = KhmerVocabularyLoader(
          assetBundle: _StringAssetBundle('   '),
        );
        await expectLater(emptyLoader.loadVocabulary(), throwsFormatException);

        final nonListLoader = KhmerVocabularyLoader(
          assetBundle: _StringAssetBundle('{"id": "tiger"}'),
        );
        await expectLater(
          nonListLoader.loadVocabulary(),
          throwsFormatException,
        );

        final missingFieldLoader = KhmerVocabularyLoader(
          assetBundle: _StringAssetBundle(
            jsonEncode([
              {
                'id': 'bad',
                'khmerWord': 'ដំរី',
                'syllables': ['ដំ', 'រី'],
                'difficulty': 'easy',
                'imagePath': 'assets/images/vocabulary/elephant.png',
              },
            ]),
          ),
        );
        await expectLater(
          missingFieldLoader.loadVocabulary(),
          throwsFormatException,
        );

        final mismatchedSyllablesLoader = KhmerVocabularyLoader(
          assetBundle: _StringAssetBundle(
            jsonEncode([
              {
                'id': 'bad_syllables',
                'khmerWord': 'ដំរី',
                'syllables': ['ដ', 'រី'],
                'englishMeaning': 'Elephant',
                'difficulty': 'easy',
                'imagePath': 'assets/images/vocabulary/elephant.png',
              },
            ]),
          ),
        );
        await expectLater(
          mismatchedSyllablesLoader.loadVocabulary(),
          throwsFormatException,
        );

        final duplicateIdLoader = KhmerVocabularyLoader(
          assetBundle: _StringAssetBundle(
            jsonEncode([
              {
                'id': 'dup',
                'khmerWord': 'ខ្លា',
                'syllables': ['ខ្លា'],
                'englishMeaning': 'Tiger',
                'difficulty': 'easy',
                'imagePath': 'assets/images/vocabulary/tiger.png',
              },
              {
                'id': 'dup',
                'khmerWord': 'ទឹក',
                'syllables': ['ទឹក'],
                'englishMeaning': 'Water',
                'difficulty': 'easy',
                'imagePath': 'assets/images/vocabulary/water.png',
              },
            ]),
          ),
        );
        await expectLater(
          duplicateIdLoader.loadVocabulary(),
          throwsFormatException,
        );
      },
    );
  });
}
