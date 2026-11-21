# M3 Khmer Puzzle Logic and Algorithms

## 1. Overall Puzzle Workflow

All three M3 puzzle modes share a six-stage lifecycle managed by `PuzzleIntegrationAdapter` and `PuzzleSessionController`:

1. **Receive Puzzle Request**: Validate `PuzzleRequest(levelId, puzzleType, difficulty, category, configuration)`.
2. **Load Verified Khmer Vocabulary**: Query `KhmerPuzzleRepository` (`VocabularyRepository`) with difficulty, category, image, and verification filters.
3. **Generate Puzzle**: Run the mode-specific generator (`PictureMatchingGenerator`, `WordMatchingGenerator`, or `SyllableOrderingGenerator`), separating `PuzzlePrompt` (UI-safe) from `PuzzleAnswerKey` (internal).
4. **Display Puzzle UI**: Render `PuzzlePresentation` (`PuzzlePrompt`) in `PictureMatchingWidget`, `WordMatchingWidget`, or `SyllableOrderingWidget`.
5. **Validate Answer & State Transitions**: Check submissions through `PuzzleValidationService` (`AnswerValidator`) while enforcing `PuzzleGameState` transition guards.
6. **Complete Puzzle**: Calculate `ScoreCalculator` points, emit `PuzzleCompletionEvent` / `PuzzleResult`, and lock further submissions.

---

## 2. Game State Machine (`PuzzleGameState`)

```text
initial -> loading -> ready
ready -> answering -> correct -> completed
ready -> answering -> incorrect -> answering -> ... -> completed (maxAttempts exhausted)
loading -> error
```

- **Submission allowed only in**: `ready`, `incorrect`, or `correct` during multi-pair `wordMatching` when pairs remain.
- **Duplicate prevention**: Repeated identical wrong Picture Matching option IDs and already-matched Word Matching pairs are blocked without consuming attempts.

---

## 3. Puzzle Algorithms & Pseudocode

### A. Picture Matching
- **Data requirements**: Items with non-empty `id`, `khmerWord`, and (when `requireImage: true`) non-empty `imagePath`.
- **Pseudocode**:
```text
function generatePictureMatching(pool, difficulty, excludeIds):
  candidates = sanitize(pool).where(hasImage)
  target = pickTarget(candidates, difficulty, preferNotIn: excludeIds)
  distractors = []
  for item in shuffle(candidates):
    if item.id != target.id and item.khmerWord != target.khmerWord
       and item.khmerWord not in distractors:
      distractors.add(item)
    if distractors.length == settings.optionCount - 1: break
  if distractors.length < settings.optionCount - 1:
    throw PuzzleGenerationException("Insufficient distinct choices")
  options = shuffle([target] + distractors) with opaque IDs opt_0..opt_n
  return Puzzle(prompt: image + options, answerKey: correctOptionId)
```

### B. Word Matching
- **Data requirements**: Distinct `id`, distinct `khmerWord`, and distinct case-insensitive `englishMeaning` within the round so no pair is ambiguous.
- **Pseudocode**:
```text
function generateWordMatching(pool, difficulty):
  chosen = selectUniqueUnambiguous(pool, count: settings.matchingPairCount)
  if chosen.length < settings.matchingPairCount:
    throw PuzzleGenerationException("Insufficient unambiguous vocabulary")
  left = shuffle(chosen) with opaque IDs left_0..left_k
  right = shuffle(chosen) with opaque IDs right_0..right_k
  expectedPairs = { leftId -> rightId where item.id matches }
  return Puzzle(prompt: left + right, answerKey: expectedPairs)
```

### C. Syllable Ordering
- **Data requirements**: `verified_syllables.length >= 2`, `verification.syllables == verified` (when `requireVerifiedSyllables: true`), and `hasValidSyllableSegments(khmerWord, syllables) == true` (no leading `U+17D2` Coeng or combining marks). **Never** split Khmer strings by character index or `runes`.
- **Pseudocode**:
```text
function generateSyllableOrdering(pool, difficulty, excludeIds):
  eligible = sanitize(pool).where(areSyllablesVerified and syllables.length >= 2)
  target = pickTarget(eligible, difficulty, preferNotIn: excludeIds)
  chips = shuffleNonTrivial(target.syllables)
  return Puzzle(prompt: target.englishMeaning + chips, answerKey: target.syllables + target.khmerWord)
```

---

## 4. Answer Validation (`PuzzleValidationService` / `AnswerValidator`)

- **Picture Matching**: Rejects empty IDs, unknown option IDs, and `alreadySolved`; checks `selectedOptionId == answerKey.correctOptionId`.
- **Word Matching**: Rejects empty/unknown IDs and IDs in `completedPairIds`; checks `answerKey.expectedPairs[leftOptionId] == rightOptionId`.
- **Syllable Ordering**: Rejects empty/incomplete lists and segment multiplicity violations; checks exact segment list equality AND `selectedSyllables.join() == target.khmerWord` (preserving exact Khmer Unicode).

---

## 5. Hint, Difficulty & Scoring Logic

- **Difficulty (`PuzzleDifficultyService` / `DifficultyManager`)**:
  - `easy`: 3 options/pairs, 4 max attempts, 3 max hints, `allowDirectClue: true`.
  - `medium`: 4 options/pairs, 3 max attempts, 2 max hints, `allowDirectClue: true`.
  - `hard`: 5 options/pairs, 2 max attempts, 1 max hint, `allowDirectClue: false`.
- **Hints (`PuzzleHintService` / `HintSession`)**:
  - Delivers progressive clues from `VocabularyItem.hints` (`easy` -> `medium` -> `strong`), tracks `hintsUsed`, avoids duplicates, and blocks spoiler leaks (e.g., 1-syllable words in Word Matching and last-syllable reveals on 2-syllable words).
- **Scoring (`ScoreCalculator`)**:
  - Unsolved: `0`.
  - Solved: `clamp(baseScore[difficulty] - (attempts - 1) * 20 - hintsUsed * 10, min: 10, max: baseScore[difficulty])`, where `baseScore` is `easy: 100`, `medium: 150`, `hard: 200`.

---

## 6. Error Handling & Integration Interfaces

- **Structured errors (`PuzzleIntegrationError`)**: `INVALID_REQUEST`, `UNSUPPORTED_PUZZLE_TYPE`, `VOCABULARY_LOAD_ERROR`, `INSUFFICIENT_VOCABULARY`, `UNKNOWN_PUZZLE_ID`.
- **Primary M3 interfaces** (exported via `lib/features/khmer_puzzle/khmer_puzzle.dart`):
  - `VocabularyRepository` (`KhmerPuzzleRepository`)
  - `PuzzleGenerator` / `QuestionGenerator`
  - `AnswerValidator` (`PuzzleValidationService`)
  - `HintService` / `HintManager` (`PuzzleHintService`)
  - `DifficultyManager` (`PuzzleDifficultyService`)
  - `ScoreCalculator` & `GameScoreManager`
  - `LivesManager`
  - `PuzzleSessionController` (`PuzzleGameState` for single-puzzle checkpoints)
  - `GameSessionManager` (`GameSessionStatus`, `GameConfig`, `GameResult` for multi-question 10-round sessions)
  - `PuzzleIntegrationAdapter` (`PuzzleRequest`, `PuzzlePresentation`, `PuzzleCompletionEvent`)

---

## 7. Multi-Question Session Logic (`GameSessionManager`, `GameScoreManager`, `LivesManager`)

- **Session Lifecycle (`GameSessionStatus`)**: `initializing -> ready -> playing -> answerFeedback -> nextQuestion -> completed | gameOver` (+ `paused`).
- **Scoring (`GameScoreManager`)**:
  - `+10` points on correct answer (`+8` net when `-2` hint penalty is applied once per question).
  - `+5` bonus at `3` consecutive correct answers; `+10` bonus at `5` consecutive correct answers.
  - `0` points on wrong answer (resets streak), clamped `>= 0`.
- **Lives (`LivesManager`)**:
  - Defaults to `3` lives; wrong answer deducts `1` life (`0` triggers `gameOver`); correct answers and hint usage cost `0` lives.
- **Session Result (`GameResult`)**:
  - Safe accuracy: `(correctAnswers / questionsAttempted) * 100` (`0.0` when `questionsAttempted == 0`).
  - Star rating: `>= 90%` → `3` stars, `>= 70%` → `2` stars, `< 70%` → `1` star (`0` on zero-correct `gameOver`).
