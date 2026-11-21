import 'dart:convert';

import 'khmer_text_utils.dart';

/// Severity level for a vocabulary validation finding.
enum ValidationSeverity { error, warning }

/// A single structured validation error or warning on a vocabulary entry.
class ValidationIssue {
  const ValidationIssue({
    required this.severity,
    required this.code,
    required this.entryIndex,
    required this.entryId,
    required this.field,
    required this.message,
  });

  final ValidationSeverity severity;
  final String code;
  final int entryIndex;
  final String entryId;
  final String field;
  final String message;
}

/// Summary report produced by [VocabularyValidator].
class VocabularyValidationReport {
  const VocabularyValidationReport({
    required this.totalEntries,
    required this.validEntries,
    required this.entriesWithErrors,
    required this.entriesWithWarnings,
    required this.duplicateIds,
    required this.duplicateKhmerWords,
    required this.duplicateEnglishMeanings,
    required this.missingFieldCount,
    required this.unverifiedSpellingCount,
    required this.unverifiedMeaningCount,
    required this.unverifiedSyllableCount,
    required this.unverifiedExampleCount,
    required this.entriesRequiringNativeReview,
    required this.issues,
  });

  final int totalEntries;
  final int validEntries;
  final int entriesWithErrors;
  final int entriesWithWarnings;
  final List<String> duplicateIds;
  final List<String> duplicateKhmerWords;
  final List<String> duplicateEnglishMeanings;
  final int missingFieldCount;
  final int unverifiedSpellingCount;
  final int unverifiedMeaningCount;
  final int unverifiedSyllableCount;
  final int unverifiedExampleCount;
  final List<String> entriesRequiringNativeReview;
  final List<ValidationIssue> issues;

  /// All error-level issues.
  List<ValidationIssue> get errors => issues
      .where((issue) => issue.severity == ValidationSeverity.error)
      .toList(growable: false);

  /// All warning-level issues.
  List<ValidationIssue> get warnings => issues
      .where((issue) => issue.severity == ValidationSeverity.warning)
      .toList(growable: false);

  /// Whether the dataset passed with zero errors.
  bool get hasErrors => entriesWithErrors > 0 || errors.isNotEmpty;
}

/// Validates raw Khmer vocabulary JSON datasets without modifying any content.
class VocabularyValidator {
  const VocabularyValidator();

  static const Set<String> allowedCategories = {
    'animals',
    'family',
    'food',
    'nature',
    'education',
    'daily_life',
    'body_parts',
    'transportation',
    'colors_shapes',
    'numbers_time',
  };

  static const Set<String> allowedPartsOfSpeech = {
    'noun',
    'verb',
    'stative_verb',
    'adverb',
    'pronoun',
    'classifier',
    'particle',
    'compound_noun',
  };

  static const Set<String> allowedDifficulties = {'easy', 'medium', 'hard'};

  static const Set<String> allowedVerificationStatuses = {
    'verified',
    'needs_review',
    'unverified',
  };

  static const List<String> verificationKeys = [
    'spelling',
    'meaning',
    'syllables',
    'example',
  ];

  static final RegExp _controlChars = RegExp(r'[\u0000-\u001F\u007F-\u009F]');
  static final RegExp _invisibleChars = RegExp(
    r'[\u200B-\u200F\u202A-\u202E\u2060\uFEFF]',
  );
  static final RegExp _leadingCombiningMark = RegExp(r'^[\u17B4-\u17D3]');

  /// Parses [rawJson] and validates the decoded list of vocabulary records.
  VocabularyValidationReport validateJsonString(String rawJson) {
    if (rawJson.trim().isEmpty) {
      return const VocabularyValidationReport(
        totalEntries: 0,
        validEntries: 0,
        entriesWithErrors: 1,
        entriesWithWarnings: 0,
        duplicateIds: [],
        duplicateKhmerWords: [],
        duplicateEnglishMeanings: [],
        missingFieldCount: 0,
        unverifiedSpellingCount: 0,
        unverifiedMeaningCount: 0,
        unverifiedSyllableCount: 0,
        unverifiedExampleCount: 0,
        entriesRequiringNativeReview: [],
        issues: [
          ValidationIssue(
            severity: ValidationSeverity.error,
            code: 'ERR_JSON_EMPTY',
            entryIndex: -1,
            entryId: '<root>',
            field: 'root',
            message: 'Vocabulary JSON string is empty.',
          ),
        ],
      );
    }

    final dynamic decoded;
    try {
      decoded = jsonDecode(rawJson);
    } on FormatException catch (e) {
      return VocabularyValidationReport(
        totalEntries: 0,
        validEntries: 0,
        entriesWithErrors: 1,
        entriesWithWarnings: 0,
        duplicateIds: const [],
        duplicateKhmerWords: const [],
        duplicateEnglishMeanings: const [],
        missingFieldCount: 0,
        unverifiedSpellingCount: 0,
        unverifiedMeaningCount: 0,
        unverifiedSyllableCount: 0,
        unverifiedExampleCount: 0,
        entriesRequiringNativeReview: const [],
        issues: [
          ValidationIssue(
            severity: ValidationSeverity.error,
            code: 'ERR_JSON_SYNTAX',
            entryIndex: -1,
            entryId: '<root>',
            field: 'root',
            message: 'Malformed JSON syntax: ${e.message}',
          ),
        ],
      );
    }

    if (decoded is! List<dynamic>) {
      return const VocabularyValidationReport(
        totalEntries: 0,
        validEntries: 0,
        entriesWithErrors: 1,
        entriesWithWarnings: 0,
        duplicateIds: [],
        duplicateKhmerWords: [],
        duplicateEnglishMeanings: [],
        missingFieldCount: 0,
        unverifiedSpellingCount: 0,
        unverifiedMeaningCount: 0,
        unverifiedSyllableCount: 0,
        unverifiedExampleCount: 0,
        entriesRequiringNativeReview: [],
        issues: [
          ValidationIssue(
            severity: ValidationSeverity.error,
            code: 'ERR_JSON_ROOT_TYPE',
            entryIndex: -1,
            entryId: '<root>',
            field: 'root',
            message: 'Vocabulary JSON root must be an array.',
          ),
        ],
      );
    }

    return validateRecords(decoded);
  }

  /// Validates a list of raw decoded JSON vocabulary entries.
  VocabularyValidationReport validateRecords(List<dynamic> records) {
    final issues = <ValidationIssue>[];
    final seenIds = <String, int>{};
    final seenKhmer = <String, int>{};
    final seenEnglish = <String, int>{};

    final duplicateIds = <String>{};
    final duplicateKhmer = <String>{};
    final duplicateEnglish = <String>{};

    final errorEntryIndices = <int>{};
    final warningEntryIndices = <int>{};
    final reviewEntries = <String>[];

    var missingFieldCount = 0;
    var unverifiedSpellingCount = 0;
    var unverifiedMeaningCount = 0;
    var unverifiedSyllableCount = 0;
    var unverifiedExampleCount = 0;

    void addIssue(ValidationIssue issue) {
      issues.add(issue);
      if (issue.severity == ValidationSeverity.error) {
        errorEntryIndices.add(issue.entryIndex);
      } else {
        warningEntryIndices.add(issue.entryIndex);
      }
      if (issue.code.startsWith('ERR_MISSING_')) {
        missingFieldCount++;
      }
    }

    for (var i = 0; i < records.length; i++) {
      final raw = records[i];
      if (raw is! Map<String, dynamic>) {
        addIssue(
          ValidationIssue(
            severity: ValidationSeverity.error,
            code: 'ERR_ENTRY_TYPE',
            entryIndex: i,
            entryId: '<index_$i>',
            field: 'entry',
            message: 'Vocabulary entry at index $i must be a JSON object.',
          ),
        );
        continue;
      }

      final rawId = raw['id'];
      final entryId = (rawId is String && rawId.trim().isNotEmpty)
          ? rawId.trim()
          : '<index_$i>';

      // 1. ID validation & duplicate detection.
      if (rawId is! String || rawId.trim().isEmpty) {
        addIssue(
          ValidationIssue(
            severity: ValidationSeverity.error,
            code: 'ERR_MISSING_ID',
            entryIndex: i,
            entryId: entryId,
            field: 'id',
            message: 'Missing or empty required field "id".',
          ),
        );
      } else {
        if (rawId != rawId.trim()) {
          addIssue(
            ValidationIssue(
              severity: ValidationSeverity.warning,
              code: 'WARN_ID_WHITESPACE',
              entryIndex: i,
              entryId: entryId,
              field: 'id',
              message: 'Field "id" has leading or trailing whitespace.',
            ),
          );
        }
        if (seenIds.containsKey(entryId)) {
          duplicateIds.add(entryId);
          addIssue(
            ValidationIssue(
              severity: ValidationSeverity.error,
              code: 'ERR_DUPLICATE_ID',
              entryIndex: i,
              entryId: entryId,
              field: 'id',
              message:
                  'Duplicate id "$entryId" (first seen at index ${seenIds[entryId]}).',
            ),
          );
        } else {
          seenIds[entryId] = i;
        }
      }

      // 2. Khmer text validation & duplicate detection.
      final rawKhmer = raw['khmer'] ?? raw['khmerWord'];
      String? khmerText;
      if (rawKhmer is! String || rawKhmer.trim().isEmpty) {
        addIssue(
          ValidationIssue(
            severity: ValidationSeverity.error,
            code: 'ERR_MISSING_KHMER',
            entryIndex: i,
            entryId: entryId,
            field: 'khmer',
            message: 'Missing or empty required Khmer word.',
          ),
        );
      } else {
        khmerText = rawKhmer;
        if (rawKhmer != rawKhmer.trim()) {
          addIssue(
            ValidationIssue(
              severity: ValidationSeverity.warning,
              code: 'WARN_KHMER_WHITESPACE',
              entryIndex: i,
              entryId: entryId,
              field: 'khmer',
              message: 'Khmer word has leading or trailing whitespace.',
            ),
          );
        }
        if (_controlChars.hasMatch(rawKhmer)) {
          addIssue(
            ValidationIssue(
              severity: ValidationSeverity.error,
              code: 'ERR_CONTROL_CHARS',
              entryIndex: i,
              entryId: entryId,
              field: 'khmer',
              message: 'Khmer word contains unexpected control characters.',
            ),
          );
        }
        if (_invisibleChars.hasMatch(rawKhmer)) {
          addIssue(
            ValidationIssue(
              severity: ValidationSeverity.warning,
              code: 'WARN_INVISIBLE_CHARS',
              entryIndex: i,
              entryId: entryId,
              field: 'khmer',
              message: 'Khmer word contains invisible formatting characters.',
            ),
          );
        }
        if (!KhmerTextUtils.containsKhmer(rawKhmer)) {
          addIssue(
            ValidationIssue(
              severity: ValidationSeverity.error,
              code: 'ERR_NO_KHMER_UNICODE',
              entryIndex: i,
              entryId: entryId,
              field: 'khmer',
              message: 'Field "khmer" must contain Khmer Unicode characters.',
            ),
          );
        }

        final normalizedKhmer = rawKhmer.trim();
        if (seenKhmer.containsKey(normalizedKhmer)) {
          duplicateKhmer.add(normalizedKhmer);
          addIssue(
            ValidationIssue(
              severity: ValidationSeverity.warning,
              code: 'WARN_DUPLICATE_KHMER',
              entryIndex: i,
              entryId: entryId,
              field: 'khmer',
              message:
                  'Duplicate Khmer word "$normalizedKhmer" (first seen at index ${seenKhmer[normalizedKhmer]}).',
            ),
          );
        } else {
          seenKhmer[normalizedKhmer] = i;
        }
      }

      // 3. English meaning & duplicate warning.
      final rawEnglish = raw['english'] ?? raw['englishMeaning'];
      if (rawEnglish is! String || rawEnglish.trim().isEmpty) {
        addIssue(
          ValidationIssue(
            severity: ValidationSeverity.error,
            code: 'ERR_MISSING_ENGLISH',
            entryIndex: i,
            entryId: entryId,
            field: 'english',
            message: 'Missing or empty required field "english".',
          ),
        );
      } else {
        final normalizedEnglish = rawEnglish.trim().toLowerCase();
        if (seenEnglish.containsKey(normalizedEnglish)) {
          duplicateEnglish.add(rawEnglish.trim());
          addIssue(
            ValidationIssue(
              severity: ValidationSeverity.warning,
              code: 'WARN_DUPLICATE_ENGLISH',
              entryIndex: i,
              entryId: entryId,
              field: 'english',
              message:
                  'Duplicate English meaning "${rawEnglish.trim()}" (first seen at index ${seenEnglish[normalizedEnglish]}). Verify whether both entries are intended synonyms.',
            ),
          );
        } else {
          seenEnglish[normalizedEnglish] = i;
        }
      }

      // 4. Category, part of speech, difficulty.
      _validateEnumField(
        raw: raw,
        field: 'category',
        allowed: allowedCategories,
        missingCode: 'ERR_MISSING_CATEGORY',
        invalidCode: 'ERR_INVALID_CATEGORY',
        entryIndex: i,
        entryId: entryId,
        addIssue: addIssue,
      );
      _validateEnumField(
        raw: raw,
        field: 'part_of_speech',
        allowed: allowedPartsOfSpeech,
        missingCode: 'ERR_MISSING_POS',
        invalidCode: 'ERR_INVALID_POS',
        entryIndex: i,
        entryId: entryId,
        addIssue: addIssue,
      );
      _validateEnumField(
        raw: raw,
        field: 'difficulty',
        allowed: allowedDifficulties,
        missingCode: 'ERR_MISSING_DIFFICULTY',
        invalidCode: 'ERR_INVALID_DIFFICULTY',
        entryIndex: i,
        entryId: entryId,
        addIssue: addIssue,
      );

      // 5. Semantic definitions, hints, and examples.
      final defEn = raw['definition_en'];
      if (defEn is! String || defEn.trim().isEmpty) {
        addIssue(
          ValidationIssue(
            severity: ValidationSeverity.warning,
            code: 'WARN_MISSING_DEFINITION_EN',
            entryIndex: i,
            entryId: entryId,
            field: 'definition_en',
            message: 'Missing or empty "definition_en".',
          ),
        );
      }
      final defKm = raw['definition_km'];
      if (defKm is! String || defKm.trim().isEmpty) {
        addIssue(
          ValidationIssue(
            severity: ValidationSeverity.warning,
            code: 'WARN_MISSING_DEFINITION_KM',
            entryIndex: i,
            entryId: entryId,
            field: 'definition_km',
            message: 'Missing or empty "definition_km".',
          ),
        );
      }

      final hints = raw['hints'];
      if (hints is! Map<String, dynamic>) {
        addIssue(
          ValidationIssue(
            severity: ValidationSeverity.warning,
            code: 'WARN_MISSING_HINTS',
            entryIndex: i,
            entryId: entryId,
            field: 'hints',
            message: 'Missing structured "hints" object (easy/medium/strong).',
          ),
        );
      } else {
        for (final tier in const ['easy', 'medium', 'strong']) {
          final hintText = hints[tier];
          if (hintText is! String || hintText.trim().isEmpty) {
            addIssue(
              ValidationIssue(
                severity: ValidationSeverity.warning,
                code: 'WARN_EMPTY_HINT',
                entryIndex: i,
                entryId: entryId,
                field: 'hints.$tier',
                message: 'Missing or empty "$tier" hint.',
              ),
            );
          }
        }
      }

      final exampleKm = raw['example_km'];
      final exampleEn = raw['example_en'];
      if (exampleKm is! String ||
          exampleKm.trim().isEmpty ||
          exampleEn is! String ||
          exampleEn.trim().isEmpty) {
        addIssue(
          ValidationIssue(
            severity: ValidationSeverity.warning,
            code: 'WARN_MISSING_EXAMPLE',
            entryIndex: i,
            entryId: entryId,
            field: 'example_km',
            message: 'Missing "example_km" or "example_en".',
          ),
        );
      }

      // 6. Verification metadata.
      final verification = raw['verification'];
      var needsNativeReview = false;
      String? syllableStatus;

      if (verification is! Map<String, dynamic>) {
        needsNativeReview = true;
        unverifiedSpellingCount++;
        unverifiedMeaningCount++;
        unverifiedSyllableCount++;
        unverifiedExampleCount++;
        addIssue(
          ValidationIssue(
            severity: ValidationSeverity.error,
            code: 'ERR_MISSING_VERIFICATION',
            entryIndex: i,
            entryId: entryId,
            field: 'verification',
            message: 'Missing required "verification" status object.',
          ),
        );
      } else {
        for (final key in verificationKeys) {
          final status = verification[key];
          if (status is! String ||
              !allowedVerificationStatuses.contains(status)) {
            needsNativeReview = true;
            addIssue(
              ValidationIssue(
                severity: ValidationSeverity.error,
                code: 'ERR_INVALID_VERIFICATION',
                entryIndex: i,
                entryId: entryId,
                field: 'verification.$key',
                message: 'Invalid or missing verification status for "$key".',
              ),
            );
          } else if (status != 'verified') {
            needsNativeReview = true;
          }
        }

        if (verification['spelling'] != 'verified') {
          unverifiedSpellingCount++;
          addIssue(
            ValidationIssue(
              severity: ValidationSeverity.warning,
              code: 'WARN_UNVERIFIED_SPELLING',
              entryIndex: i,
              entryId: entryId,
              field: 'verification.spelling',
              message: 'Spelling is marked "${verification['spelling']}".',
            ),
          );
        }
        if (verification['meaning'] != 'verified') {
          unverifiedMeaningCount++;
          addIssue(
            ValidationIssue(
              severity: ValidationSeverity.warning,
              code: 'WARN_UNVERIFIED_MEANING',
              entryIndex: i,
              entryId: entryId,
              field: 'verification.meaning',
              message: 'Meaning is marked "${verification['meaning']}".',
            ),
          );
        }
        syllableStatus = verification['syllables'] as String?;
        if (syllableStatus != 'verified') {
          unverifiedSyllableCount++;
          addIssue(
            ValidationIssue(
              severity: ValidationSeverity.warning,
              code: 'WARN_UNVERIFIED_SYLLABLES',
              entryIndex: i,
              entryId: entryId,
              field: 'verification.syllables',
              message: 'Syllables are marked "$syllableStatus".',
            ),
          );
        }
        if (verification['example'] != 'verified') {
          unverifiedExampleCount++;
          addIssue(
            ValidationIssue(
              severity: ValidationSeverity.warning,
              code: 'WARN_UNVERIFIED_EXAMPLE',
              entryIndex: i,
              entryId: entryId,
              field: 'verification.example',
              message:
                  'Example sentence is marked "${verification['example']}".',
            ),
          );
        }
      }

      if (needsNativeReview) {
        reviewEntries.add(entryId);
      }

      // 7. Syllable segmentation validation.
      final hasSyllablesKey =
          raw.containsKey('verified_syllables') || raw.containsKey('syllables');
      final rawSyllables = raw.containsKey('verified_syllables')
          ? raw['verified_syllables']
          : raw['syllables'];

      if (!hasSyllablesKey) {
        addIssue(
          ValidationIssue(
            severity: ValidationSeverity.error,
            code: 'ERR_MISSING_SYLLABLES_FIELD',
            entryIndex: i,
            entryId: entryId,
            field: 'verified_syllables',
            message: 'Missing "verified_syllables" field.',
          ),
        );
      } else if (rawSyllables == null) {
        if (syllableStatus == 'verified') {
          addIssue(
            ValidationIssue(
              severity: ValidationSeverity.error,
              code: 'ERR_VERIFIED_SYLLABLES_NULL',
              entryIndex: i,
              entryId: entryId,
              field: 'verified_syllables',
              message:
                  'Syllables cannot be null when verification.syllables is "verified".',
            ),
          );
        }
      } else if (rawSyllables is! List<dynamic>) {
        addIssue(
          ValidationIssue(
            severity: ValidationSeverity.error,
            code: 'ERR_INVALID_SYLLABLES_TYPE',
            entryIndex: i,
            entryId: entryId,
            field: 'verified_syllables',
            message: '"verified_syllables" must be a list of strings or null.',
          ),
        );
      } else if (rawSyllables.isEmpty) {
        addIssue(
          ValidationIssue(
            severity: ValidationSeverity.error,
            code: 'ERR_EMPTY_SYLLABLES',
            entryIndex: i,
            entryId: entryId,
            field: 'verified_syllables',
            message: '"verified_syllables" must not be an empty list.',
          ),
        );
      } else {
        final segments = <String>[];
        var segmentError = false;
        for (final seg in rawSyllables) {
          if (seg is! String || seg.isEmpty) {
            segmentError = true;
            addIssue(
              ValidationIssue(
                severity: ValidationSeverity.error,
                code: 'ERR_INVALID_SYLLABLE_SEGMENT',
                entryIndex: i,
                entryId: entryId,
                field: 'verified_syllables',
                message: 'Syllable segments must be non-empty strings.',
              ),
            );
            break;
          }
          if (_leadingCombiningMark.hasMatch(seg)) {
            segmentError = true;
            addIssue(
              ValidationIssue(
                severity: ValidationSeverity.error,
                code: 'ERR_LEADING_COMBINING_MARK',
                entryIndex: i,
                entryId: entryId,
                field: 'verified_syllables',
                message:
                    'Syllable segment "$seg" starts with a combining mark or Coeng.',
              ),
            );
            break;
          }
          segments.add(seg);
        }

        if (!segmentError &&
            khmerText != null &&
            !KhmerTextUtils.hasValidSyllableSegments(khmerText, segments)) {
          addIssue(
            ValidationIssue(
              severity: ValidationSeverity.error,
              code: 'ERR_SYLLABLE_MISMATCH',
              entryIndex: i,
              entryId: entryId,
              field: 'verified_syllables',
              message:
                  'Joining verified_syllables $segments does not reconstruct "$khmerText".',
            ),
          );
        }
      }

      // 8. Sources check.
      final sources = raw['sources'];
      if (sources is! List<dynamic>) {
        addIssue(
          ValidationIssue(
            severity: ValidationSeverity.warning,
            code: 'WARN_MISSING_SOURCES',
            entryIndex: i,
            entryId: entryId,
            field: 'sources',
            message: 'Field "sources" should be a list of references.',
          ),
        );
      } else if (sources.isEmpty) {
        addIssue(
          ValidationIssue(
            severity: ValidationSeverity.warning,
            code: 'WARN_MISSING_SOURCES',
            entryIndex: i,
            entryId: entryId,
            field: 'sources',
            message: 'No reference source recorded for this entry.',
          ),
        );
      }
    }

    final totalEntries = records.length;
    final entriesWithErrors = errorEntryIndices.length;
    final validEntries = totalEntries - entriesWithErrors;

    return VocabularyValidationReport(
      totalEntries: totalEntries,
      validEntries: validEntries,
      entriesWithErrors: entriesWithErrors,
      entriesWithWarnings: warningEntryIndices.length,
      duplicateIds: duplicateIds.toList(growable: false),
      duplicateKhmerWords: duplicateKhmer.toList(growable: false),
      duplicateEnglishMeanings: duplicateEnglish.toList(growable: false),
      missingFieldCount: missingFieldCount,
      unverifiedSpellingCount: unverifiedSpellingCount,
      unverifiedMeaningCount: unverifiedMeaningCount,
      unverifiedSyllableCount: unverifiedSyllableCount,
      unverifiedExampleCount: unverifiedExampleCount,
      entriesRequiringNativeReview: reviewEntries,
      issues: List<ValidationIssue>.unmodifiable(issues),
    );
  }

  void _validateEnumField({
    required Map<String, dynamic> raw,
    required String field,
    required Set<String> allowed,
    required String missingCode,
    required String invalidCode,
    required int entryIndex,
    required String entryId,
    required void Function(ValidationIssue) addIssue,
  }) {
    final value = raw[field];
    if (value is! String || value.trim().isEmpty) {
      addIssue(
        ValidationIssue(
          severity: ValidationSeverity.error,
          code: missingCode,
          entryIndex: entryIndex,
          entryId: entryId,
          field: field,
          message: 'Missing or empty required field "$field".',
        ),
      );
      return;
    }

    if (!allowed.contains(value.trim())) {
      addIssue(
        ValidationIssue(
          severity: ValidationSeverity.error,
          code: invalidCode,
          entryIndex: entryIndex,
          entryId: entryId,
          field: field,
          message: 'Invalid "$field" value "$value".',
        ),
      );
    }
  }
}
