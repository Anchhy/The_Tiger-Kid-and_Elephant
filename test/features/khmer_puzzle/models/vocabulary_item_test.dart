import 'package:flutter_test/flutter_test.dart';
import 'package:tiger_kid_elephant/features/khmer_puzzle/khmer_puzzle.dart';

void main() {
  group('VocabularyItem', () {
    test(
      'parses full schema JSON and preserves Khmer Unicode on round-trip',
      () {
        final item = VocabularyItem.fromJson({
          'id': 'animals_elephant_002',
          'khmer': 'ដំរី',
          'english': 'Elephant',
          'definition_km': 'សត្វធំមួយប្រភេទ។',
          'definition_en': 'A very large animal.',
          'part_of_speech': 'noun',
          'category': 'animals',
          'verified_syllables': ['ដំ', 'រី'],
          'example_km': 'ដំរីមានប្រមោយវែង។',
          'example_en': 'The elephant has a long trunk.',
          'hints': {
            'easy': 'Big animal',
            'medium': 'Has a long trunk',
            'strong': 'Starts with ដំ',
          },
          'difficulty': 'easy',
          'image': 'assets/images/vocabulary/elephant.png',
          'verification': {
            'spelling': 'verified',
            'meaning': 'verified',
            'syllables': 'needs_review',
            'example': 'needs_review',
          },
          'sources': ['Wiktionary: ដំរី'],
        });

        expect(item.khmerWord, 'ដំរី');
        expect(item.syllables, ['ដំ', 'រី']);
        expect(item.category, 'animals');
        expect(item.hints.orderedHints, [
          'Big animal',
          'Has a long trunk',
          'Starts with ដំ',
        ]);
        expect(item.verification.isSpellingVerified, isTrue);
        expect(item.verification.areSyllablesVerified, isFalse);

        final roundTrip = VocabularyItem.fromJson(item.toJson());
        expect(roundTrip.khmerWord, 'ដំរី');
        expect(roundTrip.syllables, ['ដំ', 'រី']);
        expect(
          roundTrip.verification.syllables,
          VerificationStatus.needsReview,
        );
      },
    );

    test(
      'handles optional fields safely and defaults verification to unverified',
      () {
        // Fixture intentionally unverified linguistically; tests structural defaults.
        final item = VocabularyItem.fromJson({
          'id': 'nature_env_001',
          'khmer': 'បរិស្ថាន',
          'english': 'Environment',
          'verified_syllables': null,
          'difficulty': 'hard',
        });

        expect(item.imagePath, isEmpty);
        expect(item.hasImage, isFalse);
        expect(item.syllables, isEmpty);
        expect(item.supportsSyllableOrdering, isFalse);
        expect(item.verification.isSpellingVerified, isFalse);
        expect(item.verification.areSyllablesVerified, isFalse);
      },
    );

    test('throws FormatException when required fields are missing', () {
      expect(
        () => VocabularyItem.fromJson({
          'khmer': 'ខ្លា',
          'english': 'Tiger',
          'syllables': ['ខ្លា'],
          'difficulty': 'easy',
        }),
        throwsFormatException,
      );

      expect(
        () => VocabularyItem.fromJson({
          'id': 'missing_khmer',
          'english': 'Tiger',
          'syllables': ['ខ្លា'],
          'difficulty': 'easy',
        }),
        throwsFormatException,
      );

      expect(
        () => VocabularyItem.fromJson({
          'id': 'verified_null_syllables',
          'khmer': 'ដំរី',
          'english': 'Elephant',
          'verified_syllables': null,
          'difficulty': 'easy',
          'verification': {'syllables': 'verified'},
        }),
        throwsFormatException,
      );
    });
  });
}
