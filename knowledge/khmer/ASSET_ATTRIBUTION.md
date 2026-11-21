# Asset Attribution & Credits

This document records required and courtesy attributions for icons, illustrations, and UI artwork used in the M3 Khmer Puzzle module of *The Tiger, Kid, and Elephant*.

---

## 1. Active Runtime Assets

### Functional UI Vector Icons (Tier 1)
- **Source**: Material Design Icons (bundled with Flutter SDK `package:flutter/material.dart`)
- **Author / Publisher**: Google
- **License**: Apache License 2.0 (<https://www.apache.org/licenses/LICENSE-2.0>)
- **Usage**: Rounded functional navigation, close, volume, check, retry, help, and warning glyphs inside `GameIcon`, `PuzzleAnswerTile`, `GameConfirmationDialog`, `GameNotificationBanner`, and `PuzzleHeader`.

### Angkor Storybook Game Art, Icons & Khmer Vocabulary Illustrations (Tiers 2–4)
- **Source**: Project M3 Asset Repository (`assets/images/`)
- **Author / Scope**: SEK THORN / M3 Khmer Puzzle & Cultural Illustration Pipeline
- **Usage**: Carved stone round buttons, temple HUD emblems (`icon_angkor_coin.png`, `icon_checkpoint_stele.png`, `icon_hint_lantern.png`, `icon_tiger_threat.png`), star & duo rewards (`reward_single_star.png`, `reward_three_stars.png`, `reward_victory_duo.png`), temple level nodes, character sprites, and 12 illustrated Cambodian starter nouns.

---

## 2. Template for Adding Any Future Third-Party Assets

If any contributor later imports an approved external CC-BY or OpenGameArt/Game-icons.net asset, record an entry below **before** merging:

```markdown
- **Asset File**: assets/images/<path>
- **Source URL**: https://...
- **Creator / Author**: <Exact Creator Name>
- **License**: <CC0 1.0 | CC BY 4.0 | MIT | Apache 2.0>
- **Attribution Text**: "<Title>" by <Author>, licensed under <License>
```
