# M3 Khmer Puzzle UI Specification (Phase 7)

> **Boundary Note**: M3 provides functional, neutral Material 3 puzzle widgets and state handling. Global visual branding, Figma tokens, custom fonts, animations, and illustrations belong to **M4** and are **not** claimed as M4-approved yet.

---

## 1. Widget Responsibilities

| Widget | Responsibility |
| --- | --- |
| `PictureMatchingWidget` | Displays target picture, selectable Khmer word choices, hint banner/button, feedback banner, and submits via `PuzzleValidationService`. |
| `WordMatchingWidget` | Displays separate Khmer and English groups, manages pair selection, disables completed pairs, handles retries, and reports round completion. |
| `SyllableOrderingWidget` | Displays shuffled verified syllable tiles (tracked by index for repeated syllables), allows placing/removing/resetting tiles, and validates via `PuzzleValidationService`. |
| `PuzzleHeader` | Displays puzzle title, difficulty badge, instruction text, and optional hint/close buttons. |
| `PuzzleProgress` | Displays remaining attempts and optional step counter (`Pairs matched` / `Syllables placed`). |
| `PuzzleFeedbackBanner` | Accessible `liveRegion` card showing correctness icon, message, and educational note. |
| `HintButton` & `PuzzleHintBanner` | Displays remaining hint count (`48dp` min touch target) and active progressive hint text. |
| `PuzzleLoadingView` / `PuzzleErrorView` / `VocabularyImageFrame` | Shared loading spinner, retryable error view, and asset image frame with missing-image fallback + optional `imageBuilder`. |

---

## 2. Required Input Data & Callbacks

All three puzzle widgets accept:
- **Inputs**:
  - `Puzzle? puzzle` (widgets render **only** `puzzle.prompt` and never inspect `puzzle.answerKey`)
  - `bool isLoading`, `String? errorMessage`
  - Optional `PuzzleValidationService`, `PuzzleHintService`, and `VocabularyImageBuilder? imageBuilder` (Picture Matching)
- **Callbacks**:
  - `VoidCallback? onRetry` — Triggered from `PuzzleErrorView`
  - `VoidCallback? onClose` — Triggered from `PuzzleHeader`
  - `ValueChanged<PuzzleResult>? onCompleted` — Emitted when solved or attempts are exhausted
  - `ValueChanged<HintResponse>? onHintRequested` — Emitted when player requests a hint
  - Mode-specific hooks: `onOptionSelected` (Picture Matching), `onPairMatched` (Word Matching)

---

## 3. Visual States

- **Loading**: Centered `CircularProgressIndicator` with `"Loading Khmer puzzle..."`.
- **Error / Empty**: Error icon, descriptive message, and optional `"Retry"` `FilledButton`.
- **Active Selection**: Primary-container fill and `2px` primary border on selected choice/tile.
- **Completed Pair (Word Matching)**: Muted container + `Icons.check_circle` + disabled tap handler (`onTap: null`).
- **Disabled Controls**: Submit/Check/Reset/Hint buttons disable automatically when selection is empty, unchanged after a wrong Picture Matching attempt, or after puzzle completion.
- **Feedback**: Primary-container banner on correct submission; error-container banner on incorrect submission.

---

## 4. Accessibility & Khmer Text Rules

- All Khmer text uses `KhmerTextUtils.khmerTextStyle` (`height: 1.5`, `leadingDistribution: TextLeadingDistribution.even`) to prevent vertical clipping of stacked subscripts (`ជើងអក្សរ`) and superscript diacritics (`៉`, `៊`, `ី`, `ឹ`).
- Interactive controls enforce `>= 48dp` minimum height (`52–56dp` on answer cards).
- Semantic labels describe picture frames, hint counts, matched pairs, syllable actions (`Select syllable ...` / `Remove syllable ...`), and live feedback banners.
- No extra font packages were added; Android device testing with Khmer system/M4 fonts is required in integration.

---

## 5. Responsive Behavior

Tested across `320px`, `375px`, `430px`, `768px`, and `1024px` widths:
- Outer `SingleChildScrollView` + `LayoutBuilder` prevents horizontal and vertical overflow.
- Content centers within `maxWidth: 680–720px` on tablet widths (`768px`, `1024px`).
- **Picture Matching**: 1 column `< 420px`, 2 columns `>= 420px` with dynamic card height.
- **Word Matching**: Stacked Khmer/English groups `< 360px`, side-by-side columns `>= 360px`.
- **Syllable Ordering**: `Wrap` layout for answer slots, tile bank, and action buttons.

---

## 6. What M4 Should Customize Later

Temporary Material 3 `ColorScheme` defaults and `Theme.of(context).textTheme` are used today. M4 can style/brand the module by:
1. Supplying the app-wide `ThemeData` (colors, card shapes, Khmer-verified font family such as Noto Sans Khmer / Battambang once licensed and bundled).
2. Passing a custom `VocabularyImageBuilder` to `PictureMatchingWidget` / `KhmerPuzzleScreen` for custom frames or animations.
3. Styling `PuzzleHeader`, `PuzzleFeedbackBanner`, and tile surfaces without altering M3 validation or engine logic.
