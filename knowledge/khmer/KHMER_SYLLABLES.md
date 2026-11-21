# Khmer Syllable Structure and Word Segmentation (Phase 2 Knowledge Base)

> **Accuracy Labels Used in This Document**:
> - **[Verified by source]**: Directly supported by cited linguistic/Unicode/lexicographic references.
> - **[General explanation]**: Pedagogical synthesis for software developers based on verified principles.
> - **[Needs native-speaker / teacher review]**: Classroom suitability, regional variation, or word-specific educational segmentation requiring confirmation by a Cambodian Khmer educator.

---

## A. Khmer Syllable Structure

### 1. What Is a Khmer Syllable?
**[Verified by source]** Unlike English, Khmer words frequently exhibit **sesquisyllabicity** ("one-and-a-half syllables"): a weak, unstressed **minor syllable** (presyllable) followed by a stressed **major syllable**—or a single stressed major syllable on its own.

```text
Word Template:           (Minor Syllable) + Major Syllable
Minor Syllable Template: C1 + (reduced vowel /ə/) + (optional nasal N)   [no full coda]
Major Syllable Template: (C1 [C2]) + Vowel Nucleus + (Coda C3)
```

### 2. Building Blocks of a Syllable
**[Verified by source / General explanation]**
- **Initial Consonant (`C1`)**: Every orthographic syllable begins with a base consonant (`U+1780`–`U+17A2`) or an independent vowel (`U+17A3`–`U+17B3`).
- **Consonant Series (Register)**: `C1` (or the dominant consonant in a cluster) belongs to either the **First Series (A-series, `/ɑː/`)** or **Second Series (O-series, `/ɔː/`)**, governing how the vowel nucleus is pronounced.
- **Subscript Consonant (`C2`, `ជើងអក្សរ`)**: When a syllable starts with a consonant cluster, `C2` is written beneath or around `C1` via `U+17D2` (`្`) + consonant (e.g., `ខ្លា`, `ព្រៃ`).
- **Dependent Vowel (`V`, `ស្រៈនិស្ស័យ`)**: Attaches around the onset (`C1`/`C2`) to form the syllable nucleus (before, after, above, below, or multi-sided).
- **Independent Vowel (`ស្រៈពេញតួ`)**: Acts as both onset and nucleus in select words without needing a consonant carrier (e.g., `ឪ` in `ឪពុក`, `ឬ`).
- **Final Consonant / Coda (`C3`)**: Optional closing consonant. Khmer codas are restricted primarily to nasals (`/m, n, ŋ, ɲ/`), glides (`/w, j/`), and unreleased voiceless stops (`/p, t, k, ʔ/`).
- **Other Written Marks**:
  - Register shifters (`៉` / `៊`) flip consonant series.
  - Diacritics (`់`, `ំ`, `ះ`, `័`) shorten vowels, add nasal/aspirated endings, or mark loanword rules (`៍`, `៌`).

---

## B. Khmer Consonant Combinations

### 1. Clusters vs. Subscripts
**[Verified by source]** When two consonants appear together at the start of a syllable without an intervening vowel, the second is rendered as a **subscript (`ជើងអក្សរ`)**. Khmer permits complex onset clusters—including stop+liquid (`ត្រ`, `ប្រ`, `ខ្ល`), stop+stop (`ផ្ទ`), and nasal+stop (`ម្ត`)—that would be impossible at the start of English syllables.

### 2. Dominant Consonant Rules (How Clusters Are Read)
**[Verified by source]** When `C1` and `C2` belong to different register series:
1. **Stops and fricatives dominate sonorants**: Stops (`k, c, d, t, p, b`) and fricatives (`s, h`) are **dominant** over sonorants (nasals `ng, n, nh, m` and liquids/glides `r, l, v, y`). The dominant consonant sets the vowel register regardless of whether it is the base or subscript.
   - *Example*: In `ត្រី` (`trəj`, fish), `ត` (A-series stop) dominates `រ` (O-series sonorant), so `ី` is read in the A-series register.
2. **Equal strength (both stops/fricatives, or both sonorants)**: The **subscript (`C2`)** takes precedence and determines the register.
   - *Example*: In `ម្តាយ` (`mɗaːj`, mother), `ដ`/`ត` subscript behavior follows the cluster stop (*note: visually similar `្ដ`/`្ត` in `ម្តាយ` is spelled with `្ត` or `្ដ` depending on dictionary norm — verify Chuon Nath vs. RAC spelling*).

### 3. Common Learner Mistakes with Clusters
**[General explanation / Needs native-speaker review]**
- Inserting an extra spoken vowel between `C1` and `C2` (reading `ខ្លា` as two syllables instead of `/kʰlaː/`).
- Choosing the wrong register when reading clusters with `រ`, `ល`, `ម`, `វ` subscripts.
- Confusing visually similar subscripts (`្ដ` vs. `្ត`) when writing from memory.

---

## C. Khmer Word Segmentation Concepts

**[Verified by source / General explanation]**

| Unit | Khmer / Technical Concept | Definition | Example (`សាលារៀន` — school) |
| --- | --- | --- | --- |
| **Unicode character** | Code point (`U+17xx`) | Single UTF-8 / UTF-16 scalar unit in memory | `ស`, `ា`, `ល`, `ា`, `រ`, `ៀ`, `ន` (7 code points) |
| **Consonant** | `ព្យញ្ជនៈ` | One of the 33 base consonant letters | `ស`, `ល`, `រ`, `ន` |
| **Vowel** | `ស្រៈ` | Dependent vowel sign or independent vowel | `ា`, `ៀ` |
| **Consonant cluster** | `ព្យញ្ជនៈផ្គុំ` | Base consonant + `្` + subscript(s) forming one onset | `ខ្ល` in `ខ្លា`, `ក្ម` in `ក្មេង` |
| **Orthographic syllable** | **Khmer Character Cluster (KCC)** | Visual/typographic writing unit that cannot be broken without corrupting glyphs | `សា`, `លា`, `រៀន` |
| **Spoken syllable** | Phonological syllable | Auditory unit pronounced in speech (may differ from KCC) | `/saː/`, `/laː/`, `/riən/` |
| **Word** | `ពាក្យ` | Minimal meaningful standalone lexical item | `សាលា` (hall/school), `រៀន` (study) |
| **Compound word** | `ពាក្យផ្សំ` | Single lexical item formed from 2+ root words | `សាលារៀន` (school), `ផ្លែឈើ` (fruit) |
| **Phrase** | `ឃ្លា / កន្សោមពាក្យ` | Multi-word syntactic unit (Khmer normally lacks inter-word spaces) | `ទៅសាលារៀន` (go to school) |

### Why Splitting Khmer Text Character by Character Is Incorrect
**[Verified by source]** Splitting a Khmer string by code points (`String.split('')` or `runes`):
1. Detaches `U+17D2` (`្`) from its consonant, producing orphaned Coeng signs and dotted circles (`◌្ល`).
2. Detaches dependent vowels (`េ`, `ែ`, `ៀ`, `ា`, `ី`) from their base consonant.
3. Splits **1 syllable** into 3–6 meaningless code points (e.g., `ខ្លា` has 4 code points `ខ + ្ + ល + ា` but only **1 syllable**).

---

## D. Practical Khmer Examples (21 Real Words)

> **Pronunciation Note**: IPA transcriptions below are cited from Wiktionary entries gathered during Phase 2 research; `[Needs review]` marks entries needing native Khmer teacher confirmation for classroom dialect and segmentation suitability.

| # | Word | Category | Meaning | Orthographic Puzzle Segments | IPA (Wiktionary) | Difficulty | Segmentation Explanation & Status |
| :-: | --- | --- | --- | --- | --- | --- | --- |
| 1 | `ខ្លា` | Animals | Tiger | `["ខ្លា"]` (1 unit) | `/kʰlaː/` | Easy | **[Verified]** Single syllable with onset cluster `ខ្` + `ល` (`្ល`) + `ា`. Do not split for syllable ordering. |
| 2 | `ដំរី` | Animals | Elephant | `["ដំ", "រី"]` | `/ɗɑm.ˈrəj/` | Easy | **[Verified]** 2 clean orthographic & spoken syllables (`ដំ` + `រី`). Ideal for Syllable Ordering. |
| 3 | `ត្រី` | Animals / Food | Fish | `["ត្រី"]` (1 unit) | `/trəj/` | Easy | **[Verified]** Single syllable with `ត` + `្` + `រ` cluster (`្រ`) + `ី`. |
| 4 | `មេអំបៅ` | Animals / Nature | Butterfly | `["មេ", "អំ", "បៅ"]` | `/mei ʔɑm.ˈɓaw/` | Hard | **[Verified]** 3 clean orthographic & spoken syllables (`មេ` + `អំ` + `បៅ`). |
| 5 | `ឪពុក` | Family | Father | `["ឪ", "ពុក"]` | `/ʔəw.ˈpuk/` | Medium | **[Verified]** 2 syllables starting with independent vowel `ឪ`. |
| 6 | `ម្តាយ` | Family | Mother | `["ម្តាយ"]` (1 unit) | `/mɗaːj/` | Medium | **[Verified cluster / Needs spelling review]** Written as 1 KCC with `ម` + subscript `្ត`/`្ដ`. Do not split. |
| 7 | `កូនក្មេង` | Family / Daily Life | Kid / Child | `["កូន", "ក្មេង"]` | *(unverified IPA)* | Easy | **[Needs review]** Compound of 2 root words (`កូន` + `ក្មេង`), 2 clean segments. |
| 8 | `បាយ` | Food | Cooked rice / meal | `["បាយ"]` (1 unit) | `/ɓaːj/` | Easy | **[Verified]** 1 closed syllable (`ប` + `ា` + coda `យ`). |
| 9 | `ទឹក` | Food / Daily Life | Water | `["ទឹក"]` (1 unit) | `/tɨk/` | Easy | **[Verified]** 1 closed syllable (`ទ` + `ឹ` + coda `ក`). |
| 10 | `ផ្លែឈើ` | Food / Nature | Fruit | `["ផ្លែ", "ឈើ"]` | `/pʰlae ˈcʰəː/` | Medium | **[Verified]** Compound of 2 clean 1-syllable words (`ផ្លែ` + `ឈើ`). |
| 11 | `ផ្កា` | Nature | Flower | `["ផ្កា"]` (1 unit) | `/pʰkaː/` | Easy | **[Verified]** 1 syllable with `ផ` + `្` + `ក` cluster + `ា`. |
| 12 | `ភ្នំ` | Nature | Mountain / Hill | `["ភ្នំ"]` (1 unit) | `/pʰnum/` | Easy | **[Verified]** 1 syllable (`ភ` + `្` + `ន` + `ំ`). |
| 13 | `ទន្លេ` | Nature | River | `["ទន្លេ"]` *(do not split at `ន្ល`)* | `/tŭən.ˈlei/` | Medium | **[Verified analysis]** 2 *spoken* syllables (`/tŭən.lei/`), but `្ល` is a subscript attached to `ន`! Splitting as `["ទន", "្លេ"]` produces invalid `◌្លេ`. |
| 14 | `ព្រៃឈើ` | Nature | Forest | `["ព្រៃ", "ឈើ"]` | `/prɨj.chəə/` | Medium | **[Verified]** Compound of 2 clean words (`ព្រៃ` + `ឈើ`). |
| 15 | `បរិស្ថាន` | Nature / Education | Environment | `["ប", "រិ", "ស្ថាន"]` | `/paʔ.rəh.tʰaːn/` | Hard | **[Needs teacher review]** 3 orthographic chunks (`ប` + `រិ` + `ស្ថាន`), though spoken phonology groups `-rəh-` across the boundary. |
| 16 | `សៀវភៅ` | Education | Book | `["សៀវ", "ភៅ"]` | `/siəw pʰɨw/` | Medium | **[Verified]** 2 clean orthographic & spoken syllables (`សៀវ` + `ភៅ`). |
| 17 | `សាលារៀន` | Education | School | `["សា", "លា", "រៀន"]` | `/saː.ˈlaː riən/` | Hard | **[Verified]** Compound (`សាលា` + `រៀន`) cleanly divisible into 3 syllables (`សា`, `លា`, `រៀន`). |
| 18 | `គ្រូបង្រៀន` | Education | Teacher | `["គ្រូ", "បង្រៀន"]` *(compound-level)* | `/kruː ɓɑŋ.ˈriən/` | Hard | **[Verified analysis]** 3 *spoken* syllables, but `បង្រៀន` binds `ង` + subscript `្រ`. Split only as `["គ្រូ", "បង្រៀន"]`, never `["គ្រូ", "បង", "្រៀន"]`. |
| 19 | `ផ្ទះ` | Daily Life | House | `["ផ្ទះ"]` (1 unit) | `/pʰtĕəh/` | Medium | **[Verified]** 1 syllable (`ផ` + `្` + `ទ` + `ះ`). |
| 20 | `កសិករ` | Daily Life | Farmer | `["ក", "សិ", "ករ"]` | `/kaʔ.se.kɑː/` | Hard | **[Verified]** 3 clean orthographic & spoken segments (`ក` + `សិ` + `ករ`). |
| 21 | `ប្រទេស` | Education / Daily Life | Country | `["ប្រ", "ទេស"]` | `/prɑ.teih/` | Medium | **[Verified]** 2 clean orthographic segments (`ប្រ` + `ទេស`); first syllable has short reduced vowel in rapid speech. |

---

## E. Word Segmentation Rules for an Educational Game

1. **Choose words with clean, independent orthographic syllables for Syllable Ordering**:
   - Good candidates: `ដំរី` (`["ដំ", "រី"]`), `សៀវភៅ` (`["សៀវ", "ភៅ"]`), `សាលារៀន` (`["សា", "លា", "រៀន"]`), `មេអំបៅ` (`["មេ", "អំ", "បៅ"]`), `កសិករ` (`["ក", "សិ", "ករ"]`).
2. **Never split across a subscript (`U+17D2` Coeng) boundary**:
   - Words like `ទន្លេ` (`/tŭən.lei/`) and `បង្រៀន` (`/ɓɑŋ.riən/`) have 2 spoken syllables, **yet their second spoken syllable starts with a subscript consonant attached to the preceding coda consonant** (`ន្ល`, `ង្រ`). Splitting them creates illegal standalone segments (`្លេ`, `្រៀន`) that render with dotted circles (`◌`).
   - **Rule**: Either keep such words exclusively in Picture/Word Matching, or segment compounds only at safe non-subscript boundaries (e.g., `["គ្រូ", "បង្រៀន"]`).
3. **Handle compound words deliberately**:
   - 2-word compounds (`កូនក្មេង`, `ផ្លែឈើ`, `ព្រៃឈើ`) work well as 2-piece ordering puzzles for beginners, while 3-syllable words (`សាលារៀន`, `មេអំបៅ`, `កសិករ`) suit `hard` difficulty.
4. **Handle words with competing analyses transparently**:
   - Where orthographic KCC boundaries differ from spoken syllable boundaries (e.g., `បរិស្ថាន` `/paʔ.rəh.tʰaːn/` vs. `["ប", "រិ", "ស្ថាន"]`), mark the entry for native Khmer teacher review before enabling it in production puzzles.
5. **Represent verified segments explicitly in JSON**:
   - Always store an explicit `syllables` (or `verified_syllables`) array per entry and validate `syllables.join() == khmerWord` in automated tests.

---

## F. Khmer Unicode Considerations in Flutter/Dart

- **Visual syllables ≠ code point length**: `ខ្លា` = 4 code points, `ព្រៃ` = 4 code points, `ផ្ទះ` = 4 code points — all are **1 syllable**.
- **Code-point splitting breaks text**: Never compute syllable counts or puzzle tiles with `.split('')`, `.runes`, or `.characters` (grapheme clusters alone also do not equal linguistic syllables when final consonants are present, e.g., `រៀន` has coda `ន` as a separate grapheme!).
- **Preservation in Flutter/Dart**:
  - Load JSON strictly as UTF-8.
  - Keep canonical strings intact in `VocabularyItem`.
  - Render syllable chips directly from the verified JSON `syllables` list so each chip is a valid, self-contained Khmer orthographic unit.

---

## G. Important Rules for M3 Puzzle Developers

### 1. Picture Matching
- Any valid vocabulary item (1-syllable or multi-syllable, including `ទន្លេ` or `ផ្ទះ`) may be used safely because the Khmer word is displayed intact.
- Use `khmerWord` directly; never strip diacritics or slice substrings.

### 2. Word Matching
- Match canonical `id` and exact UTF-8 `khmerWord`.
- Compound words (`កូនក្មេង`, `ផ្លែឈើ`, `គ្រូបង្រៀន`) are strong candidates for matching Khmer words to English meanings.

### 3. Syllable Ordering
- **Only select items where `syllables.length >= 2` AND every segment in `syllables` starts with a full base consonant or independent vowel** (never `U+17D2` Coeng or a dependent vowel!).
- Exclude single-syllable words (`ខ្លា`, `ទឹក`, `ផ្កា`, `ភ្នំ`, `ផ្ទះ`) and subscript-bridged words (`ទន្លេ`, `ម្តាយ`) from syllable splitting.

### 4. Answer Validation
- Validate Syllable Ordering by checking:
  1. Each selected chip comes from the round's available `syllables` pool (respecting multiplicity).
  2. Exact ordered list equality with `target.syllables`.
  3. Exact UTF-8 equality `selectedSyllables.join() == target.khmerWord`.
- Never use fuzzy or approximate matching.

### 5. Khmer Vocabulary JSON
- Store explicit `syllables` arrays verified by a human/educator.
- Add automated dataset tests checking:
  - `syllables.join() == khmerWord`
  - **No segment begins with `U+17D2` (Coeng) or a combining vowel/diacritic** (prevents broken `ទន្លេ`-style splits!).
  - Track `verification_status` so unreviewed entries do not ship as verified production puzzles.

---

## H. Sources

1. **Chea Sok Huor, Top Rithy, Ros Pich Hemy (PAN Localization) — *Word Bigram vs. Orthographic Syllable Bigram in Khmer Word Segmentation***: [https://www.researchgate.net/publication/228972610_Word_Bigram_Vs_Orthographic_Syllable_Bigram_in_Khmer_Word_Segmentation](https://www.researchgate.net/publication/228972610_Word_Bigram_Vs_Orthographic_Syllable_Bigram_in_Khmer_Word_Segmentation) & [https://www.semanticscholar.org/paper/Word-Bigram-Vs-Orthographic-Syllable-Bigram-in-Khmer-Huor-Rithy/efd552cb5602a3cf1819eaf30e4ea98fab0800ff](https://www.semanticscholar.org/paper/Word-Bigram-Vs-Orthographic-Syllable-Bigram-in-Khmer-Huor-Rithy/efd552cb5602a3cf1819eaf30e4ea98fab0800ff)
2. **The Unicode Consortium — Khmer Code Chart (`U+1780`–`U+17FF`)**: [https://www.unicode.org/charts/PDF/U1780.pdf](https://www.unicode.org/charts/PDF/U1780.pdf)
3. **National Council of the Khmer Language (Royal Academy of Cambodia)**: [https://nckl.rac.gov.kh](https://nckl.rac.gov.kh)
4. **SEAsite Khmer Language & Writing System (Northern Illinois University)**: [https://seasite.niu.edu/khmer/](https://seasite.niu.edu/khmer/)
5. **Wiktionary Khmer Lexical Entries** (IPA citations for `ខ្លា`, `ដំរី`, `ទឹក`, `ផ្ទះ`, `សាលារៀន`, `ផ្លែឈើ`, `មេអំបៅ`, `ឪពុក`, `ម្តាយ`, `បាយ`, `ត្រី`, `ផ្កា`, `គ្រូបង្រៀន`, `កសិករ`, `បរិស្ថាន`, `ភ្នំ`, `ទន្លេ`).
