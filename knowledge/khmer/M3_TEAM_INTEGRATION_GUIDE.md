# M3 Team Integration Guide (Phase 8)

> **Module Ownership**: M3 owns `lib/features/khmer_puzzle/`, `assets/data/khmer_vocabulary.json`, `knowledge/khmer/`, and `test/features/khmer_puzzle/`. M1, M2, M4, and M5 modules do not yet exist in this repository and remain owned by their respective teammates.

---

## 1. Public Import

All external modules import only the M3 barrel file:

```dart
import 'package:tiger_kid_elephant/features/khmer_puzzle/khmer_puzzle.dart';
```

---

## 2. For M1 — Level Developer

M3 receives level puzzle requirements via `PuzzleRequest` (or raw JSON parsed by `PuzzleRequest.fromJson`).

### Level Checkpoint JSON Example

```json
{
  "levelId": "level_01_gate_a",
  "puzzleType": "syllable_ordering",
  "difficulty": "easy",
  "category": "animals",
  "configuration": {
    "targetVocabularyId": "animals_elephant_002",
    "requireVerifiedSyllables": true,
    "requireImage": false
  }
}
```

- **Accepted `puzzleType` strings**: `"picture_matching"` (`"pictureMatching"`), `"word_matching"` (`"wordMatching"`), `"syllable_ordering"` (`"syllableOrdering"`).
- **Accepted `difficulty` strings**: `"easy"`, `"medium"`, `"hard"`.
- **Optional `category`**: `"animals"`, `"family"`, `"food"`, `"nature"`, `"education"`, `"daily_life"`, etc.

---

## 3. For M4 — UI/UX & Animation Developer

M3 provides three self-contained puzzle widgets (`PictureMatchingWidget`, `WordMatchingWidget`, `SyllableOrderingWidget`) consuming `PuzzlePresentation` (`PuzzlePrompt`)—never exposing internal answer keys.

### Embedding M3 Widgets Inside M4 Screens

```dart
PictureMatchingWidget(
  puzzle: puzzle,
  isLoading: isLoading,
  errorMessage: errorMessage,
  onRetry: reloadPuzzle,
  onClose: closeOverlay,
  onOptionSelected: (PuzzleOption option) {
    // Optional sound/highlight hook
  },
  onHintRequested: (HintResponse hint) {
    // Optional hint animation/sound hook
  },
  onCompleted: (PuzzleResult result) {
    // Forward completion to M2/M5
  },
  imageBuilder: (context, imagePath) {
    // Optional M4 stone-tablet or parchment image frame
    return Image.asset(imagePath, fit: BoxFit.contain);
  },
)
```

- See [M3_UI_SPECIFICATION.md](file:///e:/Khmer-guessing-word/knowledge/khmer/M3_UI_SPECIFICATION.md) for visual states, `KhmerTextUtils.khmerTextStyle` (`height: 1.5`), and responsive breakpoints (`320px`–`1024px`).

---

## 4. For M5 — Integration & Mobile Developer (and M2 Gameplay)

### Option A: Screen-Level Navigation (`KhmerPuzzleScreen`)

```dart
KhmerPuzzleScreen(
  puzzleType: PuzzleType.syllableOrdering,
  difficulty: PuzzleDifficulty.easy,
  category: 'animals',
  repository: sharedRepository,
  onCompleted: (PuzzleResult result) {
    if (result.isSolved) {
      // M2: unlock maze route / resume kid movement
      // M5: save completion & unlock next level
    }
  },
)
```

### Option B: Adapter API (`PuzzleIntegrationAdapter`)

```dart
final adapter = PuzzleIntegrationAdapter(
  repository: KhmerPuzzleRepository(),
  scoreCalculator: (result) =>
      (100 - (result.attempts - 1) * 20 - result.hintsUsed * 10).clamp(10, 100),
);

final loadOutcome = await adapter.loadPuzzleFromJson(levelConfigJson);
if (!loadOutcome.isSuccess) {
  // Structured error: loadOutcome.error!.code & loadOutcome.error!.message
  return;
}

final puzzle = loadOutcome.puzzle!;
final hintSession = adapter.startHintSession(puzzle);
final hint = adapter.requestHint(hintSession);

final submission = adapter.submitAnswer(
  request: PuzzleRequest.fromJson(levelConfigJson),
  puzzle: puzzle,
  selectedSyllables: userOrder,
  attempts: 1,
  hintsUsed: hintSession.hintsUsed,
);

final PuzzleCompletionEvent? event = submission.completionEvent;
if (event != null) {
  // Persist event.toJson() in M5 storage and notify M2 maze door
}
```

### Option C: Multi-Question Session Engine (`GameSessionManager`)

Use `GameSessionManager` (`GameConfig`, `GameResult`, `GameScoreManager`, `LivesManager`) for standalone multi-round practice or 10-question mini-game sessions:

```dart
final session = GameSessionManager(repository: KhmerPuzzleRepository());
await session.startSession(
  const GameConfig(
    questionsPerSession: 10,
    initialLives: 3,
    difficulty: PuzzleDifficulty.easy,
    puzzleType: PuzzleType.pictureMatching,
  ),
);

session.beginPlaying();
final hint = session.requestHint(); // 0 life loss; -2 hint penalty applied once/question
final answerResult = session.submitAnswer(selectedOptionId: chosenOptionId);
final hasMore = await session.nextQuestion();

if (session.status == GameSessionStatus.completed ||
    session.status == GameSessionStatus.gameOver) {
  final GameResult summary = session.buildResult();
  // Persist summary.toJson() (totalScore, accuracyPercentage, starRating, maxStreak) in M5
}
```

### Structured Error Codes

- `INVALID_REQUEST` — Missing/invalid `levelId`, `difficulty`, or config types.
- `UNSUPPORTED_PUZZLE_TYPE` — Unknown `puzzleType` string.
- `VOCABULARY_LOAD_ERROR` — Malformed or empty JSON dataset.
- `INSUFFICIENT_VOCABULARY` — Not enough eligible/verified items for the requested category/difficulty/image constraints.
- `UNKNOWN_PUZZLE_ID` — Submitted against a puzzle with an empty ID.

---

## 5. Unresolved Questions Requiring Teammate Agreement

1. **M1 & M5 — Level Config Schema**: Confirm exact JSON key names (`levelId`, `puzzleType`, `difficulty`, `category`, `configuration`) in M1's maze level files.
2. **M2 & M5 — Scoring & Failure Rules**: Confirm whether M3 should compute `PuzzleCompletionEvent.score` / `GameResult.totalScore` using M3 defaults or defer scoring to M5, and confirm what happens in M2's tiger chase if `isCompleted && !isCorrect`.
3. **M4 — Khmer Font & Stone-Tile Theme**: Confirm the licensed Khmer font family to bundle in `pubspec.yaml` and whether M4 wants a `tileBuilder` hook on `SyllableOrderingWidget`.
4. **Linguistic Sign-Off**: Confirm native Khmer teacher review of `knowledge/khmer/examples/initial_vocabulary.json` and `verification.example` in `assets/data/khmer_vocabulary.json`.

---

## 6. Team Repository Upload & Merge Checklist

`lib/main.dart` remains untouched in this workspace so M3 merges cleanly alongside M1, M2, M4, and M5 without entry-point conflicts.

### M3-Owned Files to Copy / Commit

- `lib/features/khmer_puzzle/` — Full M3 module source (models, data loader, repository, generators, services, integration adapters, widgets, screens, and barrel `khmer_puzzle.dart`)
- `assets/data/khmer_vocabulary.json` — Playable 15-word dataset
- `assets/images/` — M3 vocabulary illustrations, characters, UI buttons/icons, backgrounds, levels, and rewards
- `knowledge/khmer/` — Linguistic references, vocabulary schema, QA reports, teacher checklist, and team docs
- `test/features/khmer_puzzle/` — Automated M3 test suite (`15` test files)
- `pubspec.yaml` — Merge only the `flutter.assets` entries when integrating into the shared team repository (do not overwrite teammates' dependencies or app metadata)

### Pre-Push Verification Commands

```bash
dart format .
flutter analyze
flutter test
```
