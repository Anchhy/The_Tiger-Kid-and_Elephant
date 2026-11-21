# M3 Asset Catalog — Integrated Non-AI Open Assets & Audit

**Project**: *The Tiger, Kid, and Elephant* (`team_project`, `tiger_kid_elephant`)  
**Module**: M3 — Khmer Puzzle Developer (`lib/features/khmer_puzzle/`)  
**Last Updated**: Phase 9–13 Integration (Zero AI images used for integrated Categories E, F icons, A foliage, B neutral tiles, C heritage references, G audio)

---

## 1. Integrated Non-AI Asset Packs (`team_project/assets/`)

| Asset name | Category | Source | Creator | License | Format | Dimensions | Style | Commercial use | Modification | Attribution | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **FluentUI Emoji 3D Vocabulary Pack (15 words)** | E (Vocabulary Clues: Tiger, Droplet/Water, Elephant, Child/Kid, Lotus/Flower, Open book/Book, Mango/Fruit, Deciduous tree/Forest, Hut/House, Globe Asia/Country, School, Butterfly, Palm tree/Environment, Farmer, Sun behind cloud/Weather) | [github.com/microsoft/fluentui-emoji](https://github.com/microsoft/fluentui-emoji) | Microsoft Corporation Design Team | **MIT License** (`assets/images/vocabulary/LICENSE-MIT.txt`) | PNG (RGBA) | `256x256` | Cohesive clean illustrated 3D-shaded cartoon | Allowed | Allowed | Retain MIT notice | **Approved & Integrated** |
| **FluentUI Emoji Star Rewards** (`reward_single_star.png`, `reward_three_stars.png`) | F / Rewards | [github.com/microsoft/fluentui-emoji](https://github.com/microsoft/fluentui-emoji) (`assets/Star/3D`) | Microsoft Corporation | **MIT License** | PNG (RGBA) | `128x128`, `320x140` | Crisp 3D-shaded vector-cartoon star | Allowed | Allowed | Retain MIT notice | **Approved & Integrated** |
| **FluentUI Emoji Tiger Head Threat** (`icon_tiger_threat.png`) | D / HUD Threat Badge | [github.com/microsoft/fluentui-emoji](https://github.com/microsoft/fluentui-emoji) (`assets/Tiger face/3D`) | Microsoft Corporation | **MIT License** | PNG (RGBA) | `96x96` | Clean friendly cartoon | Allowed | Allowed | Retain MIT notice | **Approved & Integrated** |
| **Game-icons.net Pack (11 icons + HUD icon upgrades)** | F (UI & HUD: `compass`, `open_book`, `coins`, `cog`, `speaker`, `padlock`, `trophy`, `stars_stack`, `candle_flame`, `tied_scroll`, `light_bulb` + `icon_hint_lantern`, `icon_angkor_coin`, `icon_checkpoint_stele`) | [game-icons.net](https://game-icons.net/) | **Lorc**, **Delapouite** (`assets/icons/game_icons/ATTRIBUTION-CC-BY-3.0.txt`) | **CC BY 3.0** | PNG (RGBA) | `128x128` | Clean crisp Angkor sepia (`#3E2A1D`) / gold (`#D4921D`) icons | Allowed | Allowed | **Required per artist** | **Approved & Integrated** |
| **Google Material Rounded (`Icons.*_rounded`)** | F (Functional Chrome UI) | Flutter SDK (`package:flutter/material.dart`) | Google | **Apache License 2.0** | Vector glyph | Scalable (`20–28dp`) | Clean rounded outline/fill | Allowed | Allowed | Retain Apache 2.0 notice | **Approved & Active** |
| **Kenney UI Pack (Yellow & Extra)** | F (UI Buttons, Panels, Sliders, Arrows, Checks) | [kenney.nl/assets/ui-pack](https://kenney.nl/assets/ui-pack) | Kenney | **CC0 1.0 Universal** (`assets/ui/kenney_ui/License.txt`) | PNG (RGBA) | 130 curated sprites (`button_rectangle_*`, `check_*`, arrows) | Clean warm 2D vector game UI | Allowed | Allowed | Not required | **Approved & Integrated** |
| **Kenney Foliage Sprites (Moss-tinted)** | A (Neutral Grass & Plant Cutouts) | [kenney.nl/assets/foliage-sprites](https://kenney.nl/assets/foliage-sprites) | Kenney | **CC0 1.0 Universal** (`assets/environments/foliage/License.txt`) | PNG (RGBA) | 16 sprites tinted `#4D7741`–`#5E8A48` | Clean crisp 2D plant shapes | Allowed | Allowed | Not required | **Approved & Integrated** |
| **Kenney Pirate Pack (Neutral Sand, Water & Wood Dock Tiles Only)** | A / B (Neutral Water & Riverbank Tiles) | [kenney.nl/assets/pirate-pack](https://kenney.nl/assets/pirate-pack) | Kenney | **CC0 1.0 Universal** (`assets/environments/docks/License.txt`) | PNG (RGBA) | 24 neutral tiles (`tile_01.png`–`tile_24.png`, ship/cannon props excluded) | Clean 2D top-down tiles | Allowed | Allowed | Not required | **Approved & Integrated (Partial Neutral)** |
| **Voyage au Cambodge (1880) Historical Plates (3 scans)** | C (Angkor Wat & Bayon Cultural Heritage Reference) | [Wikimedia Commons](https://commons.wikimedia.org/wiki/Category:Voyage_au_Cambodge_(1880)._Illustrations) | Louis Delaporte (1842–1925) | **Public Domain (`PD-old`)** (`assets/environments/angkor_reference/ATTRIBUTION-PD.txt`) | JPG | `1024x699`, `1024x561`, `1024x476` | Historical woodcut engraving | Allowed | Allowed | Cited in `ATTRIBUTION.md` | **Approved Heritage Reference Only** |
| **Kenney Interface Sounds (12 clips)** | G (UI Clicks, Confirmations, Back/Close) | [kenney.nl/assets/interface-sounds](https://kenney.nl/assets/interface-sounds) | Kenney | **CC0 1.0 Universal** (`assets/audio/ui/License.txt`) | OGG | 12 clips | Crisp UI SFX | Allowed | Allowed | Not required | **Approved & Integrated** |
| **Kenney RPG Audio (12 clips)** | G (Book flips, cloth, wood interaction) | [kenney.nl/assets/rpg-audio](https://kenney.nl/assets/rpg-audio) | Kenney | **CC0 1.0 Universal** (`assets/audio/rpg/License.txt`) | OGG | 12 clips | Clean game foley SFX | Allowed | Allowed | Not required | **Approved & Integrated** |

---

## 2. Temporary Legacy Placeholders Retained Pending Custom Human Artist Replacement

| Asset Group | Location | Notes |
| --- | --- | --- |
| **Character Sprites & Maze Mockups** | `assets/images/characters/`, `assets/images/backgrounds/`, `assets/images/buttons/`, `assets/images/levels/`, `assets/images/maps/`, `assets/images/mockups/`, `assets/images/rewards/reward_victory_duo.png` | Retained temporarily so existing M2/M3 prototype layouts & automated asset-existence tests keep working while custom Cambodian human-drawn artwork is produced per [ASSET_MISSING_LIST.md](./ASSET_MISSING_LIST.md). |
