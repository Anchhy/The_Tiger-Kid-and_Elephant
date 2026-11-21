# M3 Khmer Puzzle Module — Integration Contract (Phase 5)

> **Module Import**:
> ```dart
> import 'package:tiger_kid_elephant/features/khmer_puzzle/khmer_puzzle.dart';
> ```
> M2 (Gameplay), M4 (UI/UX), and M5 (Integration/Navigation) interact only through this public barrel API and never need to parse raw JSON or access internal answer keys.

---

## 1. Loading Vocabulary

```dart
final repository = KhmerPuzzleRepository();
final allItems = await repository.getAllVocabulary();
final animals = await repository.getVocabularyByCategory('animals');
final item = await repository.findById('animals_elephant_002');
```

- Uses `KhmerVocabularyLoader` (defaults to `assets/data/khmer_vocabulary.json`; injectable `AssetBundle` / custom `assetPath` for tests or reviewed datasets).
- Supports configurable filtering via `VocabularyQuery` (`difficulty`, `category`, `onlyVerifiedSpelling`, `onlyVerifiedMeaning`, `onlyVerifiedSyllables`, `requireImage`, `requireMultiSyllable`).

---

## 2. Generating Puzzles

```dart
final generator = PuzzleGenerator(repository: repository);

final puzzle = await generator.generate(
  type: PuzzleType.pictureMatching, // or wordMatching / syllableOrdering
  difficulty: PuzzleDifficulty.easy,
  category: 'animals', // optional
);
```

- Returns a `Puzzle` containing:
  - `puzzle.prompt` (`PuzzlePrompt`) — UI-safe presentation object (contains **no** correct answer IDs).
  - `puzzle.targetVocabulary` (`VocabularyItem`) — Metadata used by services (`HintService`, `ValidationService`).
  - `puzzle.answerKey` (`PuzzleAnswerKey`) — Internal expected answer mapping consumed only by `PuzzleValidationService`.

---

## 3. Requesting Progressive Hints

```dart
const hintService = PuzzleHintService();
final hintSession = hintService.startSession(
  target: puzzle.targetVocabulary,
  puzzleType: puzzle.type,
  difficulty: puzzle.difficulty,
);

final hint = hintSession.requestNextHint();
// hint.text, hint.hintsUsed, hint.remainingHints, hint.hasHint
```

- Respects `DifficultySettings.maxHints` (`3` Easy, `2` Medium, `1` Hard).
- Prevents repeating previously shown hints in the same round.
- Handles missing dataset hints safely without spoiling the answer.

---

## 4. Submitting Answers

```dart
const validator = PuzzleValidationService();

// Picture Matching:
final result = validator.validateSubmission(
  puzzle: puzzle,
  selectedOptionId: chosenOption.id,
  attempts: attemptCount,
  hintsUsed: hintSession.hintsUsed,
);

// Word Matching:
final pairResult = validator.validateSubmission(
  puzzle: puzzle,
  leftOptionId: selectedLeft.id,
  rightOptionId: selectedRight.id,
  completedPairIds: matchedOptionIds,
);

// Syllable Ordering:
final orderResult = validator.validateSubmission(
  puzzle: puzzle,
  selectedSyllables: assembledSegments,
);
```

- Returns a structured `PuzzleResult`:
  - `isSolved` (`bool`)
  - `vocabularyId` (`String`)
  - `puzzleType` (`PuzzleType`)
  - `difficulty` (`PuzzleDifficulty`)
  - `attempts` / `hintsUsed` (`int`)
  - `feedbackMessage` / `educationalNote` (`String`)
  - `isDuplicate` (`bool`)

---

## 5. What M4 Needs to Display & How to Render Widgets

M4 UI components should read **only** from `puzzle.prompt` (`PuzzlePrompt`), `HintResponse`, and `PuzzleResult`:

- `prompt.instruction` — Short task heading
- `prompt.promptText` — Target meaning (Syllable Ordering) or prompt text
- `prompt.promptImagePath` — Vocabulary asset path (handle missing assets safely)
- `prompt.options` — List of `PuzzleOption(id, label, imagePath)` (Picture Matching choices or Word Matching left column)
- `prompt.rightOptions` — List of `PuzzleOption(id, label)` (Word Matching right column)
- `prompt.syllableChips` — Shuffled Khmer syllable strings (Syllable Ordering)
- `prompt.maxAttempts` & `prompt.maxHints` — HUD counters

### Rendering M3 Puzzle Widgets Directly (M4 / Custom Wrapper)

M4 can embed any M3 widget inside its own themed scaffold or dialog and receive callbacks without touching puzzle rules:

```dart
PictureMatchingWidget(
  puzzle: puzzle,
  isLoading: isLoading,
  errorMessage: errorMessage,
  onRetry: reloadPuzzle,
  onClose: closeOverlay,
  onOptionSelected: (PuzzleOption option) {},
  onHintRequested: (HintResponse hint) {},
  onCompleted: (PuzzleResult result) {},
  imageBuilder: (context, imagePath) => MyCustomArtworkFrame(path: imagePath),
)
```

Equivalent widget constructors exist for `WordMatchingWidget` (with `onPairMatched`) and `SyllableOrderingWidget`. See [M3_UI_SPECIFICATION.md](file:///e:/Khmer-guessing-word/knowledge/khmer/M3_UI_SPECIFICATION.md) for visual states, accessibility, and responsive rules.

---

## 6. Standardized Integration Adapter (M1 / M2 / M5)

For decoupled JSON level-config loading, structured error reporting, and terminal `PuzzleCompletionEvent` emission, callers can use `PuzzleIntegrationAdapter`:

- **`PuzzleRequest`**: `levelId`, `puzzleType`, `difficulty`, optional `category`, and `PuzzleRequestConfig` (`targetVocabularyId`, `requireVerifiedSyllables`, `requireImage`, `onlyVerifiedSpelling`, `onlyVerifiedMeaning`).
- **`PuzzlePresentation`**: Type alias for `PuzzlePrompt` (UI-safe data without answer keys).
- **`PuzzleCompletionEvent`**: `levelId`, `puzzleId`, `puzzleType`, `difficulty`, `vocabularyId`, `isCompleted`, `isCorrect`, `attempts`, `hintsUsed`, optional `score`, `feedbackMessage`, `educationalNote` (with `toJson()`).
- **`PuzzleIntegrationAdapter`**: `loadPuzzleFromJson`, `loadPuzzle`, `startHintSession`, `requestHint`, and `submitAnswer` returning `PuzzleLoadOutcome` / `PuzzleSubmissionOutcome` with structured `PuzzleIntegrationError` codes.

See [M3_TEAM_INTEGRATION_GUIDE.md](file:///e:/Khmer-guessing-word/knowledge/khmer/M3_TEAM_INTEGRATION_GUIDE.md) for M1/M4/M5 sample code and open teammate decisions.

## 7. What M5 (and M2) Needs for Screen Integration

- **Screen Entry Point (Widget Layer)**:
  ```dart
  KhmerPuzzleScreen(
    puzzleType: PuzzleType.syllableOrdering,
    difficulty: PuzzleDifficulty.medium,
    repository: repository, // optional shared instance
    onCompleted: (PuzzleResult result) {
      if (result.isSolved) {
        // M2: unlock maze door / resume kid movement
        // M5: persist progress & level score
      }
    },
  )
  ```
- **Direct Engine Access**: M5 can also inject `PuzzleGenerator`, `PuzzleHintService`, and `PuzzleValidationService` directly if wrapping puzzle state in a custom flow or test harness.
- **No Flame Coupling**: M3 exposes standard Dart classes and Flutter widgets only; M2/M5 control when to pause Flame gameplay and push/overlay `KhmerPuzzleScreen`.
