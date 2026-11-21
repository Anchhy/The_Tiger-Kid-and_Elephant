# License Verification Register

**Project**: *The Tiger, Kid, and Elephant* (`team_project`)  
**Policy**: Every candidate pack is verified individually prior to download. Assets under GPL, non-commercial (`CC BY-NC`), unverified copyright, or share-alike (`CC BY-SA`) affecting proprietary/team distribution are rejected or isolated.

---

## 1. Approved / Recommended Permissive Licenses

| License | Commercial Use | Modification | Redistribution in Game Build | Attribution Required | Representative Verified Sources |
| --- | --- | --- | --- | --- | --- |
| **CC0 1.0 Universal (Public Domain Dedication)** | Yes | Yes | Yes (without source disclosure) | **No** (courtesy credit encouraged) | Kenney (`kenney.nl/assets/*`: UI Pack, Foliage Sprites, Pirate Pack, Animal Pack Redux, Interface Sounds, RPG Audio), OGA CC0 16x16 Fruits/Food, SVG Repo CC0 items |
| **Public Domain (`PD-old`)** | Yes | Yes | Yes | Recommended historical citation | Wikimedia Commons `Category:Voyage au Cambodge (1880)` by Louis Delaporte (died 1925) |
| **Apache License 2.0** | Yes | Yes | Yes | **Yes** (retain copyright, license text & `NOTICES`) | Flutter Material Rounded Icons (`Icons.*_rounded`), `googlefonts/noto-emoji` SVG/PNG visual resources (note: font binary is SIL OFL 1.1) |
| **MIT License** | Yes | Yes | Yes | **Yes** (retain copyright + MIT permission notice) | Phosphor Icons (`phosphoricons.com`) |
| **ISC License** | Yes | Yes | Yes | **Yes** (retain copyright + ISC notice) | Lucide (`lucide.dev`; note: original Feather subset carries MIT) |
| **CC BY 3.0** | Yes | Yes | Yes (in compiled game/app) | **Mandatory** (artist name + title + license + source link) | Game-icons.net (`game-icons.net` — Lorc, Delapouite, etc.) |

---

## 2. Conditionally Restricted / Rejected Licenses

| License / Term | Source Example | Legal / Project Impact | Decision |
| --- | --- | --- | --- |
| **CC BY-SA 3.0 / 4.0 & GPL 3.0** | Universal LPC Character Generator, some OpenGameArt tilesets (e.g., DawnLike dual tags) | Share-Alike / GPL copyleft can require derivative composite spritesheets or redistribution under compatible terms | **Rejected** for composite character sheets |
| **Custom Store License (No raw asset redistribution)** | CraftPix Freebies (`craftpix.net/file-licenses/`) | Commercial games allowed, **but prohibits placing raw source assets into public GitHub repositories** as standalone downloadable packs | **Rejected for open public Git repos**; use CC0/Apache/CC-BY packs only |
| **CC BY-NC / CC BY-NC-SA** | Various itch.io / OpenGameArt uploads | Explicitly bans commercial release or paid educational distribution | **Rejected** |
| **Unlicensed / "Free to play" without explicit CC0/CC-BY/MIT/Apache/CC-BY text** | Unlabeled itch.io or random blog PNGs | Missing commercial/modification permission grants | **Rejected** unless author license file is verified |

---

## 3. Repository & Dependency Safety Verification

1. Do not add external pub dependencies to `team_project/pubspec.yaml` (`pubspec.lock` belongs to M5).
2. Store third-party `LICENSE.txt` and per-pack attribution alongside downloaded packs once approved in Phase 8.
3. Keep realistic Wikimedia architectural plates strictly for non-gameplay cultural info overlays so perspective/style consistency is never broken.
