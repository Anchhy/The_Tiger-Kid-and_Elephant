# Missing Assets & Cultural Gap Analysis

**Project**: *The Tiger, Kid, and Elephant* (`team_project`)  
**Principle**: Never mislabel unrelated European/western packs as Cambodian, and never generate replacement images with AI.

---

## 1. Completed Non-AI Replacements vs Remaining Custom Art Gaps

- **Resolved in Phase 9 Integration**:
  - **Category E (15 Vocabulary Clues)**: Replaced cleanly with Microsoft **FluentUI Emoji (`MIT`)** artwork.
  - **Category F (UI Chrome & Game Icons)**: Integrated **Kenney UI Pack (`CC0`)**, **Game-icons.net (`CC BY 3.0`)**, **FluentUI Stars (`MIT`)**, and **Flutter Material Rounded (`Apache 2.0`)**.
  - **Category A/B Neutral Tiles & G Audio**: Integrated **Kenney Foliage Sprites** (moss-tinted `CC0`), neutral riverbank/dock tiles (`CC0`), and **Kenney UI/RPG Audio (`CC0`)**.
  - **Category C Heritage Reference**: Integrated 3 **Louis Delaporte (1880) Public Domain** plates from Wikimedia Commons for cultural reference screens.

---

## 2. Remaining Culturally Specific Assets Not Available in Free Open Packs

| Gap ID | Needed Asset | Category | Why Free Packs Are Unsuitable | Recommended Path Forward |
| --- | --- | --- | --- | --- |
| **GAP-01** | **Cambodian Rural Stilt Houses (`ផ្ទះខ្មែរ`), Bamboo Fences & Sugar Palm (`ដើមត្នោត`) Top-Down Tiles** | A (Main Environment) | Free packs (Kenney, itch.io village sets) depict European timber cottages or pixel medieval towns. | Pair neutral grass/foliage (`assets/environments/foliage/`) with team-illustrated top-down Khmer village tiles. |
| **GAP-02** | **Tonle Sap Floating Stilt Village, Khmer Wooden Sampan Boats & Fishing Nets** | B (Tonle Sap) | *Pirate Pack* ships have western square sails/cannons (excluded); free itch pixel packs mismatch our clean vector art. | Keep only neutral riverbank/water tiles (`assets/environments/docks/`) and draw/commission Tonle Sap floating houses & wooden sampans. |
| **GAP-03** | **Top-Down Angkor Wat / Bayon Sandstone & Laterite Maze Tileset** | C (Angkor & Bayon) | No CC0/CC-BY free game tileset captures authentic Khmer four-faced Bayon towers and bas-relief galleries. | Display **Delaporte 1880 Public Domain engravings** (`assets/environments/angkor_reference/`) in chapter intros while custom top-down Angkor tiles are crafted by human artists. |
| **GAP-04** | **Top-Down Cambodian Child (`Kid` with *krama*), Khmer Villagers/Vendors & Matching Animated Elephant / Tiger** | D (Player & NPCs) | Universal LPC carries GPL 3.0 / CC-BY-SA copyleft limits + medieval knights; Kenney characters are modern soldiers. | Keep temporary character placeholders clearly marked until M4/human artists draw original Cambodian adventure sprites. |
