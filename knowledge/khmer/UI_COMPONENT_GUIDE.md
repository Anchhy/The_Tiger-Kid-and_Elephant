# M3 UI Component & Icon Architecture Guide

**Scope**: `lib/features/khmer_puzzle/widgets/`  
**Exports**: `package:.../features/khmer_puzzle/khmer_puzzle.dart`

---

## 1. Design Language: Angkor Storybook Adventure

The UI pairs warm parchment & carved sandstone tones (`AngkorPuzzleTheme`) with clear hierarchy tailored for children aged **8–12** learning Cambodian Khmer vocabulary:

- **Primary Surface (`parchmentSurface`)**: `#FBF4E4`
- **Carved Stone Tile (`stoneTile`) / Pressed (`stoneSelected`) / Matched (`stoneMatched`)**: `#F5EAD4` / `#FFF3CD` / `#E3F1DD`
- **Primary Ink (`inkText`) / Secondary Ink (`mutedInk`)**: `#3E2A1D` / `#6E5643`
- **Borders (`sandstoneBorder`)**: `#C5AC82`
- **Semantic Accents**: Gold (`#D4921D`), Moss Green (`#4D7741`), Terracotta (`#B94A2F`)

---

## 2. Flutter UI vs Flame Canvas Rules

| Layer | Responsibility | Recommended Components |
| --- | --- | --- |
| **Flame Canvas** (M2 maze gameplay) | Top-down 2D map, walking Kid/Tiger/Elephant sprites, tile collisions | PNG sprite frames from `KhmerPuzzleAssets` |
| **Flutter Overlay / Puzzle Screens** (M3 & HUD) | Responsive HUD counters, puzzle modals, dictionary cards, confirmation dialogs, banners | Material widgets + `AngkorPuzzleTheme` + `game_asset_widgets.dart` + `game_ui_components.dart` |

> Separating HUD & puzzle dialogs into Flutter overlay widgets guarantees native Khmer Unicode text shaping, accessible `Semantics`, screen-reader support, and automatic `320px–1024px` scaling without pixel blurring.

---

## 3. Core M3 Component Reference

### Icon & Visual Primitives
- **`GameIcon`**: Renders Tier 1 rounded vector icons (`Icons.*_rounded`) or Tier 2–4 crisp PNG sprites (`KhmerPuzzleAssets.*`) with built-in fallback recovery and `Semantics` labels.
- **`GamePanel`**: Framed parchment container with optional header icon, title, Khmer subtitle (`height: 1.5`), trailing badge slot, and sandstone shadow.
- **`GameCard`**: Tactile stone card (`TactilePressScale`) supporting default, `isSelected`, and `isHighlighted` states.

### Gameplay & Educational Controls
- **`AngkorGameButton` / `AngkorIconButton`** (`game_asset_widgets.dart`): Carved stone primary pill buttons and circular action chrome (`>= 48dp`).
- **`PuzzleHeartsBar`, `PuzzleCoinsBadge`, `PuzzleStarsRow`, `PuzzleStarCounter`**: Live player HUD counters for lives, coins, and earned stars.
- **`PuzzleProgressBar`**: Clamped animated bar indicator with Khmer/English label and `Semantics(value: ...)`.
- **`PuzzleAnswerTile`**: Answer/syllable choice tile (`>= 48x48dp`) supporting **Default**, **Selected** (gold highlight), **Matched** (moss green + check icon), **Incorrect/Retry** (terracotta cue + refresh icon), and **Disabled** states. Never reveals the answer key prior to submission.
- **`VocabularyCard`**: Dictionary preview card displaying the word image, Khmer script (`height: 1.5`), difficulty pill, English meaning, and optional Khmer example sentence.

### Exploration, Dialogs & Notices
- **`WorldMapMarker`**: Angkor temple/village waypoint pin (unlocked, active glow, completed + stars, or locked stone gate).
- **`InteractionPrompt`**: Compact floating chip shown near temple steles or NPC helpers.
- **`GameConfirmationDialog`**: Child-friendly dialog (`show(...)` helper) preventing accidental level exits without scary alerts.
- **`GameNotificationBanner`**: Reward, learning tip (`info`), or proximity caution banner with optional dismiss control (`48x48dp`).

---

## 4. Accessibility & Responsiveness Standards

1. **Khmer Script Integrity**: Always style Khmer text with `KhmerTextUtils.khmerTextStyle(...)` (`height: 1.5`, `leadingDistribution: TextLeadingDistribution.even`) so stacked Coeng subscripts (`ជើងអក្សរ`) and vowel diacritics never clip vertically.
2. **Child Touch Targets**: Interactive controls (`PuzzleAnswerTile`, `AngkorIconButton`, `InteractionPrompt`, `WorldMapMarker`, dialog buttons, banner dismiss button) maintain at least `48dp` minimum hit dimensions.
3. **Viewport Range**: Components use `Flexible`, `Expanded`, `Wrap`, and `ConstrainedBox` so layouts remain overflow-free from **`320px` narrow portrait phones** up to **`1024px` tablets**.
4. **Never rely on color alone**: Matched, caution, and locked states combine color + distinct rounded icons + `Semantics` labels.
