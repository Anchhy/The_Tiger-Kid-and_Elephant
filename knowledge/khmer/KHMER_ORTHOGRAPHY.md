# Khmer Orthography and Writing System (Phase 1 Knowledge Base)

> **Verification Policy**: Structural and Unicode facts below are verified against the Unicode Standard (`U+1780`–`U+17FF`) and standard Khmer linguistic references. Grade-level suitability, dictionary variants, and Khmer educational phrasing require native Khmer teacher review.

---

## 1. Khmer Consonants and Consonant Series (`ព្យញ្ជនៈ និងពួកសំឡេង`)

Khmer has **33 modern consonants** (`U+1780`–`U+17A2`, excluding historical/obsolete `ឝ` `U+179D` and `ឞ` `U+179E`). Every consonant belongs to one of two **register series** that govern vowel pronunciation:

- **First Series / A-Series (`ពួក អ` — 15 consonants)**: Inherent vowel `-â` (`/ɑː/`).
  - `ក` (`U+1780`), `ខ` (`U+1781`), `ច` (`U+1785`), `ឆ` (`U+1786`), `ដ` (`U+178A`), `ឋ` (`U+178B`), `ណ` (`U+178E`), `ត` (`U+178F`), `ថ` (`U+1790`), `ប` (`U+1794`), `ផ` (`U+1795`), `ស` (`U+179F`), `ហ` (`U+17A0`), `ឡ` (`U+17A1`), `អ` (`U+17A2`)
- **Second Series / O-Series (`ពួក អ៊` — 18 consonants)**: Inherent vowel `-ô` (`/ɔː/`).
  - `គ` (`U+1782`), `ឃ` (`U+1783`), `ង` (`U+1784`), `ជ` (`U+1787`), `ឈ` (`U+1788`), `ញ` (`U+1789`), `ឌ` (`U+178C`), `ឍ` (`U+178D`), `ទ` (`U+1791`), `ធ` (`U+1792`), `ន` (`U+1793`), `ព` (`U+1796`), `ភ` (`U+1797`), `ម` (`U+1798`), `យ` (`U+1799`), `រ` (`U+179A`), `ល` (`U+179B`), `វ` (`U+179C`)

**Examples**:
- `ក` (A-series) + `ា` -> `កា` (light/open `-aa` sound)
- `គ` (O-series) + `ា` -> `គា` (deeper `-ie` sound)

---

## 2. Independent Vowels (`ស្រៈពេញតួ`)

Independent vowels are standalone characters (`U+17A3`–`U+17B3`) that form syllables without a base consonant (mostly in Sanskrit/Pali-origin or traditional words):

- Inventory: `ឣ`*, `ឤ`*, `ឥ`, `ឦ`, `ឧ`, `ឩ`, `ឪ`, `ឫ`, `ឬ`, `ឭ`, `ឮ`, `ឯ`, `ឰ`, `ឱ`, `ឲ`, `ឳ`
  *(Note: `ឣ` `U+17A3` and `ឤ` `U+17A4` are deprecated in Unicode; modern Khmer uses `អ` + vowel instead.)*
- **Common student examples**:
  - `ឪពុក` (father — uses `ឪ`)
  - `ឬ` (or — uses `ឬ`)
  - `ឥឡូវ` (now — uses `ឥ`)
  - `ឯង` (self / you — uses `ឯ`)

---

## 3. Dependent Vowels (`ស្រៈនិស្ស័យ`)

Dependent vowels cannot stand alone; they attach **before, after, above, below, or around** a consonant (or consonant cluster).

- **Core Unicode vowel signs (`U+17B6`–`U+17C5`)**:
  - `ា`, `ិ`, `ី`, `ឹ`, `ឺ`, `ុ`, `ូ`, `ួ`, `ើ`, `ឿ`, `ៀ`, `េ`, `ែ`, `ៃ`, `ោ`, `ៅ`
- **Traditional Cambodian school list (24 dependent vowels)**: Adds standard composite vowel+diacritic endings taught together in primary school, including `ុំ`, `ំ`, `ាំ`, `ះ`, `ុះ`, `េះ`, `ោះ` (plus `ៈ`/`ៅ` combinations depending on textbook grouping — *requires native teacher review for exact MoEYS Grade 1–3 chart order*).
- **Examples**:
  - Post-posed: `ា` in `ខ្លា` (tiger)
  - Above: `ី` in `ដំរី` (elephant)
  - Below: `ូ` in `កូន` (child/offspring)
  - Pre-posed (visual left): `េ` in `មេអំបៅ` (butterfly)
  - Surrounding/multi-part: `ើ` in `ឈើ` (tree/wood), `ៀ` in `រៀន` (study)

---

## 4. Diacritics and Modifying Signs (`វណ្ណយុត្តិ និងសញ្ញា`)

| Mark | Name | Unicode | Function | Example |
| --- | --- | --- | --- | --- |
| `៉` | Muusikatoan (`មូសិកទន្ត`) | `U+17C9` | Shifts select O-series consonants (and `ប` -> `ប៉`) to A-series sound | `ប៉ា` |
| `៊` | Triisap (`ត្រីស័ព្ទ`) | `U+17CA` | Shifts select A-series consonants (`ប, ស, ហ, អ`) to O-series sound | `ស៊ូ` |
| `់` | Bantoc (`បន្តក់`) | `U+17CB` | Shortens the syllable's vowel sound | `កាត់` |
| `ំ` | Nikahit (`និគ្គហិត`) | `U+17C6` | Nasal final (`-m` / `-am`) | `ដំរី` |
| `ះ` | Reahmukh (`វិសជ្ជនីយ`) | `U+17C7` | Final breath/glottal release (`-ah`) | `ផ្ទះ` |
| `ៈ` | Yuukaleapintu (`យុគលពិន្ទុ`) | `U+17C8` | Short glottal stop in loanwords | `គណៈ` |
| `័` | Samyok Sannya (`សំយោគសញ្ញា`) | `U+17D0` | Modifies vowel quality/length in select words | `សម័យ` |
| `៌` | Robat (`របាទ`) | `U+17CC` | Historical Sanskrit `r` marker above consonant | `ព័ត៌មាន` |
| `៍` | Toandakhiat (`ទណ្ឌឃាដ`) | `U+17CD` | Silences the consonant it sits above (loanwords) | `សិទ្ធិ៍` *(verify grade suitability)* |
| `៎` | Kakabat (`កាកបាទ`) | `U+17CE` | Exclamation / rising intonation marker | `ចា៎` |
| `៏` | Ahsda (`អស្តា`) | `U+17CF` | Marks particles/words like `ក៏` | `ក៏` |

---

## 5. Subscript Consonants (`ជើងអក្សរ` / Coeng)

When two consonants are pronounced together in a cluster without an intervening vowel, the second consonant is written in reduced **subscript** form (`ជើង`, meaning "foot") underneath or around the first consonant:

- **Mechanism**: Encoded as `U+17D2` (`្`, **KHMER SIGN COENG**) + the target consonant.
- **Count**: **32 subscript forms** exist in standard Khmer — `ឡ` (`U+17A1`) has **no** standard subscript form.
- **Examples**:
  - `ខ្លា` (tiger): `ខ` + `្` + `ល` (`្ល`) + `ា`
  - `ក្មេង` (young/kid): `ក` + `្` + `ម` (`្ម`) + `េ` + `ង`
  - `ព្រៃ` (forest): `ព` + `្` + `រ` (`្រ` wraps visually to the left and bottom) + `ៃ`

---

## 6. Orthographic Combinations: Spelling Rules vs. Pronunciation Rules

It is essential to separate **spelling rules** (written form) from **pronunciation rules** (spoken realization):

| Aspect | Spelling Rule (Written Orthography) | Pronunciation Rule (Spoken Realization) |
| --- | --- | --- |
| **Consonant Series** | A word must always preserve its canonical dictionary consonant (`ក` vs `គ`, `ត` vs `ទ`). | The series of the initial consonant (or register shifter `៉`/`៊`) changes how the attached vowel is pronounced. |
| **Subscript Clusters** | Subscripts follow fixed dictionary spelling (`ខ្លា`, `ផ្ទះ`), even when a subscript or final is silent or altered. | In clusters, the dominant initial or series determines the syllable register (*requires phonology phase review for cluster-register details*). |
| **Etymological Loanwords** | Sanskrit/Pali words retain historical letters and signs (`៍`, `៌`, `័`, `ៈ`) per the Chuon Nath / RAC standard. | Silent final consonants marked by `៍` or historical `៌` are not pronounced as full syllables. |
| **Word Boundaries** | Khmer writes words continuously **without spaces between words**; spaces mark phrases/clauses, and `។` (`U+17D4`) ends sentences. | Spoken pauses occur at phrase/word boundaries even though no ASCII space separates words in text. |

---

## 7. Khmer Unicode Representation

- **Block**: `U+1780`–`U+17FF` (UTF-8 encoded in JSON and Dart strings).
- **Logical Order (Not Visual Order)**: Unicode stores characters in phonological/typing order, while the font/rendering engine (HarfBuzz/Skia in Flutter) reorders glyphs visually.
- **Canonical Syllable Cluster Order**:
  ```text
  Base Consonant (or Independent Vowel)
    -> [Robat U+17CC]
    -> [Coeng U+17D2 + Subscript Consonant] (up to 2)
    -> [Register Shifter: U+17C9 or U+17CA]
    -> [Dependent Vowel: U+17B6..U+17C5]
    -> [Trailing Sign: U+17C6, U+17C7, U+17CB, U+17CD, U+17D0, etc.]
  ```
- **Example (`ព្រៃ` — forest)**:
  - Visual order: `្រ` appears to the left of `ព`, and `ៃ` appears to the left of `្រ`.
  - Logical Unicode order: `ព` (`U+1796`) -> `្` (`U+17D2`) -> `រ` (`U+179A`) -> `ៃ` (`U+17C3`).
- **Critical Code Rule**: `ខ្លា` has **4 Unicode code points** (`ខ` + `្` + `ល` + `ា`), NOT 4 syllables or 4 letters.

---

## 8. Common Khmer Spelling Mistakes

1. **Confusing `ដ` and `ត` subscripts (`្ដ` vs. `្ត`)**: Both subscripts look nearly identical in standard fonts, causing frequent substitution errors (e.g., `អណ្ដើក` vs. incorrect `អន្តើក`).
2. **Confusing `់` (Bantoc), `័` (Samyok Sannya), and `៍` (Toandakhiat)**: Learners mix up vowel-shortening `់` with vowel-modifying `័` or consonant-silencing `៍`, or omit them when spelling phonetically.
3. **Misplacing or swapping `៉` and `៊` on `ប` (`ប៉` vs. `ប៊`)**: Changing `៉` vs. `៊` alters both consonant register and meaning, and incorrect typing order breaks rendering.
4. **Phonetic simplification of Sanskrit/Pali loanwords**: Dropping silent/etymological characters (`៍`, `៌`, `ៈ`) to match casual pronunciation instead of Chuon Nath / RAC spelling.
5. **Keyboard typing-order errors**: Typing a pre-posed vowel (`េ`, `ែ`, `ៃ`, `ោ`, `ៅ`) or `្រ` *before* the base consonant instead of following Unicode logical order, producing invalid sequences or dotted circles (`◌`).

---

## 9. Important Rules for M3 Puzzle Developers

### Impact on Word Matching Puzzles
1. **Exact canonical comparison only**: Compare answers by exact canonical `id` and exact UTF-8 `khmerWord` strings—never strip diacritics (`់`, `៉`, `៊`, `័`) or apply fuzzy string matching.
2. **Preserve full combining sequences**: Never trim, normalize inconsistently, or slice Khmer strings in UI cards; use complete verified strings from JSON.
3. **Safe visual distractors**: At `easy` difficulty, avoid pairing words whose only visual difference is easily confused subscripts like `្ដ` vs. `្ត` unless explicitly intended for advanced spelling practice (pending native teacher review).
4. **Android font verification**: Always test rendered cards containing stacked subscripts (`ជើងអក្សរ`) and register shifters (`ប៊ី`, `ផ្ទះ`, `ព្រៃ`) on Android devices to prevent glyph clipping.

### Impact on Syllable Ordering Puzzles
1. **Never split by `String.split('')` or `runes`**: Splitting code points separates `U+17D2` (Coeng) from its subscript consonant and separates pre-posed vowels (`េ`, `ែ`, `ៃ`, `ោ`, `ៅ`) from their base consonant, corrupting Khmer text.
2. **Use pre-verified JSON `syllables` arrays**: Every puzzle's shuffled chips must come strictly from manually verified orthographic/educational segments stored in JSON (e.g., `["ដំ", "រី"]`, `["សា", "លា", "រៀន"]`).
3. **Round-trip integrity check**: After assembling selected segments (`selectedSyllables.join()`), verify BOTH exact segment-list order AND exact equality with the canonical `khmerWord`.
4. **Single-syllable words excluded**: Words like `ខ្លា` or `ទឹក` are 1 syllable despite having 3–4 Unicode code points and must only appear in Picture/Word Matching, never Syllable Ordering.

---

## 10. Unresolved Questions & Items Requiring Native Khmer Teacher Review

1. **MoEYS Grade 1–3 dependent vowel list**: Confirm the exact 24-vowel school chart ordering and composite forms (`ុំ`, `ំ`, `ាំ`, `ះ`, `ុះ`, `េះ`, `ោះ`) used in Cambodian primary classrooms.
2. **Dictionary variants (Chuon Nath vs. RAC/MoEYS)**: Confirm which spelling standard to enforce if any target children's words have accepted modern variants (especially `្ដ`/`្ត` and loanwords).
3. **Difficulty placement of diacritics/subscripts**: Confirm whether words with `៍`, `៌`, `ៈ`, or multi-subscript clusters should be restricted strictly to `hard` difficulty.
4. **Verification of existing starter JSON entries**: Have a native Khmer educator review all 15 starter words and educational notes in `assets/data/khmer_vocabulary.json` before finalizing production content.

---

## 11. Sources

1. **The Unicode Consortium — Khmer Code Chart (`U+1780`–`U+17FF`)**: [https://www.unicode.org/charts/PDF/U1780.pdf](https://www.unicode.org/charts/PDF/U1780.pdf)
2. **National Council of the Khmer Language (Royal Academy of Cambodia)**: [https://nckl.rac.gov.kh](https://nckl.rac.gov.kh)
3. **SEAsite Khmer Language & Writing System (Northern Illinois University)**: [https://seasite.niu.edu/khmer/](https://seasite.niu.edu/khmer/)
