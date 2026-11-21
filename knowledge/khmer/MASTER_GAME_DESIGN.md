# Master Game Design & Player Experience Blueprint — *The Tiger, Kid, and Elephant*

> **Goal**: Transform the educational puzzle-maze concept into a cohesive, thrilling, culturally authentic Cambodian mobile game that kids genuinely enjoy replaying while learning Khmer.

---

## 1. Core Gameplay Loop & Realistic Tension

### A. Reactive "Bad Tiger" AI (3 States)
Instead of moving at a flat robotic speed, give the Tiger believable jungle-predator behavior using the 4-frame stalking/walking sheet:
1. **Prowling (`លបមើល`)**: Patrols near the *Gopura* entrance and main corridors at steady pace.
2. **Alerted (`ភ្ញាក់ផ្អើល`)**: When the player makes a wrong puzzle attempt at a checkpoint stele, the stone rumbles and the Tiger turns toward the sound and speeds up briefly.
3. **Lunging / Blocked (`ដេញតាម`)**: Solving a checkpoint puzzle raises a glowing golden *Kbach* barrier behind the Kid or briefly startles/pushes the Tiger back, rewarding quick thinking with breathing room.

### B. Kid Movement & "Check the Map" Mechanic
Use all 4 animation keyframes from `kid_character_sheet.jpg`:
- **Walking + Reading Map**: Default steady movement with a subtle corner mini-map peek of the maze.
- **Running (Map Tucked)**: Hold sprint / swipe fast to run at full speed away from the Tiger (hides the map while sprinting).
- **Startled / Struggling**: Triggered momentarily on dead ends or wrong puzzle submissions for immediate visual personality.

### C. Illuminated Maze Route Progression
Match the 3 glowing checkpoints in `angkor_maze_level_map.jpg`:
- Before a puzzle is solved, the fork ahead stays dim/overgrown with roots.
- Solving a checkpoint stele lights up golden *Kbach* floor runes leading toward the next gate and finally opens the sunlit **Seven-Headed Naga Exit** where the Kind Cambodian Elephant awaits.

---

## 2. Tactile Khmer Puzzle "Juice" & Polish

1. **Carved Sandstone Tiles (`SyllableOrderingWidget`)**:
   - Style syllable chips as warm beveled Angkor sandstone blocks with subtle drop shadows, `AnimatedScale` snap-in on tap, golden pulse on correct assembly, and gentle horizontal shake on wrong order.
2. **Word & Picture Cards (`PictureMatchingWidget` / `WordMatchingWidget`)**:
   - Use warm palm-leaf parchment cards with thin dark-brown ink borders (`#4A3525`) matching the character art rather than generic default blue/grey Material boxes.
   - Add matching Cambodian watercolor illustrations in `assets/images/vocabulary/` so every Picture Matching prompt feels alive.
3. **Streak & Speed Blessing (`ប្រាជ្ញា` — Wisdom Boost)**:
   - Solving a checkpoint on the **first try with zero hints** awards full `ScoreCalculator` points and grants a 3-second Kid movement boost in the maze.
4. **Fair Anti-Frustration Recovery**:
   - If a student runs out of attempts on a puzzle, do not hard-lock the level—reset the stele with a fresh word and advance the Tiger slightly closer, keeping tension exciting without causing rage-quits for young learners.

---

## 3. Living Cambodian Temple Atmosphere

- **Ambient Motion**: Drifting sunbeams and golden dust motes near the exit *Gopura*, gentle lotus pond ripples, and celebratory *Rumduol* (`ផ្ការំដួល`) petals floating when reaching the Elephant.
- **Audio Feedback (M5 Integration)**:
  - Soft stone-grinding click when placing/removing Khmer syllable stones.
  - Warm bamboo chime / traditional *Roneat* (`រនាត`) flourish when a puzzle is solved.
  - Tiger growl warning on wrong answers and joyful elephant trumpet at level clear.
  - Native Khmer spoken pronunciation playback immediately after solving a word.

---

## 4. Concrete Implementation Roadmap by Team Module

| Module | High-Impact Upgrade |
| --- | --- |
| **M1 (Levels)** | Design 5 escalating temple mazes (`1` -> `3` -> `5` checkpoints) moving from Easy Animals/Family to Hard Education/Nature compounds. |
| **M2 (Gameplay / Flame)** | Implement 3-state Tiger AI, Kid walk-with-map vs. sprint toggle, and golden floor-rune path reveal on `PuzzleCompletionEvent.isCorrect`. |
| **M3 (Khmer Puzzles)** | Populate `assets/images/vocabulary/` with matching watercolor art; add animated stone-tile feedback, optional Angkor Storybook theme preset for `PuzzlePreviewScreen`, and native teacher verification of `initial_vocabulary.json`. |
| **M4 (UI/UX & Art)** | Slice `kid_character_sheet.jpg`, `tiger_character_sheet.jpg`, and `elephant_character_sheet.jpg` into transparent PNG sprite frames; bundle a licensed Khmer font (`Noto Sans Khmer` / `Battambang`). |
| **M5 (Integration)** | Wire *Roneat* / stone SFX + Khmer voice clips, persist stars/scores from `PuzzleCompletionEvent`, and unlock levels progressively. |
