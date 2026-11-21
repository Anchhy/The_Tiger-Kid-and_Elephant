import '../models/puzzle.dart';
import '../models/puzzle_enums.dart';
import '../models/puzzle_result.dart';
import '../models/vocabulary_item.dart';
import '../utils/khmer_text_utils.dart';

/// Result returned when checking a player's puzzle submission.
class ValidationResult {
  const ValidationResult({
    required this.isCorrect,
    required this.feedbackMessage,
    this.educationalNote = '',
    this.isDuplicate = false,
    AnswerValidationStatus? status,
  }) : status =
           status ??
           (isCorrect
               ? AnswerValidationStatus.correct
               : AnswerValidationStatus.incorrect);

  final bool isCorrect;
  final String feedbackMessage;
  final String educationalNote;
  final bool isDuplicate;
  final AnswerValidationStatus status;
}

/// Shared answer validation service for all three Khmer puzzle modes.
class PuzzleValidationService {
  const PuzzleValidationService();

  /// Validates a player's submission against a generated [Puzzle] and returns
  /// a structured [PuzzleResult].
  PuzzleResult validateSubmission({
    required Puzzle puzzle,
    String? selectedOptionId,
    String? leftOptionId,
    String? rightOptionId,
    List<String>? selectedSyllables,
    Set<String> completedPairIds = const {},
    int attempts = 1,
    int hintsUsed = 0,
    bool alreadySolved = false,
  }) {
    if (puzzle.id.trim().isEmpty) {
      return PuzzleResult(
        puzzleId: puzzle.id,
        puzzleType: puzzle.type,
        difficulty: puzzle.difficulty,
        vocabularyId: puzzle.targetVocabulary.id,
        isSolved: false,
        attempts: attempts,
        hintsUsed: hintsUsed,
        feedbackMessage: 'Unknown puzzle ID.',
        validationStatus: AnswerValidationStatus.invalidInput,
      );
    }

    if (alreadySolved) {
      return PuzzleResult(
        puzzleId: puzzle.id,
        puzzleType: puzzle.type,
        difficulty: puzzle.difficulty,
        vocabularyId: puzzle.targetVocabulary.id,
        isSolved: false,
        attempts: attempts,
        hintsUsed: hintsUsed,
        feedbackMessage: 'This puzzle has already been solved.',
        educationalNote: puzzle.targetVocabulary.educationalNote,
        isDuplicate: true,
        validationStatus: AnswerValidationStatus.invalidInput,
      );
    }

    switch (puzzle.type) {
      case PuzzleType.pictureMatching:
        final check = _validatePictureOption(
          puzzle: puzzle,
          selectedOptionId: selectedOptionId ?? '',
          alreadySolved: alreadySolved,
        );
        return PuzzleResult(
          puzzleId: puzzle.id,
          puzzleType: puzzle.type,
          difficulty: puzzle.difficulty,
          vocabularyId: puzzle.targetVocabulary.id,
          isSolved: check.isCorrect,
          attempts: attempts,
          hintsUsed: hintsUsed,
          feedbackMessage: check.feedbackMessage,
          educationalNote: check.educationalNote,
          isDuplicate: check.isDuplicate,
          validationStatus: check.status,
        );

      case PuzzleType.wordMatching:
        final check = _validateWordPair(
          puzzle: puzzle,
          leftOptionId: leftOptionId ?? '',
          rightOptionId: rightOptionId ?? '',
          completedPairIds: completedPairIds,
        );
        final matchedItem =
            puzzle.answerKey.itemsByOptionId[leftOptionId ?? ''] ??
            puzzle.targetVocabulary;
        return PuzzleResult(
          puzzleId: puzzle.id,
          puzzleType: puzzle.type,
          difficulty: puzzle.difficulty,
          vocabularyId: matchedItem.id,
          isSolved: check.isCorrect,
          attempts: attempts,
          hintsUsed: hintsUsed,
          feedbackMessage: check.feedbackMessage,
          educationalNote: check.educationalNote,
          isDuplicate: check.isDuplicate,
          validationStatus: check.status,
        );

      case PuzzleType.syllableOrdering:
        final check = validateSyllableOrder(
          target: puzzle.targetVocabulary,
          selectedSyllables: selectedSyllables ?? const [],
          availableSyllables: puzzle.prompt.syllableChips,
        );
        return PuzzleResult(
          puzzleId: puzzle.id,
          puzzleType: puzzle.type,
          difficulty: puzzle.difficulty,
          vocabularyId: puzzle.targetVocabulary.id,
          isSolved: check.isCorrect,
          attempts: attempts,
          hintsUsed: hintsUsed,
          feedbackMessage: check.feedbackMessage,
          educationalNote: check.educationalNote,
          isDuplicate: check.isDuplicate,
          validationStatus: check.status,
        );
    }
  }

  ValidationResult _validatePictureOption({
    required Puzzle puzzle,
    required String selectedOptionId,
    required bool alreadySolved,
  }) {
    if (alreadySolved) {
      return ValidationResult(
        isCorrect: false,
        isDuplicate: true,
        status: AnswerValidationStatus.invalidInput,
        feedbackMessage: 'This puzzle has already been solved.',
        educationalNote: puzzle.targetVocabulary.educationalNote,
      );
    }

    final normalizedId = selectedOptionId.trim();
    if (normalizedId.isEmpty) {
      return const ValidationResult(
        isCorrect: false,
        status: AnswerValidationStatus.invalidInput,
        feedbackMessage: 'Please select an answer first.',
      );
    }

    final validIds = puzzle.prompt.options.map((o) => o.id).toSet();
    if (!validIds.contains(normalizedId)) {
      return const ValidationResult(
        isCorrect: false,
        status: AnswerValidationStatus.invalidInput,
        feedbackMessage: 'Selected option is not valid for this question.',
      );
    }

    if (normalizedId == puzzle.answerKey.correctOptionId) {
      final target = puzzle.targetVocabulary;
      return ValidationResult(
        isCorrect: true,
        feedbackMessage:
            'Correct! ${target.khmerWord} means ${target.englishMeaning}.',
        educationalNote: target.educationalNote,
      );
    }

    return const ValidationResult(
      isCorrect: false,
      feedbackMessage: 'Not quite right. Try another choice!',
    );
  }

  ValidationResult _validateWordPair({
    required Puzzle puzzle,
    required String leftOptionId,
    required String rightOptionId,
    required Set<String> completedPairIds,
  }) {
    final leftId = leftOptionId.trim();
    final rightId = rightOptionId.trim();

    if (leftId.isEmpty || rightId.isEmpty) {
      return const ValidationResult(
        isCorrect: false,
        status: AnswerValidationStatus.invalidInput,
        feedbackMessage: 'Select one Khmer word and one meaning to match.',
      );
    }

    final validLeftIds = puzzle.prompt.options.map((o) => o.id).toSet();
    final validRightIds = puzzle.prompt.rightOptions.map((o) => o.id).toSet();
    if (!validLeftIds.contains(leftId) || !validRightIds.contains(rightId)) {
      return const ValidationResult(
        isCorrect: false,
        status: AnswerValidationStatus.invalidInput,
        feedbackMessage: 'Selected pair is not part of this round.',
      );
    }

    if (completedPairIds.contains(leftId) ||
        completedPairIds.contains(rightId)) {
      return const ValidationResult(
        isCorrect: false,
        isDuplicate: true,
        status: AnswerValidationStatus.invalidInput,
        feedbackMessage: 'This pair has already been matched.',
      );
    }

    if (puzzle.answerKey.expectedPairs[leftId] == rightId) {
      final matched = puzzle.answerKey.itemsByOptionId[leftId]!;
      return ValidationResult(
        isCorrect: true,
        feedbackMessage:
            'Matched! ${matched.khmerWord} means ${matched.englishMeaning}.',
        educationalNote: matched.educationalNote,
      );
    }

    return const ValidationResult(
      isCorrect: false,
      feedbackMessage: 'Those do not match. Please try again!',
    );
  }

  /// Validates a direct vocabulary-ID selection for Picture Matching.
  ValidationResult validateSelection({
    required VocabularyItem target,
    required String selectedVocabularyId,
    Set<String>? availableOptionIds,
    bool alreadySolved = false,
  }) {
    if (alreadySolved) {
      return ValidationResult(
        isCorrect: false,
        isDuplicate: true,
        feedbackMessage: 'This puzzle has already been solved.',
        educationalNote: target.educationalNote,
      );
    }

    final normalizedId = selectedVocabularyId.trim();
    if (normalizedId.isEmpty) {
      return const ValidationResult(
        isCorrect: false,
        feedbackMessage: 'Please select an answer first.',
      );
    }

    if (availableOptionIds != null &&
        !availableOptionIds.contains(normalizedId)) {
      return const ValidationResult(
        isCorrect: false,
        feedbackMessage: 'Selected option is not valid for this question.',
      );
    }

    if (normalizedId == target.id) {
      return ValidationResult(
        isCorrect: true,
        feedbackMessage:
            'Correct! ${target.khmerWord} means ${target.englishMeaning}.',
        educationalNote: target.educationalNote,
      );
    }

    return const ValidationResult(
      isCorrect: false,
      feedbackMessage: 'Not quite right. Try another choice!',
    );
  }

  /// Validates a direct vocabulary-ID pair for Word Matching.
  ValidationResult validatePair({
    required String leftVocabularyId,
    required String rightVocabularyId,
    required Map<String, VocabularyItem> vocabularyById,
    Set<String> completedPairIds = const {},
    Set<String>? availableIds,
  }) {
    final leftId = leftVocabularyId.trim();
    final rightId = rightVocabularyId.trim();

    if (leftId.isEmpty || rightId.isEmpty) {
      return const ValidationResult(
        isCorrect: false,
        feedbackMessage: 'Select one Khmer word and one meaning to match.',
      );
    }

    if (availableIds != null &&
        (!availableIds.contains(leftId) || !availableIds.contains(rightId))) {
      return const ValidationResult(
        isCorrect: false,
        feedbackMessage: 'Selected pair is not part of this round.',
      );
    }

    if (!vocabularyById.containsKey(leftId) ||
        !vocabularyById.containsKey(rightId)) {
      return const ValidationResult(
        isCorrect: false,
        feedbackMessage: 'Selected vocabulary item could not be found.',
      );
    }

    if (completedPairIds.contains(leftId) ||
        completedPairIds.contains(rightId)) {
      return const ValidationResult(
        isCorrect: false,
        isDuplicate: true,
        feedbackMessage: 'This pair has already been matched.',
      );
    }

    if (leftId == rightId) {
      final matched = vocabularyById[leftId]!;
      return ValidationResult(
        isCorrect: true,
        feedbackMessage:
            'Matched! ${matched.khmerWord} means ${matched.englishMeaning}.',
        educationalNote: matched.educationalNote,
      );
    }

    return const ValidationResult(
      isCorrect: false,
      feedbackMessage: 'Those do not match. Please try again!',
    );
  }

  /// Validates an English/Khmer text meaning submission against [target]'s
  /// verified [VocabularyItem.allAcceptedMeanings] and Khmer Unicode spelling.
  ValidationResult validateMeaningText({
    required VocabularyItem target,
    required String submittedMeaning,
    bool alreadySolved = false,
  }) {
    if (alreadySolved) {
      return ValidationResult(
        isCorrect: false,
        isDuplicate: true,
        status: AnswerValidationStatus.invalidInput,
        feedbackMessage: 'This puzzle has already been solved.',
        educationalNote: target.educationalNote,
      );
    }

    final normalized = KhmerTextUtils.normalizeKhmerText(submittedMeaning);
    if (normalized.isEmpty) {
      return const ValidationResult(
        isCorrect: false,
        status: AnswerValidationStatus.invalidInput,
        feedbackMessage: 'Please enter or select a meaning first.',
      );
    }

    if (KhmerTextUtils.matchesAcceptedAnswer(normalized, target)) {
      return ValidationResult(
        isCorrect: true,
        status: AnswerValidationStatus.correct,
        feedbackMessage:
            'Correct! ${target.khmerWord} means ${target.englishMeaning}.',
        educationalNote: target.educationalNote,
      );
    }

    return const ValidationResult(
      isCorrect: false,
      status: AnswerValidationStatus.incorrect,
      feedbackMessage: 'Those do not match. Please try again!',
    );
  }

  /// Validates an ordered list of Khmer syllables against [target].
  ValidationResult validateSyllableOrder({
    required VocabularyItem target,
    required List<String> selectedSyllables,
    List<String>? availableSyllables,
  }) {
    if (selectedSyllables.isEmpty) {
      return const ValidationResult(
        isCorrect: false,
        status: AnswerValidationStatus.invalidInput,
        feedbackMessage: 'Please select syllables to build the Khmer word.',
      );
    }

    if (selectedSyllables.any((segment) => segment.isEmpty)) {
      return const ValidationResult(
        isCorrect: false,
        status: AnswerValidationStatus.invalidInput,
        feedbackMessage: 'Empty syllable segments are not allowed.',
      );
    }

    final pool = availableSyllables ?? target.syllables;
    if (!_usesValidSegmentCounts(selectedSyllables, pool)) {
      return const ValidationResult(
        isCorrect: false,
        isDuplicate: true,
        status: AnswerValidationStatus.invalidInput,
        feedbackMessage:
            'Only available syllable segments may be used once each.',
      );
    }

    if (selectedSyllables.length < target.syllables.length) {
      return ValidationResult(
        isCorrect: false,
        status: AnswerValidationStatus.invalidInput,
        feedbackMessage:
            'Incomplete word: select all ${target.syllables.length} syllables.',
      );
    }

    if (selectedSyllables.length != target.syllables.length) {
      return const ValidationResult(
        isCorrect: false,
        status: AnswerValidationStatus.invalidInput,
        feedbackMessage: 'Syllable count does not match the target word.',
      );
    }

    final assembledWord = selectedSyllables.join();
    final exactSegmentMatch = _listsEqual(selectedSyllables, target.syllables);

    if (exactSegmentMatch && assembledWord == target.khmerWord) {
      return ValidationResult(
        isCorrect: true,
        feedbackMessage:
            'Well done! ${target.khmerWord} (${target.englishMeaning}).',
        educationalNote: target.educationalNote,
      );
    }

    return const ValidationResult(
      isCorrect: false,
      feedbackMessage: 'Incorrect syllable order. Try rearranging them!',
    );
  }

  bool _usesValidSegmentCounts(List<String> selected, List<String> available) {
    final remaining = <String, int>{};
    for (final segment in available) {
      remaining[segment] = (remaining[segment] ?? 0) + 1;
    }
    for (final segment in selected) {
      final count = remaining[segment] ?? 0;
      if (count <= 0) {
        return false;
      }
      remaining[segment] = count - 1;
    }
    return true;
  }

  bool _listsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}
