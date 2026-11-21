import '../utils/khmer_text_utils.dart';
import 'puzzle_enums.dart';

/// Verification status for an individual vocabulary aspect.
enum VerificationStatus {
  verified,
  needsReview,
  unverified;

  static VerificationStatus fromString(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'verified' => VerificationStatus.verified,
      'needs_review' || 'needsreview' => VerificationStatus.needsReview,
      _ => VerificationStatus.unverified,
    };
  }

  String toJsonValue() {
    return switch (this) {
      VerificationStatus.verified => 'verified',
      VerificationStatus.needsReview => 'needs_review',
      VerificationStatus.unverified => 'unverified',
    };
  }
}

/// Field-level linguistic verification metadata for a [VocabularyItem].
class VocabularyVerification {
  const VocabularyVerification({
    this.spelling = VerificationStatus.unverified,
    this.meaning = VerificationStatus.unverified,
    this.syllables = VerificationStatus.unverified,
    this.example = VerificationStatus.unverified,
  });

  final VerificationStatus spelling;
  final VerificationStatus meaning;
  final VerificationStatus syllables;
  final VerificationStatus example;

  bool get isSpellingVerified => spelling == VerificationStatus.verified;
  bool get isMeaningVerified => meaning == VerificationStatus.verified;
  bool get areSyllablesVerified => syllables == VerificationStatus.verified;
  bool get isExampleVerified => example == VerificationStatus.verified;

  factory VocabularyVerification.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const VocabularyVerification();
    }
    return VocabularyVerification(
      spelling: VerificationStatus.fromString(json['spelling'] as String?),
      meaning: VerificationStatus.fromString(json['meaning'] as String?),
      syllables: VerificationStatus.fromString(json['syllables'] as String?),
      example: VerificationStatus.fromString(json['example'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'spelling': spelling.toJsonValue(),
      'meaning': meaning.toJsonValue(),
      'syllables': syllables.toJsonValue(),
      'example': example.toJsonValue(),
    };
  }
}

/// Progressive 3-tier educational hints attached to a [VocabularyItem].
class VocabularyHints {
  const VocabularyHints({this.easy = '', this.medium = '', this.strong = ''});

  final String easy;
  final String medium;
  final String strong;

  List<String> get orderedHints => [
    if (easy.isNotEmpty) easy,
    if (medium.isNotEmpty) medium,
    if (strong.isNotEmpty) strong,
  ];

  factory VocabularyHints.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const VocabularyHints();
    }
    return VocabularyHints(
      easy: (json['easy'] as String? ?? '').trim(),
      medium: (json['medium'] as String? ?? '').trim(),
      strong: (json['strong'] as String? ?? '').trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'easy': easy, 'medium': medium, 'strong': strong};
  }
}

/// Represents a Khmer vocabulary entry loaded from JSON.
class VocabularyItem {
  const VocabularyItem({
    required this.id,
    required this.khmerWord,
    required this.syllables,
    required this.englishMeaning,
    required this.difficulty,
    this.imagePath = '',
    this.category = '',
    this.partOfSpeech = '',
    this.definitionKm = '',
    this.definitionEn = '',
    this.exampleKm = '',
    this.exampleEn = '',
    this.hints = const VocabularyHints(),
    this.hint = '',
    this.educationalNote = '',
    this.acceptedAnswers = const [],
    this.verification = const VocabularyVerification(),
    this.sources = const [],
    this.notes = '',
  });

  /// Unique identifier for the vocabulary entry.
  final String id;

  /// Khmer word in UTF-8 Unicode (preserved without alteration).
  final String khmerWord;

  /// Explicitly stored Khmer syllable segments ordered to form [khmerWord].
  ///
  /// Empty when `verified_syllables` is `null` in the dataset.
  final List<String> syllables;

  /// English meaning shown as educational context or matching prompt.
  final String englishMeaning;

  /// Target difficulty tier for this vocabulary entry.
  final PuzzleDifficulty difficulty;

  /// Optional relative Flutter asset path to the vocabulary illustration.
  final String imagePath;

  /// Vocabulary topic category (e.g. `animals`, `family`, `food`).
  final String category;

  /// Khmer grammatical category (e.g. `noun`, `compound_noun`).
  final String partOfSpeech;

  /// Simple Khmer learner definition.
  final String definitionKm;

  /// Simple English definition.
  final String definitionEn;

  /// Natural Khmer example sentence.
  final String exampleKm;

  /// English translation of [exampleKm].
  final String exampleEn;

  /// Structured progressive hints (`easy`, `medium`, `strong`).
  final VocabularyHints hints;

  /// Optional legacy single-string hint.
  final String hint;

  /// Educational feedback displayed after answering.
  final String educationalNote;

  /// Optional accepted alternative meanings for flexible meaning validation.
  final List<String> acceptedAnswers;

  /// Field-level verification metadata.
  final VocabularyVerification verification;

  /// Reference citations for this vocabulary entry.
  final List<String> sources;

  /// Optional linguistic or curation notes.
  final String notes;

  /// Deduplicated meanings accepted for this item ([englishMeaning] + [acceptedAnswers]).
  List<String> get allAcceptedMeanings {
    final seen = <String>{};
    final meanings = <String>[];
    for (final candidate in [englishMeaning, ...acceptedAnswers]) {
      final trimmed = candidate.trim();
      if (trimmed.isNotEmpty && seen.add(trimmed.toLowerCase())) {
        meanings.add(trimmed);
      }
    }
    return List<String>.unmodifiable(meanings);
  }

  /// Whether this entry has 2+ explicit syllable segments.
  bool get supportsSyllableOrdering => syllables.length > 1;

  /// Whether this entry has an image asset path configured.
  bool get hasImage => imagePath.trim().isNotEmpty;

  /// Creates and validates a [VocabularyItem] from a decoded JSON object.
  factory VocabularyItem.fromJson(Map<String, dynamic> json) {
    final id = _requireString(json, 'id');
    final khmerWord = _requireExactString(
      json,
      'khmer',
      fallbackKey: 'khmerWord',
    );
    final englishMeaning = _requireString(
      json,
      'english',
      fallbackKey: 'englishMeaning',
    );
    final difficultyRaw = _requireString(json, 'difficulty');
    final imagePath = _optionalString(json, 'image', fallbackKey: 'imagePath');

    final rawVerification = json['verification'] as Map<String, dynamic>?;
    final verification = rawVerification != null
        ? VocabularyVerification.fromJson(rawVerification)
        : (json['verified'] == true
              ? const VocabularyVerification(
                  spelling: VerificationStatus.verified,
                  meaning: VerificationStatus.verified,
                  syllables: VerificationStatus.verified,
                )
              : const VocabularyVerification());

    final hasSyllablesKey =
        json.containsKey('verified_syllables') || json.containsKey('syllables');
    final dynamic rawSyllables = json.containsKey('verified_syllables')
        ? json['verified_syllables']
        : json['syllables'];

    final List<String> syllables;
    if (rawSyllables == null) {
      if (!hasSyllablesKey) {
        throw FormatException(
          'Vocabulary item "$id" is missing a syllables/verified_syllables field.',
        );
      }
      if (verification.areSyllablesVerified) {
        throw FormatException(
          'Vocabulary item "$id" cannot have null syllables while verified.',
        );
      }
      syllables = const [];
    } else {
      if (rawSyllables is! List || rawSyllables.isEmpty) {
        throw FormatException(
          'Vocabulary item "$id" must define a non-empty syllables list.',
        );
      }
      final parsed = <String>[];
      for (final segment in rawSyllables) {
        if (segment is! String || segment.isEmpty) {
          throw FormatException(
            'Vocabulary item "$id" contains an invalid syllable segment.',
          );
        }
        parsed.add(segment);
      }
      if (!KhmerTextUtils.hasValidSyllableSegments(khmerWord, parsed)) {
        throw FormatException(
          'Vocabulary item "$id" syllables do not match "$khmerWord".',
        );
      }
      syllables = List<String>.unmodifiable(parsed);
    }

    if (!KhmerTextUtils.containsKhmer(khmerWord)) {
      throw FormatException(
        'Vocabulary item "$id" must contain Khmer Unicode characters.',
      );
    }

    final rawSources = json['sources'];
    final sources = rawSources is List
        ? List<String>.unmodifiable(
            rawSources.whereType<String>().map((s) => s.trim()),
          )
        : const <String>[];

    final rawAccepted = json['acceptedAnswers'];
    final acceptedAnswers = rawAccepted is List
        ? List<String>.unmodifiable(
            rawAccepted
                .whereType<String>()
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty),
          )
        : const <String>[];

    final rawHints = json['hints'];
    final VocabularyHints hints;
    if (rawHints is Map<String, dynamic>) {
      hints = VocabularyHints.fromJson(rawHints);
    } else if (rawHints is List) {
      final listHints = rawHints
          .whereType<String>()
          .map((s) => s.trim())
          .toList();
      hints = VocabularyHints(
        easy: listHints.isNotEmpty ? listHints[0] : '',
        medium: listHints.length > 1 ? listHints[1] : '',
        strong: listHints.length > 2 ? listHints[2] : '',
      );
    } else {
      hints = const VocabularyHints();
    }

    return VocabularyItem(
      id: id,
      khmerWord: khmerWord,
      syllables: syllables,
      englishMeaning: englishMeaning,
      difficulty: PuzzleDifficulty.fromString(difficultyRaw),
      imagePath: imagePath,
      category: _optionalString(json, 'category'),
      partOfSpeech: _optionalString(json, 'part_of_speech'),
      definitionKm: _optionalString(json, 'definition_km'),
      definitionEn: _optionalString(json, 'definition_en'),
      exampleKm: _optionalString(json, 'example_km'),
      exampleEn: _optionalString(json, 'example_en'),
      hints: hints,
      hint: _optionalString(json, 'hint'),
      educationalNote: _optionalString(json, 'educationalNote'),
      acceptedAnswers: acceptedAnswers,
      verification: verification,
      sources: sources,
      notes: _optionalString(json, 'notes'),
    );
  }

  /// Serializes this [VocabularyItem] into a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'khmer': khmerWord,
      'english': englishMeaning,
      'definition_km': definitionKm,
      'definition_en': definitionEn,
      'part_of_speech': partOfSpeech,
      'category': category,
      'verified_syllables': syllables.isEmpty ? null : syllables,
      'example_km': exampleKm,
      'example_en': exampleEn,
      'hints': hints.toJson(),
      'difficulty': difficulty.name,
      'image': imagePath,
      'verification': verification.toJson(),
      'sources': sources,
      if (acceptedAnswers.isNotEmpty) 'acceptedAnswers': acceptedAnswers,
      if (hint.isNotEmpty) 'hint': hint,
      if (educationalNote.isNotEmpty) 'educationalNote': educationalNote,
      if (notes.isNotEmpty) 'notes': notes,
    };
  }

  static String _requireString(
    Map<String, dynamic> json,
    String key, {
    String? fallbackKey,
  }) {
    final value = json[key] ?? (fallbackKey != null ? json[fallbackKey] : null);
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Missing or empty required field "$key".');
    }
    return value.trim();
  }

  static String _requireExactString(
    Map<String, dynamic> json,
    String key, {
    String? fallbackKey,
  }) {
    final value = json[key] ?? (fallbackKey != null ? json[fallbackKey] : null);
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Missing or empty required field "$key".');
    }
    return value;
  }

  static String _optionalString(
    Map<String, dynamic> json,
    String key, {
    String? fallbackKey,
  }) {
    final value = json[key] ?? (fallbackKey != null ? json[fallbackKey] : null);
    if (value == null) {
      return '';
    }
    if (value is! String) {
      throw FormatException('Optional field "$key" must be a string.');
    }
    return value.trim();
  }
}
