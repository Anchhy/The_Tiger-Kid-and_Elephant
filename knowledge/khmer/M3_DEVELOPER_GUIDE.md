# M3 Developer Guide — Khmer Puzzle Module

Welcome! This guide explains how the **M3 Khmer Puzzle** module works in *The Tiger, Kid, and Elephant* so any teammate or student developer can maintain and extend it safely.

---

## 1. Architecture Overview

M3 is built in plain **Flutter + Dart** (no Flame dependency, no extra third-party packages). It separates:
1. **Data** (`data/`, `repositories/`): Loads and filters Khmer vocabulary JSON.
2. **Engine / Logic** (`models/`, `generators/`, `services/`): Generates puzzles, validates answers, tracks hints, and applies difficulty rules.
3. **UI** (`widgets/`, `screens/`): Displays UI-safe `PuzzlePrompt` data without ever seeing correct answers directly.
4. **Integration** (`integration/`): Standardizes requests (`PuzzleRequest`) and completion events (`PuzzleCompletionEvent`) for M1, M4, and M5.

---

## 2. Folder Structure

```text
lib/features/khmer_puzzle/
  khmer_puzzle.dart              # Public barrel export (import this file!)
  models/                        # VocabularyItem, Puzzle, PuzzleResult, enums
  data/                          # KhmerVocabularyLoader (JSON asset reading)
  repositories/                  # KhmerPuzzleRepository (caching + filtering)
  generators/                    # PictureMatching, WordMatching, SyllableOrdering
  services/                      # PuzzleGenerator, Validation, Hint, Difficulty
  widgets/                       # Reusable puzzle widgets & state views
  screens/                       # KhmerPuzzleScreen & PuzzlePreviewScreen
  integration/                   # PuzzleRequest, CompletionEvent, Adapter
  utils/                         # KhmerTextUtils & VocabularyValidator
```

---

## 3. Important Classes

| Class | What It Does |
| --- | --- |
| `VocabularyItem` | Holds one Khmer word, verified syllables, English meaning, hints, difficulty, and verification flags. |
| `KhmerPuzzleRepository` | Loads JSON once, caches it, and filters by difficulty, category, image, or verification status. |
| `PuzzleGenerator` | Facade that creates a `Puzzle` for any `PuzzleType` and `PuzzleDifficulty`. |
| `Puzzle` / `PuzzlePrompt` | `PuzzlePrompt` is safe for UI display; `PuzzleAnswerKey` stays internal for validation. |
| `PuzzleValidationService` | Checks player answers (`validateSubmission`) and returns a `PuzzleResult`. |
| `PuzzleHintService` / `HintSession` | Gives progressive non-repeating hints capped by difficulty. |
| `PuzzleDifficultyService` | Controls option count, matching pairs, max attempts, and max hints for `easy`, `medium`, `hard`. |
| `PuzzleIntegrationAdapter` | Clean entry point for M1 JSON requests and M5 `PuzzleCompletionEvent` handling. |

---

## 4. Vocabulary Data Format

Every word in JSON follows `knowledge/khmer/VOCABULARY_SCHEMA.md`:

```json
{
  "id": "animals_elephant_002",
  "khmer": "ដំរី",
  "english": "Elephant",
  "definition_km": "សត្វធំមួយប្រភេទ ដែលមានប្រមោយវែង។",
  "definition_en": "A very large land animal with a long trunk.",
  "part_of_speech": "noun",
  "category": "animals",
  "verified_syllables": ["ដំ", "រី"],
  "example_km": "ដំរីមានប្រមោយវែង។",
  "example_en": "The elephant has a long trunk.",
  "hints": {
    "easy": "It is a very big animal.",
    "medium": "It has a long trunk and big ears.",
    "strong": "This 2-syllable word starts with ដំ."
  },
  "difficulty": "easy",
  "image": "assets/images/vocabulary/elephant.png",
  "verification": {
    "spelling": "verified",
    "meaning": "verified",
    "syllables": "needs_review",
    "example": "needs_review"
  },
  "sources": ["Wiktionary: ដំរី"]
}
```

---

## 5. How to Add a New Vocabulary Entry

1. Check the Khmer spelling in Chuon Nath / RAC references.
2. Split `verified_syllables` **only** at valid orthographic syllable boundaries—**never** split across a subscript (`្`, `U+17D2`) like `ទន្លេ`, and **never** use `.split('')`.
3. Set `verification` flags honestly (`"needs_review"` until a native Khmer teacher checks them).
4. Add the image path (if used for Picture Matching) under `assets/images/vocabulary/`.
5. Run the dataset tests to verify JSON syntax, unique IDs, Khmer Unicode, and syllable joining (`syllables.join() == khmer`).

---

## 6. How to Add a New Puzzle Type

1. Add a new value to `PuzzleType` in `models/puzzle_enums.dart`.
2. Create a new generator in `generators/` that outputs a `Puzzle` (`PuzzlePrompt` + `PuzzleAnswerKey`) using `sanitizeVocabularyPool`.
3. Add the new case in `services/puzzle_generator.dart` and `services/puzzle_validation_service.dart`.
4. Build the widget in `widgets/` (reading only `puzzle.prompt`) and add it to `screens/khmer_puzzle_screen.dart`.
5. Export the new files in `khmer_puzzle.dart` and add unit + widget tests.

---

## 7. How to Use Generators, Widgets & Run Tests

### Using the Puzzle Generator (Dart)
```dart
final repo = KhmerPuzzleRepository();
final generator = PuzzleGenerator(repository: repo);

final puzzle = await generator.generate(
  type: PuzzleType.pictureMatching,
  difficulty: PuzzleDifficulty.easy,
);
```

### Using Puzzle Widgets (Flutter UI)
```dart
KhmerPuzzleScreen(
  puzzleType: PuzzleType.wordMatching,
  difficulty: PuzzleDifficulty.medium,
  onCompleted: (PuzzleResult result) {
    // result.isSolved -> true or false
  },
)
```

### Running Formatting, Analysis, and Tests
```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

---

## 8. Common Errors and Solutions

| Error | Cause | Solution |
| --- | --- | --- |
| `PuzzleGenerationException: Insufficient distinct choices...` | Too few unique items or missing images in the selected difficulty/category. | Add more verified items or set `requireImage: false` during early testing. |
| `PuzzleGenerationException: ... verified syllables` | `SyllableOrderingGenerator` ran with `requireVerifiedSyllables: true` on unverified data. | Have a native Khmer teacher verify `syllables` (`"verified"`), or pass `requireVerifiedSyllables: false` in `PuzzlePreviewScreen` only. |
| `FormatException: ... syllables do not match` | `verified_syllables.join()` does not equal `khmer` (or leading/trailing whitespace). | Fix the syllable array or exact UTF-8 string in JSON. |
| `Image unavailable` displayed in UI | PNG asset file has not been added to `assets/images/vocabulary/` yet. | Place the matching `.png` file in `assets/images/vocabulary/` and run `flutter pub get`. |
