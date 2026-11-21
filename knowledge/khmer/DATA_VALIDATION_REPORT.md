# Khmer Vocabulary Data Validation Report (Phase 4)

- **Target Dataset**: [initial_vocabulary.json](file:///e:/Khmer-guessing-word/knowledge/khmer/examples/initial_vocabulary.json)
- **Validator Implementation**: [vocabulary_validator.dart](file:///e:/Khmer-guessing-word/lib/features/khmer_puzzle/utils/vocabulary_validator.dart)
- **Test Verification**: [vocabulary_validator_test.dart](file:///e:/Khmer-guessing-word/test/features/khmer_puzzle/vocabulary_validator_test.dart)

---

## 1. Summary Metrics

| Metric | Observed Result |
| --- | :-: |
| **Total entries** | **50** |
| **Valid entries (0 errors)** | **50** |
| **Entries with errors** | **0** |
| **Entries with warnings** | **50** (74 total warnings) |
| **Duplicate IDs** | **0** |
| **Duplicate Khmer words** | **0** |
| **Duplicate English meanings** | **0** |
| **Missing required fields** | **0** |
| **Unverified spelling** | **2** |
| **Unverified meanings** | **0** |
| **Unverified syllables** | **22** |
| **Unverified examples** | **50** |
| **Entries requiring native-speaker review** | **50** |

---

## 2. Detailed Breakdown of Review Items

### A. Unverified Spelling (2 entries — `WARN_UNVERIFIED_SPELLING`)
1. `family_mother_011` (`ម្តាយ`) — Requires Chuon Nath vs. RAC dictionary confirmation for `្ត` vs. `្ដ` subscript preference.
2. `family_kid_013` (`កូនក្មេង`) — Everyday compound; awaiting formal dictionary/textbook citation.

### B. Unverified Syllables (22 entries — `WARN_UNVERIFIED_SYLLABLES`)
- **21 multi-syllable / compound / subscript-bridged entries** (`ដំរី`, `មេអំបៅ`, `ឪពុក`, `ម្តាយ`, `កូនក្មេង`, `ផ្លែឈើ`, `បន្លែ`, `ទឹកដោះគោ`, `ផ្លែស្វាយ`, `ដើមឈើ`, `ព្រៃឈើ`, `ទន្លេ`, `ព្រះអាទិត្យ`, `សាលារៀន`, `សៀវភៅ`, `ខ្មៅដៃ`, `ក្តារខៀន`, `គ្រូបង្រៀន`, `កៅអី`, `កសិករ`, `នាឡិកា`) require MoEYS primary-school teacher confirmation for classroom segmentation.
- **1 entry with `verified_syllables: null`**: `nature_environment_035` (`បរិស្ថាន`) — orthographic clusters (`ប-រិ-ស្ថាន`) differ from spoken syllabification (`/paʔ.rəh.tʰaːn/`); intentionally left `null` rather than guessing.

### C. Unverified Examples, Definitions & Hints (50 entries — `WARN_UNVERIFIED_EXAMPLE`)
- All 50 drafted `example_km`, `definition_km`, and `hints` fields are marked `"example": "needs_review"` until reviewed by a native Cambodian Khmer educator for natural child-directed grammar and age appropriateness.

---

## 3. Readiness Assessment for M3 Development

- **Structure, Unicode & Code-Safety Readiness**: **READY** — All 50 records pass structural, UTF-8 Khmer Unicode, unique ID, and non-broken syllable-join checks with **0 errors**.
- **Production Linguistic Readiness**: **PARTIAL (Development/Testing Ready; Production Gated)** —
  - All 28 single-syllable `spelling == "verified"` + `meaning == "verified"` words (plus dictionary-verified words in matching modes) can safely power **M3 Picture Matching & Word Matching development and testing** immediately.
  - **Syllable Ordering** should gate on `verification.syllables == "verified"` in production, and **all 50 Khmer example sentences/definitions/hints** must pass native Khmer teacher review before final release.
- **Starter Asset Dataset Note**: [khmer_vocabulary.json](file:///e:/Khmer-guessing-word/assets/data/khmer_vocabulary.json) (15 starter entries in `assets/data/`) remains preserved unchanged for current Flutter unit tests until the team approves promoting the reviewed Phase 3/4 schema to `assets/data/`.
