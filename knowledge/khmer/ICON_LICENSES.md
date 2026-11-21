# Icon & UI Asset License Compliance Audit

**Project**: *The Tiger, Kid, and Elephant*  
**Module**: M3 — Khmer Puzzle Developer  
**Dependency Policy**: Zero external icon packages added (`pubspec.yaml` `dependencies:` and `pubspec.lock` unchanged).

---

## 1. Active Project Icon & UI Sources (Currently Shipped)

| Asset Class | Publisher / Origin | License | Commercial Use | Modification Allowed | Attribution Required | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| **Tier 1 Vector Icons** (`Icons.*_rounded` via `package:flutter/material.dart`) | Google Material Design Icons (`google/material-design-icons`, bundled inside Flutter SDK) | **Apache License 2.0** | Yes | Yes | Retain Apache 2.0 notice where applicable (`NOTICES`) | Zero third-party pub dependency; crisp at all DPIs. |
| **Tiers 2–4 Custom Angkor UI & Cultural Sprites** (`assets/images/buttons/`, `icons/`, `levels/`, `rewards/`, `characters/`, `vocabulary/`, `backgrounds/`) | Project M3 Original Storybook Artwork (*The Tiger, Kid, and Elephant* team assets) | **Project Original / Team Internal Rights** | Team project scope | Yes (within M3 assets) | Internal M3 credit | Includes cleaned `icon_tiger_threat.png`, `icon_hint_lantern.png`, `reward_single_star.png`, 15 character PNGs, and 12 vocabulary illustrations. |

---

## 2. Evaluated External Libraries (Reference Matrix — Not Bundled Unless Approved)

Before finalizing the zero-dependency Option A hybrid system, the following reputable icon/game asset libraries were audited for license safety:

| Resource | Publisher | License | Commercial Use | Attribution Rule | Adoption Decision |
| --- | --- | --- | --- | --- | --- |
| **Google Material Symbols / Icons** | Google | **Apache 2.0** | Yes | Notice/license text recommended | **Adopted (Built-in Flutter SDK)** for Tier 1 functional icons. |
| **Kenney UI Pack & Game Assets** (`kenney.nl`) | Kenney | **CC0 1.0 Universal (Public Domain)** | Yes | None legally required (credit optional) | **Safe Reference**: Excellent fallback if generic vector-free UI chrome PNGs are ever needed, though current carved Angkor artwork is tighter thematically. |
| **Lucide Icons** (`lucide.dev`) | Lucide Contributors | **ISC License** | Yes | Retain copyright + ISC notice | **Not needed**: Flutter Material Rounded covers all Tier 1 functional glyphs without adding third-party dependencies. |
| **Phosphor Icons** (`phosphoricons.com`) | Phosphor Icons | **MIT License** | Yes | Retain copyright + MIT notice | **Not needed**: `phosphor_flutter` package omitted to avoid touching shared `pubspec.yaml` / `pubspec.lock`. |
| **Game-icons.net** (`game-icons.net`) | Delapouite, Lorc, Skoll & contributors | **CC BY 3.0** | Yes | **Mandatory per-icon creator credit** | **Deferred**: Would require per-icon creator tracking & custom SVG tooling (`flutter_svg`); custom Angkor icons match Cambodian aesthetic better. |
| **OpenGameArt.org** (`opengameart.org`) | Mixed individual community artists | **Varies per asset** (`CC0`, `CC-BY 3.0/4.0`, `GPL 2/3`, `OGA-BY`) | **Depends on upload** | Often mandatory; **GPL incompatible** with non-GPL proprietary app store builds | **Strict Guardrail**: Never bulk-download from OpenGameArt without checking each file's exact license page and rejecting GPL/SA-only uploads. |

---

## 3. Security & Asset Hygiene Rules Verified

1. No `flutter_svg` or unverified third-party icon packages were introduced into `team_project/pubspec.yaml` or `team_project/pubspec.lock`.
2. Every binary asset in `assets/images/` is a local static `.png` or `.jpg` validated by `vocabulary_dataset_test.dart` via `rootBundle.load(...)`.
3. Every `Image.asset` UI surface provides an explicit `errorBuilder` fallback icon so missing or corrupt assets never crash a child's puzzle session.
