# M3 Khmer Puzzle Engine — QA & Refinement Report (Phase 6)

- **SDK**: Flutter 3.44.0 (stable) / Dart 3.12.0
- **Scope**: M3 puzzle engine testing, edge-case hardening, and regression verification (`lib/features/khmer_puzzle/`). No UI screens or M1/M2/M4/M5 modules were modified.

---

## 1. Initial Audit & Baseline Quality Checks

Before Phase 6 edits:
- `dart format --output=none --set-exit-if-changed .` — Passed (`Formatted 33 files (0 changed) in 0.08 seconds.`).
- `flutter analyze` — Passed (`No issues found!`).
- `flutter test` — Passed (`+39: All tests passed!`).
- **Audit findings**:
  - `KhmerPuzzleRepository` caches JSON reads cleanly in memory (`_cachedItems`).
  - `PuzzlePrompt` separates UI presentation from `PuzzleAnswerKey` without exposing answer keys.
  - Five subtle edge-case bugs were identified through code inspection and edge-case testing (documented in Section 3 below).

---

## 2. Tests Executed

- **Existing suite (39 tests)** across:
  - `test/features/khmer_puzzle/models/vocabulary_item_test.dart`
  - `test/features/khmer_puzzle/khmer_puzzle_repository_test.dart`
  - `test/features/khmer_puzzle/vocabulary_dataset_test.dart`
  - `test/features/khmer_puzzle/vocabulary_validator_test.dart`
  - `test/features/khmer_puzzle/puzzle_services_test.dart`
  - `test/features/khmer_puzzle/generators/picture_matching_generator_test.dart`
  - `test/features/khmer_puzzle/generators/word_matching_generator_test.dart`
  - `test/features/khmer_puzzle/generators/syllable_ordering_generator_test.dart`
  - `test/features/khmer_puzzle/khmer_puzzle_screen_test.dart`
  - `test/widget_test.dart`
- **New Phase 6 QA suite (10 tests)** in [puzzle_engine_qa_test.dart](file:///e:/Khmer-guessing-word/test/features/khmer_puzzle/puzzle_engine_qa_test.dart):
  - 6 regression tests for bugs discovered during Phase 6 audit.
  - 3 edge-case & stress tests (empty/single pools, missing images, repeated syllable segments, visually similar combining marks `ប៉ា` vs. `ប៊ា`).
  - 1 seeded randomized property-based test (`Random(20261118)`) running **100 iterations × 3 difficulties × 3 puzzle types (900 generated puzzles)** verifying reference integrity, option uniqueness, single-solution matching, and multiset syllable preservation.
- **Total test count**: **49 tests executed, 49 passed, 0 failed**.

---

## 3. Bugs Discovered, Fixes Applied & Regression Tests

| # | Bug Discovered | Fix Applied | Regression Test |
| :-: | --- | --- | --- |
| 1 | **Word Matching hint answer leak**: `_wordMatchingHint` (`hintIndex == 1`) revealed `target.syllables.first` even on 1-syllable words (e.g., `"Tiger" starts with the syllable "ខ្លា"`), exposing the full answer. | Restricted syllable-prefix hints in [puzzle_hint_service.dart](file:///e:/Khmer-guessing-word/lib/features/khmer_puzzle/services/puzzle_hint_service.dart) to `target.syllables.length > 1`. | `Word Matching hint does not leak 1-syllable Khmer word` |
| 2 | **Syllable Ordering 2-syllable hint leak**: `_syllableOrderingHint` revealed the first syllable at `hintIndex == 1` and the last syllable at `hintIndex == 2`, exposing the entire 2-syllable word (e.g., `ដំ` + `រី`). | Restricted last-syllable hints in [puzzle_hint_service.dart](file:///e:/Khmer-guessing-word/lib/features/khmer_puzzle/services/puzzle_hint_service.dart) to `syllableCount >= 3`, falling back to non-spoiler strong clues/meaning for 2-syllable words. | `Syllable Ordering hints do not reveal full 2-syllable word` |
| 3 | **Repeated submission bypass**: `PuzzleValidationService.validateSubmission` checked `alreadySolved: true` only for Picture Matching, ignoring it for Word Matching and Syllable Ordering. | Moved `alreadySolved` handling to the top of `validateSubmission` in [puzzle_validation_service.dart](file:///e:/Khmer-guessing-word/lib/features/khmer_puzzle/services/puzzle_validation_service.dart). | `validateSubmission rejects repeated submissions when alreadySolved` |
| 4 | **Duplicate IDs & broken Coeng segments in direct pools**: Generators did not reject duplicate `id`s in an injected `vocabularyPool`, and `KhmerTextUtils.hasValidSyllableSegments` did not block segments starting with `U+17D2` (Coeng) on manually constructed `VocabularyItem`s. | Added shared `sanitizeVocabularyPool` in [puzzle.dart](file:///e:/Khmer-guessing-word/lib/features/khmer_puzzle/models/puzzle.dart) across all 3 generators, and added leading combining-mark detection to [khmer_text_utils.dart](file:///e:/Khmer-guessing-word/lib/features/khmer_puzzle/utils/khmer_text_utils.dart). | `generators reject duplicate vocabulary IDs in pool` & `rejects broken Coeng syllable splits even on direct VocabularyItem` |
| 5 | **Silent whitespace trimming on `khmer` during JSON parsing**: `VocabularyItem.fromJson` trimmed `khmer`, which could mask whitespace mismatches against `verified_syllables`. | Changed `khmer` extraction in [vocabulary_item.dart](file:///e:/Khmer-guessing-word/lib/features/khmer_puzzle/models/vocabulary_item.dart) to `_requireExactString` (preserves raw Khmer text without mutating). | `VocabularyItem.fromJson preserves exact Khmer without trimming` |

---

## 4. Analyzer, Formatter & Performance Observations

- **`dart format --output=none --set-exit-if-changed .`**: Exited `0` (`Formatted 34 files (0 changed) in 0.09 seconds.`).
- **`flutter analyze`**: Exited `0` (`No issues found! (ran in 1.3s)`).
- **`flutter test`**: Exited `0` (`00:01 +49: All tests passed!`).
- **Performance observations**:
  - `KhmerPuzzleRepository` loads and decodes JSON once and serves subsequent queries from an unmodifiable in-memory list.
  - Generating and validating 900 randomized puzzles across all 3 types and difficulties completed well within the ~1s test run with no unnecessary allocations or dependencies.
- **Environment note**: `dart`/`flutter` CLI commands required running outside the Windows sandbox (`BypassSandbox: true`) because sandboxed CLI invocations stalled without output.

---

## 5. Remaining Limitations & Integration Readiness

- **Remaining limitations**:
  - Puzzle UI screens (`PictureMatchingScreen`, `WordMatchingScreen`, `SyllableOrderingScreen`) are still placeholders until the UI implementation phase.
  - `assets/images/vocabulary/*.png` assets are not yet added.
  - Native Cambodian Khmer teacher review of [initial_vocabulary.json](file:///e:/Khmer-guessing-word/knowledge/khmer/examples/initial_vocabulary.json) is still pending before promoting all 50 entries to production.
- **Integration readiness**:
  - **Engine & Contract Ready**: [M3_INTEGRATION_CONTRACT.md](file:///e:/Khmer-guessing-word/knowledge/khmer/M3_INTEGRATION_CONTRACT.md) matches all implemented engine methods (`KhmerPuzzleRepository`, `PuzzleGenerator`, `PuzzleHintService`, `PuzzleValidationService`, `PuzzleResult`).
  - **UI Integration Pending**: M2/M5 screen-level navigation works against the `KhmerPuzzleScreen` stub today, with full interactive puzzle screens planned for the UI phase.
