# M3 Human-Illustrated Art Direction & Quality Guide

**Game:** *The Tiger, Kid, and Elephant* (Khmer Educational Adventure Game)  
**Target Audience:** Children aged 8–12  
**Art Goal:** Warm, hand-drawn commercial storybook ink-and-watercolor illustrations with authentic Cambodian cultural details—free of glossy 3D AI plastics, neon glare, harsh bounding boxes, or mixed Southeast Asian motifs.

---

## 1. Unified Hand-Crafted Illustration Standards

### Linework & Shading
- **Ink Outlines:** Warm dark sepia-umber ink (`#3E2A1D` to `#4A3525`) with subtle organic stroke-weight variation (never rigid CAD vectors or harsh pitch-black `#000000` lines).
- **Wash & Texture:** Soft matte watercolor washes on warm textured palm-leaf paper (`#FBF4E4`)—no plastic 3D bevels, chrome glare, or artificial neon bloom.
- **Transparency & Framing:** All character poses, HUD icons, stone buttons, reward stars, level nodes, and vocabulary illustrations use clean edge-keyed `Format32bppArgb` PNG transparency with anti-aliased watercolor feathering so illustrations blend seamlessly onto sandstone cards and temple backgrounds.

### Controlled Angkor Mineral & Botanical Color Palette
| Token / Role | Hex | Cultural Source |
| :--- | :--- | :--- |
| Palm-Leaf Parchment | `#FBF4E4` | Dried *Sluek Rith* manuscript leaves |
| Angkor Sandstone | `#F5EAD4` / `#C5AC82` | Banteay Srei & Angkor Wat warm stone |
| Laterite Terracotta | `#B94A2F` | Khmer laterite temple foundations |
| Rumduol Gold | `#D4921D` | National flower & gilded *Kbach* accents |
| Jungle Moss Green | `#4D7741` | Mossy *Ta Prohm* banyan courtyards |
| Mekong Turquoise | `#5BA4A4` | Glazed Angkorian celadon & river water |
| Sepia Ink | `#3E2A1D` / `#4A3525` | Natural hand-inked nib linework |

---

## 2. Cambodian Cultural Authenticity Rules

1. **Khmer Farmer Attire (`farmer.png`):**
   - Must wear a traditional Cambodian woven sugar-palm hat **`មួកស្លឹកត្នោត` (*Muok Sleuk Thnot*)** with a **rounded/tiered woven dome crown**, red-and-white checkered **Krama (`ក្រមា`)** scarf, indigo work shirt, and harvested golden paddy sheaves—explicitly avoiding pointed conical hats (*nón lá*) from neighboring traditions.
2. **Kid Explorer Attire (`kid_hero.png`, `kid.png`):**
   - Wears a traditional red-and-white checkered **Krama (`ក្រមា`)** and brown draped **Sampot Chang Kben (`សំពត់ចងក្បិន`)**.
3. **Khmer Architecture & Objects:**
   - **Country & Maze:** Angkor Wat multi-towered sanctuary silhouette, slender **Thnot (`ដើមត្នោត`)** sugar palms, mossy *Gopura* arches, and **seven-headed Naga (`នាគក្បាល ៧`)** stone balustrades (`angkor_temple_maze_bg.jpg`).
   - **House & School (`house.png`, `school.png`):** Elevated traditional Khmer wooden stilt house with clay roof tiles and stair ladder; rural Cambodian schoolhouse flying the Cambodian national flag.
   - **Book (`book.png`):** Open illustrated storybook paired with a ribbon-bound **Sastra Sluek Rith (`សាស្ត្រាស្លឹករឹត`)** palm-leaf manuscript.
   - **Flower (`flower.png`):** Cambodian national **Rumduol (`ផ្ការំដួល`)** blossoms and sacred pink **lotus (`ផ្កាឈូក`)**.

---

## 3. Individual Asset Quality Control Audit

| Category | Assets Audited | Refinements Applied |
| :--- | :--- | :--- |
| **Main Characters (15 PNGs)** | `kid_hero`, `kid_idle_map`, `kid_walk_map`, `kid_run`, `kid_startled`, `tiger_hero`, `tiger_walk_1..4`, `elephant_hero`, `elephant_walk_1..4` | Flood-keyed trapped cream islands inside `elephant_hero` (`(370,330)`, `(310,350)`) and `tiger_hero` (`(150,290)`, `(310,290)`); cleared elbow wedge on `kid_startled`; stripped bottom sheet baseline rules while preserving 100% opaque whiskers/teeth/eyes/tusks. |
| **Vocabulary Illustrations (15 PNGs)** | `tiger`, `elephant`, `water`, `kid`, `flower`, `book`, `fruit`, `forest`, `house`, `country`, `school`, `butterfly`, `environment`, `farmer`, `weather` (flat + categorized subfolders) | Replaced pointed conical hat on `farmer.png` with a hand-painted rounded Cambodian *Muok Sleuk Thnot* (`មួកស្លឹកត្នោត`) dome crown; eliminated 16px edge-clamping barcode streaks on `tiger.png` and `kid.png`; converted all 15 to clean transparent PNGs with soft anti-aliased edges. |
| **Backgrounds (2)** | `angkor_temple_maze_bg.jpg`, `angkor_parchment_header_bg.png` | Preserved original high-res watercolor brushwork; paired with subtle paper-grain parchment vignette in `VocabularyImageFrame`. |
| **UI Buttons & HUD Icons (11 PNGs)** | 7 stone buttons + `icon_tiger_threat`, `icon_checkpoint_stele`, `icon_angkor_coin`, `icon_hint_lantern` | Re-cropped `icon_tiger_threat` (`46,25,72,72`) inside the HUD border so all corners key cleanly transparent; refined circular stone rims and glowing lantern trim. |
| **Rewards & Level Landmarks (7 PNGs)** | `reward_single_star`, `reward_three_stars`, `reward_victory_duo`, `level_node_completed`, `level_node_active`, `level_gate_locked`, `level_stele_checkpoint` | Shaped transparent carved arch contours (`level_gate_locked`, `level_stele_checkpoint`) with warm `#4A3525` hand-inked borders and cleaned earth edges around `level_node_completed` and `level_node_active`. |
