# Khmer Writing System and Unicode Reference

> **Status**: Documented from Unicode Standard & linguistic references. Linguistic/pedagogical choices for Cambodian primary-school learners require native Khmer educator review.

## 1. Script Classification & Overview

Khmer is an **abugida** (alphasyllabary) derived from the ancient Brahmi script. Every base consonant carries an inherent vowel unless modified by a dependent vowel sign or diacritic. Unlike alphabetic scripts, a single visual Khmer orthographic syllable is composed of multiple stacked or surrounding Unicode code points.

---

## 2. Khmer Unicode Block (`U+1780`–`U+17FF`)

The primary Khmer Unicode block contains 128 code points (plus Khmer lunar calendar symbols in `U+19E0`–`U+19FF`):

| Range | Category | Notes |
| --- | --- | --- |
| `U+1780`–`U+17A2` | **Consonants (33 letters)** + 2 deprecated (`U+17A3`, `U+17A4` are independent vowels) | Base consonants `ក` through `អ`; divided into two register series |
| `U+17A3`–`U+17B3` | **Independent Vowels** | Standalone syllable nuclei (mostly in loanwords/special words); `U+17A3` & `U+17A4` are deprecated |
| `U+17B4`–`U+17B5` | **Inherent Vowels** | Invisible marks deprecated/discouraged in standard text |
| `U+17B6`–`U+17C5` | **Dependent Vowel Signs** | Attach before, after, above, below, or around a base consonant |
| `U+17C6`–`U+17D3` | **Diacritics & Signs** | Modifiers (`ំ`, `ះ`, `ៈ`, `៉`, `៊`, `់`, `៌`, `៍`, `៎`, `៏`, `័`, `៑`, **Coeng `្` at `U+17D2`**) |
| `U+17D4`–`U+17DC` | **Punctuation & Symbols** | `។` Khan (`U+17D4`), `៕` Bariyoosan (`U+17D5`), `៛` Riel (`U+17DB`), etc. |
| `U+17E0`–`U+17E9` | **Khmer Digits** | `០` (0) through `៩` (9) |

### Key Diacritic & Subscript Code Points (Verified)

- `U+17D2` (`្`) — **KHMER SIGN COENG**: Invisible control/combining mark instructing the text shaper to render the *following* consonant as a subscript (`ជើងអក្សរ`) beneath the base consonant.
- `U+17C6` (`ំ`) — **KHMER SIGN NIKAHIT**: Final nasalization (`-m` / `-am`).
- `U+17C7` (`ះ`) — **KHMER SIGN REAHMUK**: Final aspiration/glottal stop (`-ah`).
- `U+17C8` (`ៈ`) — **KHMER SIGN YUUKALEAPINTU**: Short glottalized vowel marker (often in Pali/Sanskrit loanwords).
- `U+17C9` (`៉`) — **KHMER SIGN MUUSIKATOAN**: Consonant shifter (shifts certain O-series consonants to A-series).
- `U+17CA` (`៊`) — **KHMER SIGN TRIISAP**: Consonant shifter (shifts certain A-series consonants to O-series).
- `U+17CB` (`់`) — **KHMER SIGN BANTOC**: Shortens vowel length.
- `U+17CC` (`៌`) — **KHMER SIGN ROBAT**: Historical/Sanskrit `r` marker above consonant.
- `U+17CD` (`៍`) — **KHMER SIGN TOANDAKHIAT**: Silences/cancels the consonant it sits above (loanwords).
- `U+17CE` (`៎`) — **KHMER SIGN KAKABAT**: Exclamation/rising intonation mark.
- `U+17CF` (`៏`) — **KHMER SIGN AHSDA**: Marks certain single-consonant words/particles (e.g., `ក៏`).
- `U+17D0` (`័`) — **KHMER SIGN SAMYOK SANNYA**: Modifies/shortens vowel quality in specific words.

---

## 3. Consonant Series (Register System)

All 33 Khmer consonants belong to one of two historical register series:

1. **First Series (A-Series)**: Inherent vowel `-â` / `-ɑː` (e.g., `ក`, `ខ`, `ច`, `ត`, `ប`, `ស`).
2. **Second Series (O-Series)**: Inherent vowel `-ô` / `-ɔː` (e.g., `គ`, `ឃ`, `ជ`, `ទ`, `ព`, `ម`, `រ`, `ល`).

Because the same dependent vowel sign is pronounced differently depending on the consonant's series, consonant + vowel combinations form tightly coupled orthographic units.

---

## 4. Logical Unicode Order vs. Visual Rendering Order

Unicode encodes Khmer in **logical typing/phonological order**, NOT visual left-to-right screen order.

Standard canonical cluster sequence:

```text
Base Consonant (or Independent Vowel)
  -> [Robat U+17CC]
  -> [Coeng U+17D2 + Subscript Consonant] (up to 2 subscripts)
  -> [Register Shifter: U+17C9 or U+17CA]
  -> [Dependent Vowel: U+17B6..U+17C5]
  -> [Trailing Sign: U+17C6, U+17C7, U+17CB, U+17CD, U+17D0, etc.]
```

### Example: `ខ្លា` ("Tiger")

- **Visual result**: `ខ` with subscript `្ល` underneath and `ា` to the right.
- **Logical UTF-8 sequence**:
  1. `ខ` (`U+1781` — base consonant)
  2. `្` (`U+17D2` — Coeng)
  3. `ល` (`U+179B` — subscript consonant)
  4. `ា` (`U+17B6` — dependent vowel `AA`)

### Example with Pre-posed Vowel: `ក្មេង` ("Kid / Child" root)

- Visually, `េ` (`U+17C1`) appears to the **left** of `ក`, yet in Unicode memory it is stored **after** `ក` + `្` + `ម` (`ក` -> `្` -> `ម` -> `េ` -> `ង`).

---

## 5. Rules for Dart & Flutter Implementation

1. **Never split by `String.split('')` or `runes`**: Splitting code points breaks `U+17D2` (Coeng), dependent vowels, and combining marks into unreadable or corrupted glyphs.
2. **Preserve exact UTF-8**: Always store and compare Khmer strings as complete UTF-8 strings from verified JSON data.
3. **Never infer syllable count from code-point length**: `ខ្លា` is **4 Unicode code points** (`ខ` + `្` + `ល` + `ា`), yet it is **1 spoken and orthographic syllable**.
4. **Test font rendering on Android**: Ensure the selected app font (and Android fallback font) renders multi-subscript clusters and diacritics without clipping or dotted circles (`◌`).

---

## 6. Sources

1. **The Unicode Consortium — Khmer Code Chart (`U+1780`–`U+17FF`)**: [https://www.unicode.org/charts/PDF/U1780.pdf](https://www.unicode.org/charts/PDF/U1780.pdf)
2. **National Council of the Khmer Language (Royal Academy of Cambodia)**: [https://nckl.rac.gov.kh](https://nckl.rac.gov.kh)
3. **SEAsite Khmer Language & Writing System (Northern Illinois University)**: [https://seasite.niu.edu/khmer/](https://seasite.niu.edu/khmer/)
