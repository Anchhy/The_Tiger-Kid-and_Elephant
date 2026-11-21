import '../models/puzzle_enums.dart';
import '../models/vocabulary_item.dart';
import 'puzzle_difficulty_service.dart';

/// Result returned when requesting a progressive puzzle hint.
class HintResponse {
  const HintResponse({
    required this.text,
    required this.hintsUsed,
    required this.maxHints,
    required this.hasHint,
  });

  final String text;
  final int hintsUsed;
  final int maxHints;
  final bool hasHint;

  int get remainingHints => (maxHints - hintsUsed).clamp(0, maxHints);
  bool get hasMoreHints => remainingHints > 0;
}

/// Stateful per-puzzle tracker preventing repeated hints and enforcing caps.
class HintSession {
  HintSession({
    required this.target,
    required this.puzzleType,
    required this.difficulty,
    PuzzleHintService? hintService,
  }) : _hintService = hintService ?? const PuzzleHintService();

  final VocabularyItem target;
  final PuzzleType puzzleType;
  final PuzzleDifficulty difficulty;
  final PuzzleHintService _hintService;

  final List<String> _deliveredHints = [];
  int _nextCandidateIndex = 0;

  int get hintsUsed => _deliveredHints.length;
  List<String> get deliveredHints => List<String>.unmodifiable(_deliveredHints);

  /// Requests the next non-repeating hint for this session.
  HintResponse requestNextHint() {
    final maxHints = _hintService.maxHintsFor(difficulty);
    if (_deliveredHints.length >= maxHints) {
      return HintResponse(
        text: 'No more hints available for this difficulty level.',
        hintsUsed: _deliveredHints.length,
        maxHints: maxHints,
        hasHint: false,
      );
    }

    // Advance past any candidate text already shown so hints never repeat.
    while (_nextCandidateIndex < 6) {
      final candidate = _hintService.getHint(
        target: target,
        puzzleType: puzzleType,
        difficulty: difficulty,
        hintIndex: _nextCandidateIndex,
      );
      _nextCandidateIndex++;

      if (candidate.isNotEmpty &&
          !candidate.startsWith('No more hints') &&
          !_deliveredHints.contains(candidate)) {
        _deliveredHints.add(candidate);
        return HintResponse(
          text: candidate,
          hintsUsed: _deliveredHints.length,
          maxHints: maxHints,
          hasHint: true,
        );
      }
    }

    return HintResponse(
      text: 'No additional hints are available for this word.',
      hintsUsed: _deliveredHints.length,
      maxHints: maxHints,
      hasHint: false,
    );
  }
}

/// Shared progressive hint service for all three Khmer puzzle modes.
class PuzzleHintService {
  const PuzzleHintService({PuzzleDifficultyService? difficultyService})
    : _difficultyService = difficultyService ?? const PuzzleDifficultyService();

  final PuzzleDifficultyService _difficultyService;

  /// Returns the configured hint cap for [difficulty].
  int maxHintsFor(PuzzleDifficulty difficulty) {
    return _difficultyService.getSettings(difficulty).maxHints;
  }

  /// Creates a stateful [HintSession] that tracks usage and prevents repeats.
  HintSession startSession({
    required VocabularyItem target,
    required PuzzleType puzzleType,
    required PuzzleDifficulty difficulty,
  }) {
    return HintSession(
      target: target,
      puzzleType: puzzleType,
      difficulty: difficulty,
      hintService: this,
    );
  }

  /// Generates an educational hint for [target] at zero-based [hintIndex].
  ///
  /// Never reveals the full answer directly unless a dataset clue explicitly
  /// contains non-spoiler structural guidance.
  String getHint({
    required VocabularyItem target,
    required PuzzleType puzzleType,
    PuzzleDifficulty difficulty = PuzzleDifficulty.easy,
    int hintIndex = 0,
  }) {
    final settings = _difficultyService.getSettings(difficulty);
    if (hintIndex < 0 || hintIndex >= settings.maxHints) {
      return 'No more hints available for this difficulty level.';
    }

    return switch (puzzleType) {
      PuzzleType.pictureMatching => _pictureMatchingHint(
        target: target,
        allowDirectClue: settings.allowDirectClue,
        hintIndex: hintIndex,
      ),
      PuzzleType.wordMatching => _wordMatchingHint(
        target: target,
        allowDirectClue: settings.allowDirectClue,
        hintIndex: hintIndex,
      ),
      PuzzleType.syllableOrdering => _syllableOrderingHint(
        target: target,
        allowDirectClue: settings.allowDirectClue,
        hintIndex: hintIndex,
      ),
    };
  }

  String _pickStructuredClue(VocabularyItem target, int hintIndex) {
    final structured = target.hints.orderedHints;
    if (hintIndex < structured.length) {
      return structured[hintIndex];
    }
    if (hintIndex == 0 && target.hint.isNotEmpty) {
      return target.hint;
    }
    return '';
  }

  String _pictureMatchingHint({
    required VocabularyItem target,
    required bool allowDirectClue,
    required int hintIndex,
  }) {
    if (hintIndex == 0 && !allowDirectClue) {
      final syllableCount = target.syllables.length;
      if (syllableCount > 0) {
        return 'This Khmer word has $syllableCount syllable(s).';
      }
      return target.category.isNotEmpty
          ? 'Category: ${target.category}.'
          : 'Look closely at the picture details.';
    }

    final clue = _pickStructuredClue(target, hintIndex);
    if (clue.isNotEmpty && !clue.contains(target.khmerWord)) {
      return clue;
    }

    if (hintIndex == 0 && target.category.isNotEmpty) {
      return 'Category: ${target.category}.';
    }
    if (hintIndex == 1) {
      return 'Meaning clue: ${target.englishMeaning}.';
    }
    return 'Look closely for the picture showing "${target.englishMeaning}".';
  }

  String _wordMatchingHint({
    required VocabularyItem target,
    required bool allowDirectClue,
    required int hintIndex,
  }) {
    if (hintIndex == 0 && !allowDirectClue) {
      final syllableCount = target.syllables.length;
      return syllableCount > 0
          ? '"${target.englishMeaning}" matches a word with $syllableCount syllable(s).'
          : 'Look at the meaning of "${target.englishMeaning}".';
    }

    final clue = _pickStructuredClue(target, hintIndex);
    if (clue.isNotEmpty && !clue.contains(target.khmerWord)) {
      return '${target.englishMeaning}: $clue';
    }

    if (hintIndex == 1 && target.syllables.length > 1) {
      return '"${target.englishMeaning}" starts with the syllable '
          '"${target.syllables.first}".';
    }
    return target.educationalNote.isNotEmpty &&
            !target.educationalNote.contains(target.khmerWord)
        ? target.educationalNote
        : '"${target.englishMeaning}" belongs to ${target.category.isNotEmpty ? target.category : 'this vocabulary set'}.';
  }

  String _syllableOrderingHint({
    required VocabularyItem target,
    required bool allowDirectClue,
    required int hintIndex,
  }) {
    final syllableCount = target.syllables.length;
    if (hintIndex == 0 && !allowDirectClue) {
      return 'Meaning: ${target.englishMeaning} ($syllableCount syllables).';
    }

    if (hintIndex == 0) {
      final clue = _pickStructuredClue(target, 0);
      final suffix = clue.isNotEmpty && !clue.contains(target.khmerWord)
          ? ' — $clue'
          : '';
      return 'Meaning: ${target.englishMeaning}$suffix';
    }
    if (hintIndex == 1 && target.syllables.isNotEmpty) {
      return 'The first syllable is "${target.syllables.first}".';
    }
    if (syllableCount >= 3) {
      return 'The word has $syllableCount syllables and ends with '
          '"${target.syllables.last}".';
    }
    final strongClue = _pickStructuredClue(target, 2);
    if (strongClue.isNotEmpty && !strongClue.contains(target.khmerWord)) {
      return strongClue;
    }
    return 'This word has $syllableCount syllables meaning "${target.englishMeaning}".';
  }
}
