import '../models/puzzle_enums.dart';

/// Exception thrown when an incoming M1/M5 puzzle request is invalid.
class PuzzleRequestException implements Exception {
  const PuzzleRequestException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'PuzzleRequestException($code): $message';
}

/// Optional puzzle generation configuration supplied by M1/M5 level configs.
class PuzzleRequestConfig {
  const PuzzleRequestConfig({
    this.targetVocabularyId,
    this.requireVerifiedSyllables = true,
    this.requireImage = false,
    this.onlyVerifiedSpelling = false,
    this.onlyVerifiedMeaning = false,
  });

  final String? targetVocabularyId;
  final bool requireVerifiedSyllables;
  final bool requireImage;
  final bool onlyVerifiedSpelling;
  final bool onlyVerifiedMeaning;

  factory PuzzleRequestConfig.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PuzzleRequestConfig();
    }
    return PuzzleRequestConfig(
      targetVocabularyId: json['targetVocabularyId'] as String?,
      requireVerifiedSyllables:
          json['requireVerifiedSyllables'] as bool? ?? true,
      requireImage: json['requireImage'] as bool? ?? false,
      onlyVerifiedSpelling: json['onlyVerifiedSpelling'] as bool? ?? false,
      onlyVerifiedMeaning: json['onlyVerifiedMeaning'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (targetVocabularyId != null) 'targetVocabularyId': targetVocabularyId,
      'requireVerifiedSyllables': requireVerifiedSyllables,
      'requireImage': requireImage,
      'onlyVerifiedSpelling': onlyVerifiedSpelling,
      'onlyVerifiedMeaning': onlyVerifiedMeaning,
    };
  }
}

/// Standardized request contract sent by M1/M5 to M3 to generate a puzzle.
class PuzzleRequest {
  const PuzzleRequest({
    required this.levelId,
    required this.puzzleType,
    required this.difficulty,
    this.category,
    this.configuration = const PuzzleRequestConfig(),
  });

  /// Identifier of the M1 maze level or checkpoint requesting the puzzle.
  final String levelId;

  /// Requested M3 puzzle mode.
  final PuzzleType puzzleType;

  /// Requested difficulty tier.
  final PuzzleDifficulty difficulty;

  /// Optional vocabulary category filter (e.g. `animals`, `food`).
  final String? category;

  /// Optional generation flags and target overrides.
  final PuzzleRequestConfig configuration;

  /// Validates request invariants before invoking the puzzle engine.
  void validate() {
    if (levelId.trim().isEmpty) {
      throw const PuzzleRequestException(
        'INVALID_REQUEST',
        'PuzzleRequest.levelId must not be empty.',
      );
    }
  }

  /// Parses an M1/M5 JSON configuration object into a [PuzzleRequest].
  factory PuzzleRequest.fromJson(Map<String, dynamic> json) {
    final rawLevelId = json['levelId'];
    if (rawLevelId is! String || rawLevelId.trim().isEmpty) {
      throw const PuzzleRequestException(
        'INVALID_REQUEST',
        'Missing or empty "levelId".',
      );
    }

    final rawType = json['puzzleType'];
    if (rawType is! String || rawType.trim().isEmpty) {
      throw const PuzzleRequestException(
        'INVALID_REQUEST',
        'Missing or empty "puzzleType".',
      );
    }

    final puzzleType = _parsePuzzleType(rawType);

    final rawDifficulty = json['difficulty'];
    if (rawDifficulty is! String || rawDifficulty.trim().isEmpty) {
      throw const PuzzleRequestException(
        'INVALID_REQUEST',
        'Missing or empty "difficulty".',
      );
    }

    final PuzzleDifficulty difficulty;
    try {
      difficulty = PuzzleDifficulty.fromString(rawDifficulty);
    } on FormatException catch (e) {
      throw PuzzleRequestException('INVALID_REQUEST', e.message);
    }

    final rawCategory = json['category'];
    if (rawCategory != null && rawCategory is! String) {
      throw const PuzzleRequestException(
        'INVALID_REQUEST',
        '"category" must be a string when provided.',
      );
    }

    final rawConfig = json['configuration'];
    if (rawConfig != null && rawConfig is! Map<String, dynamic>) {
      throw const PuzzleRequestException(
        'INVALID_REQUEST',
        '"configuration" must be a JSON object when provided.',
      );
    }

    return PuzzleRequest(
      levelId: rawLevelId.trim(),
      puzzleType: puzzleType,
      difficulty: difficulty,
      category: (rawCategory as String?)?.trim(),
      configuration: PuzzleRequestConfig.fromJson(
        rawConfig as Map<String, dynamic>?,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'levelId': levelId,
      'puzzleType': puzzleType.name,
      'difficulty': difficulty.name,
      if (category != null && category!.isNotEmpty) 'category': category,
      'configuration': configuration.toJson(),
    };
  }

  static PuzzleType _parsePuzzleType(String raw) {
    return switch (raw.trim().toLowerCase()) {
      'picturematching' || 'picture_matching' => PuzzleType.pictureMatching,
      'wordmatching' || 'word_matching' => PuzzleType.wordMatching,
      'syllableordering' || 'syllable_ordering' => PuzzleType.syllableOrdering,
      _ => throw PuzzleRequestException(
        'UNSUPPORTED_PUZZLE_TYPE',
        'Unsupported puzzleType "$raw".',
      ),
    };
  }
}
