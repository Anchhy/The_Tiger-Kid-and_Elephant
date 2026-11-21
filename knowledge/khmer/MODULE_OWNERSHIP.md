# Module Ownership & Collaboration Matrix

**Repository**: *The Tiger, Kid, and Elephant* (`tiger_kid_elephant` / `https://github.com/Anchhy/The_Tiger-Kid-and_Elephant.git`)  
**Principle**: Each contributor develops exclusively inside their assigned module boundaries and shares explicit interface contracts instead of editing teammates' code directly.

---

## 1. Module Ownership Table

| Module | Role | Primary Scope & Owned Directories | Protected From Unassigned Edits |
| :-: | --- | --- | --- |
| **M1** | **Level Developer** | Level definitions, maze maps, checkpoint configurations (`PuzzleRequest` payloads) | M2, M3, M4, M5 |
| **M2** | **Gameplay Developer** | Flame maze loop, Kid movement, Tiger chase logic, Elephant destination triggers, collisions | M1, M3, M4, M5 |
| **M3** | **Khmer Puzzle Developer** *(SEK THORN — T9, T10, T11)* | • `lib/features/khmer_puzzle/`<br>• `assets/data/khmer_vocabulary.json`<br>• `assets/images/` (M3 vocabulary & UI illustrations)<br>• `knowledge/khmer/`<br>• `test/features/khmer_puzzle/` | M1, M2, M4, M5, `lib/main.dart`, `test/widget_test.dart` |
| **M4** | **UI/UX & Animation Developer** | Overall UI/UX, Figma design system, global themes, HUD framing, character animations | M1, M2, M3, M5 |
| **M5** | **Integration & Mobile Developer** | `lib/main.dart`, Flame host screen (`TigerKidElephantApp`, `GameScreen`), routing/navigation, save persistence, `test/widget_test.dart`, Android/iOS build & release | Internal M1, M2, M3, M4 business logic |

---

## 2. Shared Files & Edit Rules

| Shared File | Primary Owner / Stewards | Allowed Collaboration Rule |
| --- | --- | --- |
| `pubspec.yaml` | **M5** (Steward) + **All Modules** | Only make minimal, additive edits (e.g., M3 appends entries under `flutter.assets`). Never alter `name:`, `environment.sdk`, or another teammate's dependencies without approval. |
| `pubspec.lock` | **M5** | Do not regenerate or commit lockfile churn from module-only asset changes. |
| `lib/main.dart` | **M5** | Host integration point only. M3 exposes `lib/features/khmer_puzzle/khmer_puzzle.dart` for M5 to import rather than modifying `main.dart` unilaterally. |
| `.github/pull_request_template.md` | **Team / M1 & M5** | Follow for every feature PR. |
| `AGENTS.md` / `GEMINI.md` | **Team** | Defines workspace agent boundaries and safe Git workflow. |

---

## 3. M3 Public Entry Point & Integration Contract

External modules (M1, M2, M4, M5) should import **only**:

```dart
import 'package:tiger_kid_elephant/features/khmer_puzzle/khmer_puzzle.dart';
```

See [M3_INTEGRATION_CONTRACT.md](./M3_INTEGRATION_CONTRACT.md) and [M3_TEAM_INTEGRATION_GUIDE.md](./M3_TEAM_INTEGRATION_GUIDE.md) for `PuzzleRequest`, `PuzzlePresentation` (`PuzzlePrompt`), `PuzzleIntegrationAdapter`, `GameSessionManager`, and `GameResult`.
