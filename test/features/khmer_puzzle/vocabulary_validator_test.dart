import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tiger_kid_elephant/features/khmer_puzzle/khmer_puzzle.dart';

Map<String, dynamic> _validRecord({
  String id = 'animals_elephant_001',
  String khmer = 'ដំរី',
  String english = 'Elephant',
  String category = 'animals',
  String partOfSpeech = 'noun',
  String difficulty = 'easy',
  List<String>? verifiedSyllables = const ['ដំ', 'រី'],
  String syllableStatus = 'verified',
  List<String> sources = const ['Wiktionary: ដំរី'],
}) {
  return {
    'id': id,
    'khmer': khmer,
    'english': english,
    'definition_km': 'សត្វធំមួយប្រភេទ។',
    'definition_en': 'A large land animal with a long trunk.',
    'part_of_speech': partOfSpeech,
    'category': category,
    'verified_syllables': verifiedSyllables,
    'example_km': 'ដំរីមានប្រមោយវែង។',
    'example_en': 'The elephant has a long trunk.',
    'hints': {
      'easy': 'It is a large animal.',
      'medium': 'It has a long trunk.',
      'strong': 'Starts with ដំ.',
    },
    'difficulty': difficulty,
    'verification': {
      'spelling': 'verified',
      'meaning': 'verified',
      'syllables': syllableStatus,
      'example': 'verified',
    },
    'sources': sources,
  };
}

void main() {
  const validator = VocabularyValidator();

  group('VocabularyValidator', () {
    test(
      '1. accepts a valid vocabulary record with zero errors or warnings',
      () {
        final report = validator.validateRecords([_validRecord()]);

        expect(report.totalEntries, 1);
        expect(report.validEntries, 1);
        expect(report.hasErrors, isFalse);
        expect(report.issues, isEmpty);
      },
    );

    test('2. flags missing required id', () {
      final record = _validRecord()..remove('id');
      final report = validator.validateRecords([record]);

      expect(report.hasErrors, isTrue);
      expect(report.errors.any((e) => e.code == 'ERR_MISSING_ID'), isTrue);
    });

    test('3. flags missing Khmer word', () {
      final record = _validRecord(khmer: '  ');
      final report = validator.validateRecords([record]);

      expect(report.hasErrors, isTrue);
      expect(report.errors.any((e) => e.code == 'ERR_MISSING_KHMER'), isTrue);
    });

    test('4. flags invalid difficulty', () {
      final report = validator.validateRecords([
        _validRecord(difficulty: 'expert'),
      ]);

      expect(report.hasErrors, isTrue);
      expect(
        report.errors.any((e) => e.code == 'ERR_INVALID_DIFFICULTY'),
        isTrue,
      );
    });

    test('5. flags invalid category', () {
      final report = validator.validateRecords([
        _validRecord(category: 'space_travel'),
      ]);

      expect(report.hasErrors, isTrue);
      expect(
        report.errors.any((e) => e.code == 'ERR_INVALID_CATEGORY'),
        isTrue,
      );
    });

    test('6. detects duplicate IDs', () {
      final report = validator.validateRecords([
        _validRecord(
          id: 'dup_001',
          khmer: 'ខ្លា',
          english: 'Tiger',
          verifiedSyllables: const ['ខ្លា'],
        ),
        _validRecord(
          id: 'dup_001',
          khmer: 'គោ',
          english: 'Cow',
          verifiedSyllables: const ['គោ'],
        ),
      ]);

      expect(report.hasErrors, isTrue);
      expect(report.duplicateIds, ['dup_001']);
      expect(report.errors.any((e) => e.code == 'ERR_DUPLICATE_ID'), isTrue);
    });

    test('7. warns on duplicate Khmer words without auto-deleting', () {
      final report = validator.validateRecords([
        _validRecord(
          id: 'word_001',
          khmer: 'បាយ',
          english: 'Cooked rice',
          verifiedSyllables: const ['បាយ'],
        ),
        _validRecord(
          id: 'word_002',
          khmer: 'បាយ',
          english: 'Meal',
          verifiedSyllables: const ['បាយ'],
        ),
      ]);

      expect(report.hasErrors, isFalse);
      expect(report.duplicateKhmerWords, ['បាយ']);
      expect(
        report.warnings.any((w) => w.code == 'WARN_DUPLICATE_KHMER'),
        isTrue,
      );
    });

    test('8. rejects empty syllable list', () {
      final report = validator.validateRecords([
        _validRecord(verifiedSyllables: const []),
      ]);

      expect(report.hasErrors, isTrue);
      expect(report.errors.any((e) => e.code == 'ERR_EMPTY_SYLLABLES'), isTrue);
    });

    test('9. rejects incorrect syllable reconstruction and leading Coeng', () {
      final mismatchReport = validator.validateRecords([
        _validRecord(khmer: 'ដំរី', verifiedSyllables: const ['ដ', 'រី']),
      ]);
      expect(mismatchReport.hasErrors, isTrue);
      expect(
        mismatchReport.errors.any((e) => e.code == 'ERR_SYLLABLE_MISMATCH'),
        isTrue,
      );

      final brokenCoengReport = validator.validateRecords([
        _validRecord(
          id: 'nature_river_031',
          khmer: 'ទន្លេ',
          english: 'River',
          category: 'nature',
          verifiedSyllables: const ['ទន', '្លេ'],
        ),
      ]);
      expect(brokenCoengReport.hasErrors, isTrue);
      expect(
        brokenCoengReport.errors.any(
          (e) => e.code == 'ERR_LEADING_COMBINING_MARK',
        ),
        isTrue,
      );
    });

    test('10. warns on unverified syllable status', () {
      final report = validator.validateRecords([
        _validRecord(syllableStatus: 'needs_review'),
      ]);

      expect(report.hasErrors, isFalse);
      expect(report.unverifiedSyllableCount, 1);
      expect(report.entriesRequiringNativeReview, ['animals_elephant_001']);
      expect(
        report.warnings.any((w) => w.code == 'WARN_UNVERIFIED_SYLLABLES'),
        isTrue,
      );
    });

    test('11. warns on missing source without fabricating references', () {
      final report = validator.validateRecords([
        _validRecord(sources: const []),
      ]);

      expect(report.hasErrors, isFalse);
      expect(
        report.warnings.any((w) => w.code == 'WARN_MISSING_SOURCES'),
        isTrue,
      );
    });

    test(
      '12. preserves Khmer Unicode and detects control/invisible issues',
      () {
        final record = _validRecord(
          id: 'nature_forest_001',
          khmer: 'ព្រៃ\u200Bឈើ',
          english: 'Forest',
          category: 'nature',
          verifiedSyllables: const ['ព្រៃ\u200B', 'ឈើ'],
        );
        final report = validator.validateRecords([record]);

        // Validator inspects without mutating the source map.
        expect(record['khmer'], 'ព្រៃ\u200Bឈើ');
        expect(
          report.warnings.any((w) => w.code == 'WARN_INVISIBLE_CHARS'),
          isTrue,
        );

        final nonKhmerReport = validator.validateRecords([
          _validRecord(
            khmer: 'Elephant',
            verifiedSyllables: const ['Ele', 'phant'],
          ),
        ]);
        expect(
          nonKhmerReport.errors.any((e) => e.code == 'ERR_NO_KHMER_UNICODE'),
          isTrue,
        );
      },
    );

    test(
      'validates knowledge/khmer/examples/initial_vocabulary.json cleanly',
      () {
        final rawJson = File(
          'knowledge/khmer/examples/initial_vocabulary.json',
        ).readAsStringSync();
        final report = validator.validateJsonString(rawJson);

        expect(report.totalEntries, 50);
        expect(report.validEntries, 50);
        expect(report.entriesWithErrors, 0);
        expect(report.duplicateIds, isEmpty);
        expect(report.duplicateKhmerWords, isEmpty);
        expect(report.unverifiedSpellingCount, 2);
        expect(report.unverifiedMeaningCount, 0);
        expect(report.unverifiedSyllableCount, 22);
        expect(report.unverifiedExampleCount, 50);
        expect(report.entriesRequiringNativeReview.length, 50);
      },
    );
  });
}
