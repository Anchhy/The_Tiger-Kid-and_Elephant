import 'package:flutter/material.dart';

import '../models/vocabulary_item.dart';

/// Shared Khmer Unicode and syllable-integrity utilities.
class KhmerTextUtils {
  const KhmerTextUtils._();

  static final RegExp _khmerBlockPattern = RegExp(r'[\u1780-\u17FF]');
  static final RegExp _leadingCombiningMark = RegExp(r'^[\u17B4-\u17D3]');
  static final RegExp _whitespaceRuns = RegExp(r'\s+');

  /// Normalizes whitespace consistently while preserving all Khmer consonants,
  /// subscripts (`ជើងអក្សរ`), dependent vowels, and diacritics untouched.
  static String normalizeKhmerText(String input) {
    return input.trim().replaceAll(_whitespaceRuns, ' ');
  }

  /// Compares [submitted] cleanly against [target]'s Khmer word and verified
  /// accepted English/alternative meanings.
  static bool matchesAcceptedAnswer(String submitted, VocabularyItem target) {
    final normalized = normalizeKhmerText(submitted);
    if (normalized.isEmpty) {
      return false;
    }
    if (normalized == normalizeKhmerText(target.khmerWord)) {
      return true;
    }
    final lower = normalized.toLowerCase();
    for (final meaning in target.allAcceptedMeanings) {
      if (normalizeKhmerText(meaning).toLowerCase() == lower) {
        return true;
      }
    }
    return false;
  }

  /// Ensures sufficient vertical line height for stacked Khmer subscripts
  /// (`ជើងអក្សរ`) and superscript diacritics.
  static TextStyle khmerTextStyle([TextStyle? base]) {
    return (base ?? const TextStyle()).copyWith(
      height: 1.5,
      leadingDistribution: TextLeadingDistribution.even,
    );
  }

  /// Returns `true` if [text] contains at least one Khmer Unicode character.
  static bool containsKhmer(String text) {
    return _khmerBlockPattern.hasMatch(text);
  }

  /// Verifies that [syllables] are non-empty, do not start with combining marks
  /// or Coeng (`U+17D2`), and concatenate to [khmerWord].
  static bool hasValidSyllableSegments(
    String khmerWord,
    List<String> syllables,
  ) {
    if (khmerWord.isEmpty || syllables.isEmpty) {
      return false;
    }
    if (syllables.any(
      (segment) => segment.isEmpty || _leadingCombiningMark.hasMatch(segment),
    )) {
      return false;
    }
    return syllables.join() == khmerWord;
  }
}
