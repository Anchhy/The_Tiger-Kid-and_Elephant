# Khmer Vocabulary JSON Schema & Verification Workflow (Phase 3)

## 1. Design Goals

- Keep vocabulary content completely separate from Flutter/Dart puzzle logic.
- Record **field-level verification status** honestly so unverified AI-drafted educational text is never confused with native-verified content.
- Prevent corrupted Khmer syllable splits and duplicate vocabulary IDs.

---

## 2. JSON Entry Structure

```json
{
  "id": "animals_elephant_001",
  "khmer": "ដំរី",
  "english": "Elephant",
  "definition_km": "សត្វព្រៃធំមួយប្រភេទ ដែលមានប្រមោយវែង។",
  "definition_en": "A very large animal with a long trunk.",
  "part_of_speech": "noun",
  "category": "animals",
  "verified_syllables": ["ដំ", "រី"],
  "example_km": "ដំរីមានប្រមោយវែង។",
  "example_en": "The elephant has a long trunk.",
  "hints": {
    "easy": "It is a very big animal.",
    "medium": "It has a long trunk and large ears.",
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
  "sources": [
    "Wiktionary: ដំរី"
  ]
}
```

---

## 3. Field Definitions & Allowed Values

| Field | Required | Type | Allowed Values / Rules |
| --- | :-: | --- | --- |
| `id` | Yes | `string` | Unique snake_case identifier: `<category>_<slug>_<nnn>` (e.g., `animals_elephant_001`). |
| `khmer` | Yes | `string` | Non-empty UTF-8 Khmer word (`U+1780`–`U+17FF` characters required). |
| `english` | Yes | `string` | Concise standard English translation. |
| `definition_km` | Yes | `string` | Simple Khmer learner definition (empty string allowed only if `unverified`, prefer draft + `needs_review`). |
| `definition_en` | Yes | `string` | Simple English explanation for developers/reviewers. |
| `part_of_speech` | Yes | `string` | `noun`, `verb`, `stative_verb`, `adverb`, `pronoun`, `classifier`, `particle`, `compound_noun`. |
| `category` | Yes | `string` | `animals`, `family`, `food`, `nature`, `education`, `daily_life`, `body_parts`, `transportation`, `colors_shapes`, `numbers_time`. |
| `verified_syllables` | Yes | `array<string> \| null` | Explicit ordered Khmer segments; must join to `khmer` (`join() == khmer`), or `null` if segmentation is unverified/ambiguous. |
| `example_km` | Yes | `string` | Natural child-friendly Khmer example sentence. |
| `example_en` | Yes | `string` | English translation of `example_km`. |
| `hints` | Yes | `object` | Must contain `easy`, `medium`, and `strong` string clues (each may contain English or `km`/`en` clues; never expose full answer directly). |
| `difficulty` | Yes | `string` | `easy`, `medium`, `hard`. |
| `image` | Optional | `string` | Asset path under `assets/images/vocabulary/<slug>.png`. |
| `verification` | Yes | `object` | Four keys: `spelling`, `meaning`, `syllables`, `example`. Each must be `"verified"`, `"needs_review"`, or `"unverified"`. |
| `sources` | Yes | `array<string>` | Titles/URLs of dictionaries or textbooks consulted (empty array `[]` if none yet). |
| `notes` | Optional | `string` | Linguistic caveats (e.g., subscript cluster constraints like `ទន្លេ` or `បន្លែ`). |

---

## 4. Validation Rules

1. **Uniqueness**: No duplicate `id` or duplicate canonical `khmer` word within the same dataset without explicit sense disambiguation.
2. **Unicode Integrity**: `khmer` must contain valid Khmer Unicode (`[\u1780-\u17FF]`).
3. **Syllable Safety**:
   - When `verified_syllables` is non-null, `verified_syllables.join() == khmer` MUST hold.
   - No segment in `verified_syllables` may begin with `U+17D2` (Coeng) or a combining vowel/diacritic.
   - Words with 1 orthographic unit (or subscript-bridged clusters like `ទន្លេ`, `បន្លែ`, `ម្តាយ`) must keep 1 intact string or `null` so Syllable Ordering never splits them incorrectly.
4. **Production Gate**: Only items with `verification.spelling == "verified"` and `verification.meaning == "verified"` should be enabled in production matching puzzles; Syllable Ordering additionally requires `verification.syllables == "verified"` and `verified_syllables.length >= 2`.

---

## 5. Safe Update & Verification Workflow

1. **Drafting**: Add new entry with `sources` listed and all unconfirmed educational fields (`example`, `syllables`, `meaning` if uncertain) marked `"needs_review"`.
2. **Automated Check**: Run schema/Unicode/syllable-join tests before accepting dataset edits.
3. **Native Teacher Review**: A Cambodian Khmer educator verifies `spelling`, `meaning`, `verified_syllables`, `example_km`, and `hints`, then flips the corresponding `verification` flags to `"verified"`.
4. **Deprecation**: Never delete an `id` already referenced by saved M5 player progress—mark or migrate safely instead.
