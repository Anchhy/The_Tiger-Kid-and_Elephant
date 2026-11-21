import 'package:flutter/material.dart';

import '../models/puzzle_enums.dart';
import '../models/puzzle_result.dart';
import '../models/vocabulary_item.dart';
import '../repositories/khmer_puzzle_repository.dart';
import '../utils/khmer_puzzle_assets.dart';
import '../widgets/angkor_puzzle_theme.dart';
import '../widgets/game_asset_widgets.dart';
import '../widgets/game_ui_components.dart';
import '../widgets/puzzle_outcome_overlays.dart';
import 'khmer_puzzle_screen.dart';

/// Standalone M3 preview screen for testing puzzle types and difficulties.
///
/// Showcases the Angkor Storybook theme by default and includes toggles for
/// neutral Material 3 theme overrides and the integrated Angkor UI asset kit.
class PuzzlePreviewScreen extends StatefulWidget {
  const PuzzlePreviewScreen({super.key, this.repository});

  final KhmerPuzzleRepository? repository;

  @override
  State<PuzzlePreviewScreen> createState() => _PuzzlePreviewScreenState();
}

class _PuzzlePreviewScreenState extends State<PuzzlePreviewScreen> {
  PuzzleType _selectedType = PuzzleType.pictureMatching;
  PuzzleDifficulty _selectedDifficulty = PuzzleDifficulty.easy;
  bool _useAngkorStorybookTheme = true;
  bool _showAssetShowcase = false;
  int _roundSeed = 0;

  @override
  Widget build(BuildContext context) {
    final activeTheme = _useAngkorStorybookTheme
        ? AngkorPuzzleTheme.storybookThemeData(
            brightness: Theme.of(context).brightness,
          )
        : Theme.of(context);
    final angkor = AngkorPuzzleTheme.of(context);

    final previewScaffold = Scaffold(
      appBar: AppBar(
        title: const Text('M3 Puzzle Preview'),
        actions: [
          IconButton(
            onPressed: () =>
                setState(() => _showAssetShowcase = !_showAssetShowcase),
            icon: Icon(
              _showAssetShowcase
                  ? Icons.extension_outlined
                  : Icons.view_quilt_outlined,
            ),
            tooltip: 'Toggle Asset Kit Showcase',
          ),
          IconButton(
            onPressed: () => setState(
              () => _useAngkorStorybookTheme = !_useAngkorStorybookTheme,
            ),
            icon: Icon(
              _useAngkorStorybookTheme
                  ? Icons.auto_awesome
                  : Icons.palette_outlined,
            ),
            tooltip: _useAngkorStorybookTheme
                ? 'Switch to Host M3 Theme'
                : 'Switch to Angkor Storybook Theme',
          ),
          IconButton(
            onPressed: () => setState(() => _roundSeed++),
            icon: const Icon(Icons.refresh),
            tooltip: 'New puzzle',
          ),
        ],
      ),
      body: _showAssetShowcase
          ? const _AssetKitShowcaseView()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      DropdownButton<PuzzleType>(
                        value: _selectedType,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedType = value);
                          }
                        },
                        items: PuzzleType.values
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type.name),
                              ),
                            )
                            .toList(),
                      ),
                      DropdownButton<PuzzleDifficulty>(
                        value: _selectedDifficulty,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedDifficulty = value);
                          }
                        },
                        items: PuzzleDifficulty.values
                            .map(
                              (level) => DropdownMenuItem(
                                value: level,
                                child: Text(level.name),
                              ),
                            )
                            .toList(),
                      ),
                      Chip(
                        label: Text(
                          _useAngkorStorybookTheme
                              ? 'Angkor Theme'
                              : 'Host Theme',
                        ),
                        backgroundColor: _useAngkorStorybookTheme
                            ? angkor.stoneSelected.withValues(alpha: 0.6)
                            : null,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: KhmerPuzzleScreen(
                    key: ValueKey(
                      '${_selectedType.name}_${_selectedDifficulty.name}_$_roundSeed',
                    ),
                    puzzleType: _selectedType,
                    difficulty: _selectedDifficulty,
                    repository: widget.repository,
                    requireVerifiedSyllables: false,
                  ),
                ),
              ],
            ),
    );

    return Theme(data: activeTheme, child: previewScaffold);
  }
}

class _AssetKitShowcaseView extends StatefulWidget {
  const _AssetKitShowcaseView();

  @override
  State<_AssetKitShowcaseView> createState() => _AssetKitShowcaseViewState();
}

class _AssetKitShowcaseViewState extends State<_AssetKitShowcaseView> {
  int _selectedLevel = 2;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const sampleResult = PuzzleResult(
      puzzleId: 'showcase_elephant',
      puzzleType: PuzzleType.syllableOrdering,
      difficulty: PuzzleDifficulty.easy,
      vocabularyId: 'elephant',
      isSolved: true,
      attempts: 1,
      hintsUsed: 0,
      score: 120,
      feedbackMessage: 'Correct! ដំរី (Elephant)',
      educationalNote: 'ដំរី (damrei) has two syllables: ដំ and រី.',
    );

    return PuzzleGameBackground(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'HUD Counters & Stone Controls',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const PuzzleHeartsBar(remainingLives: 3, maxLives: 4),
                    const PuzzleCoinsBadge(coins: 1250),
                    const PuzzleStarsRow(earnedStars: 3, starSize: 28),
                    AngkorIconButton(
                      tooltip: 'Dictionary',
                      assetPath: KhmerPuzzleAssets.dictionaryButton,
                      fallbackIcon: Icons.menu_book,
                      onPressed: () {},
                    ),
                    AngkorIconButton(
                      tooltip: 'Sound',
                      assetPath: KhmerPuzzleAssets.soundButton,
                      fallbackIcon: Icons.volume_up,
                      onPressed: () {},
                    ),
                    AngkorIconButton(
                      tooltip: 'Settings',
                      assetPath: KhmerPuzzleAssets.settingsButton,
                      fallbackIcon: Icons.settings,
                      onPressed: () {},
                    ),
                    AngkorIconButton(
                      tooltip: 'Pause',
                      assetPath: KhmerPuzzleAssets.pauseButton,
                      fallbackIcon: Icons.pause,
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Extracted Character Sprites',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                const Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    PuzzleCharacterAvatar(
                      type: PuzzleCharacterType.kid,
                      poseIndex: 0,
                      size: 92,
                      isHighlighted: true,
                    ),
                    PuzzleCharacterAvatar(
                      type: PuzzleCharacterType.elephant,
                      poseIndex: 0,
                      size: 92,
                    ),
                    PuzzleCharacterAvatar(
                      type: PuzzleCharacterType.tiger,
                      poseIndex: 0,
                      size: 92,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Temple Level Cards & Achievement',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                PuzzleLevelCard(
                  levelNumber: 1,
                  title: 'Mossy Gopura',
                  khmerSubtitle: 'សត្វព្រៃ • Easy',
                  starsEarned: 3,
                  isUnlocked: true,
                  isCurrent: _selectedLevel == 1,
                  onTap: () => setState(() => _selectedLevel = 1),
                ),
                const SizedBox(height: 8),
                PuzzleLevelCard(
                  levelNumber: 2,
                  title: 'Kbach Courtyard',
                  khmerSubtitle: 'ផ្ទះ និង អាហារ • Medium',
                  starsEarned: 2,
                  isUnlocked: true,
                  isCurrent: _selectedLevel == 2,
                  onTap: () => setState(() => _selectedLevel = 2),
                ),
                const SizedBox(height: 8),
                const PuzzleLevelCard(
                  levelNumber: 3,
                  title: 'Naga Exit Gate',
                  khmerSubtitle: 'សាលារៀន • Hard',
                  isUnlocked: false,
                ),
                const SizedBox(height: 12),
                const AchievementBadgeCard(
                  khmerTitle: 'ប្រាជ្ញា • Khmer Explorer',
                  title: 'First-Try Stele Master',
                  description:
                      'Solved a temple word puzzle with zero hints used.',
                ),
                const SizedBox(height: 20),
                Text(
                  'Unified Angkor UI Component Kit',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                GamePanel(
                  title: 'Bayon Temple Gate',
                  khmerSubtitle: 'ក្លោងទ្វារប្រាសាទបាយ័ន',
                  leadingAssetPath: KhmerPuzzleAssets.checkpointSteleIcon,
                  headerTrailing: const PuzzleStarCounter(
                    earnedStars: 7,
                    maxStars: 9,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const PuzzleProgressBar(
                        current: 2,
                        total: 3,
                        khmerLabel: 'វឌ្ឍនភាពល្បែង • Session Progress',
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          PuzzleAnswerTile(
                            label: 'ដំរី',
                            isSelected: true,
                            onTap: () {},
                          ),
                          PuzzleAnswerTile(
                            label: 'ទឹក',
                            isMatched: true,
                            onTap: () {},
                          ),
                          PuzzleAnswerTile(label: 'ផ្កា', onTap: () {}),
                        ],
                      ),
                      const SizedBox(height: 12),
                      VocabularyCard(
                        item: VocabularyItem(
                          id: 'elephant',
                          khmerWord: 'ដំរី',
                          syllables: const ['ដំ', 'រី'],
                          englishMeaning: 'Elephant',
                          difficulty: PuzzleDifficulty.easy,
                          imagePath: KhmerPuzzleAssets.vocabularyPath(
                            'elephant',
                          ),
                          exampleKm: 'ដំរីដើរក្នុងព្រៃ។',
                        ),
                        showExample: true,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          WorldMapMarker(
                            label: 'Village',
                            khmerLabel: 'ភូមិ',
                            isCompleted: true,
                            starsEarned: 3,
                            onTap: () {},
                          ),
                          WorldMapMarker(
                            label: 'Tonle Sap',
                            khmerLabel: 'ទន្លេសាប',
                            isActive: true,
                            onTap: () {},
                          ),
                          const WorldMapMarker(
                            label: 'Bayon Gate',
                            khmerLabel: 'បាយ័ន',
                            isUnlocked: false,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      InteractionPrompt(
                        title: 'Inspect Stone Stele',
                        khmerPrompt: 'ចុចដើម្បីអានពាក្យខ្មែរ',
                        onTap: () => GameConfirmationDialog.show(
                          context,
                          title: 'Enter Bayon Chamber?',
                          khmerTitle: 'តើអ្នកចង់ចូលប្រាសាទទេ?',
                          message:
                              'Solve 3 Khmer vocabulary puzzles to unlock the next path.',
                        ),
                      ),
                      const SizedBox(height: 12),
                      const GameNotificationBanner(
                        title: 'Daily Stele Bonus',
                        khmerBadge: 'ពូកែណាស់!',
                        message:
                            'You mastered ដំរី without using any lantern hints.',
                        tone: GameBannerTone.reward,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: const [
                          GameIcon(
                            assetPath: KhmerPuzzleAssets.gameIconCompass,
                            tier: GameIconTier.hudEmblem,
                            semanticLabel: 'Explore Map Compass',
                          ),
                          GameIcon(
                            assetPath: KhmerPuzzleAssets.gameIconOpenBook,
                            tier: GameIconTier.hudEmblem,
                            semanticLabel: 'Khmer Dictionary',
                          ),
                          GameIcon(
                            assetPath: KhmerPuzzleAssets.gameIconTrophy,
                            tier: GameIconTier.hudEmblem,
                            semanticLabel: 'Temple Trophy',
                          ),
                          GameIcon(
                            assetPath: KhmerPuzzleAssets.gameIconStarsStack,
                            tier: GameIconTier.hudEmblem,
                            semanticLabel: 'Bonus Stars',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                PuzzleVictoryView(
                  result: sampleResult,
                  khmerWord: 'ដំរី',
                  englishMeaning: 'Elephant',
                  onReplay: () {},
                  onContinue: () {},
                ),
                const SizedBox(height: 16),
                PuzzleGameOverView(onRetry: () {}, onBack: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
