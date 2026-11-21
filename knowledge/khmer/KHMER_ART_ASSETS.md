# Khmer-Culture Character & Map Assets Guide

All generated character sheets and the playable Angkor temple-jungle maze map are stored inside the Flutter project asset structure and registered in [pubspec.yaml](../../pubspec.yaml).

## 1. Asset Locations

| Asset | Project Path | Cultural & Game Details |
| --- | --- | --- |
| **Cambodian Kid Explorer** | `assets/images/characters/kid_character_sheet.jpg` | 3/4 turnaround hero pose + 4 animation keyframes (`Idle`, `Walk`, `Run`, `Startled`). Wears a traditional red-and-white checkered **Krama (`ក្រមា`)** and brown **Sampot Chang Kben (`សំពត់ចងក្បិន`)** with backpack and parchment map. |
| **Bad Tiger** | `assets/images/characters/tiger_character_sheet.jpg` | Snarling 3/4 prowling hero pose + 4 aligned side-view walking/stalking keyframes. |
| **Kind Cambodian Elephant** | `assets/images/characters/elephant_character_sheet.jpg` | Welcoming 3/4 hero pose + 4 aligned side-view walking keyframes adorned in saffron-gold and crimson **Kbach Angkor (`ក្បាច់`)** royal brocade with golden lotus-petal tassels and forehead crown ornament. |
| **Angkor Maze Level Map** | `assets/images/maps/angkor_maze_level_map.jpg` | 3/4 overhead playable maze featuring **Ta Prohm Spung roots** over the left *Gopura* entrance, **laterite** & carved **sandstone** walls, 3 golden **Kbach** checkpoint steles, **Rumduol (`ផ្ការំដួល`)** & **lotus (`ផ្កាឈូក`)** blossoms, and **seven-headed Khmer Naga balustrades (`នាគក្បាល ៧`)** at the right exit. |

## 2. `pubspec.yaml` Registration

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/data/
    - assets/images/vocabulary/
    - assets/images/characters/
    - assets/images/maps/
```

For cultural research references, see [KHMER_CULTURE.md](./KHMER_CULTURE.md).
