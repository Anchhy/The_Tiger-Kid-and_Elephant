# Khmer Vocabulary Data Quality Rules (Phase 4)

> **Scope**: Automated quality control and human linguistic QA rules for Khmer vocabulary datasets (`knowledge/khmer/examples/initial_vocabulary.json` and future M3 production datasets). Automated checks verify structural, Unicode, and metadata integrity—they **never** prove linguistic or pedagogical correctness without native Khmer review.

---

## 1. Validation Rules by Category

### A. JSON Structure
- Must be valid UTF-8 JSON.
- Root value must be a JSON array (`List`), and every item must be a JSON object (`Map`).
- Field names must follow `VOCABULARY_SCHEMA.md` (with `khmerWord`/`englishMeaning`/`imagePath`/`syllables` recognized when validating legacy M3 starter records).

### B. Required vs. Optional Fields
- **Required fields**:
  - `id` (unique non-empty string)
  - `khmer` (non-empty Khmer Unicode string)
  - `english` (non-empty string)
  - `category` (allowed category enum)
  - `part_of_speech` (allowed part-of-speech enum)
  - `difficulty` (`easy`, `medium`, `hard`)
  - `verified_syllables` (explicit non-empty list of strings, or `null` only when `verification.syllables != "verified"`)
  - `verification` (`spelling`, `meaning`, `syllables`, `example` each set to `verified`, `needs_review`, or `unverified`)
- **Recommended / Optional fields** (missing/empty triggers warnings rather than hard errors):
  - `definition_km`, `definition_en`
  - `example_km`, `example_en`
  - `hints` (`easy`, `medium`, `strong`)
  - `sources` (list of reference titles/URLs)
  - `image`, `notes`

### C. Khmer Text Integrity
- Reject empty Khmer text or strings lacking Khmer Unicode (`U+1780`–`U+17FF`).
- Warn on leading/trailing whitespace (`WARN_KHMER_WHITESPACE`).
- Reject unexpected control characters (`U+0000`–`U+001F`, `U+007F`–`U+009F`).
- Warn on invisible formatting characters (`U+200B`–`U+200F`, `U+202A`–`U+202E`, `U+2060`, `U+FEFF`).
- **Non-mutation rule**: Validator never strips combining marks, alters spelling, or normalizes Khmer text silently.

### D. Syllable Segmentation Integrity
- Syllables must be explicit non-empty strings inside an array (`verified_syllables`), never inferred by character or code-point splitting.
- Reject empty syllable lists (`ERR_EMPTY_SYLLABLES`).
- Reject any segment starting with a combining mark or `U+17D2` Coeng (`ERR_LEADING_COMBINING_MARK`, e.g., invalid `["ទន", "្លេ"]`).
- When `verified_syllables` is non-null, `verified_syllables.join()` must exactly reconstruct `khmer` (`ERR_SYLLABLE_MISMATCH`).
- `verified_syllables` cannot be `null` if `verification.syllables == "verified"`.

### E. Semantic Data & Duplicate Detection
- Warn on missing `definition_km`, `definition_en`, `hints`, or `example_km`/`example_en`.
- Reject duplicate `id` (`ERR_DUPLICATE_ID`).
- Warn (never auto-delete) on duplicate `khmer` (`WARN_DUPLICATE_KHMER`) or duplicate `english` (`WARN_DUPLICATE_ENGLISH`) so human reviewers can verify valid homographs/synonyms.

### F. Verification & Sources
- Warn when `sources` is empty (`WARN_MISSING_SOURCES`) rather than inventing citations.
- Warn on any `verification.*` field not equal to `"verified"`.

---

## 2. Error and Warning Code Reference

| Code | Severity | Meaning | How to Fix |
| --- | --- | --- | --- |
| `ERR_JSON_EMPTY` / `ERR_JSON_SYNTAX` / `ERR_JSON_ROOT_TYPE` | Error | Empty, invalid, or non-array JSON file. | Fix JSON syntax and ensure root is `[...]`. |
| `ERR_ENTRY_TYPE` | Error | Array element is not a JSON object. | Replace element with a valid vocabulary JSON object. |
| `ERR_MISSING_ID` | Error | Missing or empty `id`. | Assign a unique `<category>_<slug>_<nnn>` ID. |
| `ERR_DUPLICATE_ID` | Error | Two records share the same `id`. | Rename the duplicate entry's `id`. |
| `ERR_MISSING_KHMER` / `ERR_NO_KHMER_UNICODE` | Error | Missing Khmer word or lacks `U+1780`–`U+17FF`. | Provide a valid Khmer Unicode word. |
| `ERR_CONTROL_CHARS` | Error | Khmer word contains control characters. | Clean the raw input string manually in UTF-8 editor. |
| `ERR_MISSING_ENGLISH` | Error | Missing or empty `english`. | Add a concise English translation. |
| `ERR_MISSING_CATEGORY` / `ERR_INVALID_CATEGORY` | Error | Missing or unknown `category`. | Use an allowed category from `VOCABULARY_SCHEMA.md`. |
| `ERR_MISSING_POS` / `ERR_INVALID_POS` | Error | Missing or unknown `part_of_speech`. | Use an allowed part of speech from `VOCABULARY_SCHEMA.md`. |
| `ERR_MISSING_DIFFICULTY` / `ERR_INVALID_DIFFICULTY` | Error | Missing or unknown `difficulty`. | Use `easy`, `medium`, or `hard`. |
| `ERR_MISSING_VERIFICATION` / `ERR_INVALID_VERIFICATION` | Error | Missing or invalid `verification` sub-keys. | Provide `spelling`, `meaning`, `syllables`, `example` with `verified` / `needs_review` / `unverified`. |
| `ERR_MISSING_SYLLABLES_FIELD` / `ERR_INVALID_SYLLABLES_TYPE` / `ERR_EMPTY_SYLLABLES` | Error | Missing, wrong-type, or empty `verified_syllables`. | Provide explicit verified segment list or `null` (when unverified). |
| `ERR_VERIFIED_SYLLABLES_NULL` | Error | `verified_syllables` is `null` while marked `"verified"`. | Either add verified segments or set `verification.syllables` to `"needs_review"`. |
| `ERR_INVALID_SYLLABLE_SEGMENT` / `ERR_LEADING_COMBINING_MARK` | Error | Empty segment or segment starts with `្` / combining vowel. | Merge broken subscript/vowel back onto its base consonant. |
| `ERR_SYLLABLE_MISMATCH` | Error | `verified_syllables.join() != khmer`. | Correct segment boundaries after consulting Khmer spelling rules. |
| `WARN_KHMER_WHITESPACE` / `WARN_INVISIBLE_CHARS` | Warning | Leading/trailing spaces or invisible characters in Khmer text. | Inspect and clean invisible characters carefully. |
| `WARN_DUPLICATE_KHMER` / `WARN_DUPLICATE_ENGLISH` | Warning | Repeated Khmer word or English gloss across records. | Reviewer confirms whether entries are distinct senses/synonyms or duplicates. |
| `WARN_MISSING_DEFINITION_*` / `WARN_MISSING_HINTS` / `WARN_EMPTY_HINT` / `WARN_MISSING_EXAMPLE` | Warning | Missing optional/draft pedagogical content. | Author child-friendly Khmer/English content and mark `"needs_review"`. |
| `WARN_UNVERIFIED_*` | Warning | One or more `verification` keys are not `"verified"`. | Have a native Cambodian Khmer educator review and approve before production release. |
| `WARN_MISSING_SOURCES` | Warning | Empty or missing `sources` list. | Record the dictionary/textbook reference used (never fabricate). |
