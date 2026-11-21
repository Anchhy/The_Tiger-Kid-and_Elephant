import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiger_kid_elephant/features/khmer_puzzle/khmer_puzzle.dart';

class _InMemoryAssetBundle extends CachingAssetBundle {
  _InMemoryAssetBundle(this._payload);

  final String _payload;

  @override
  Future<ByteData> load(String key) async => ByteData(0);

  @override
  Future<String> loadString(String key, {bool cache = true}) async => _payload;
}

KhmerPuzzleRepository _createPreviewRepository() {
  final sampleJson = jsonEncode([
    {
      'id': 'tiger',
      'khmerWord': 'ខ្លា',
      'syllables': ['ខ្លា'],
      'englishMeaning': 'Tiger',
      'difficulty': 'easy',
      'imagePath': 'assets/images/vocabulary/tiger.png',
    },
    {
      'id': 'elephant',
      'khmerWord': 'ដំរី',
      'syllables': ['ដំ', 'រី'],
      'englishMeaning': 'Elephant',
      'difficulty': 'easy',
      'imagePath': 'assets/images/vocabulary/elephant.png',
    },
    {
      'id': 'water',
      'khmerWord': 'ទឹក',
      'syllables': ['ទឹក'],
      'englishMeaning': 'Water',
      'difficulty': 'easy',
      'imagePath': 'assets/images/vocabulary/water.png',
    },
    {
      'id': 'flower',
      'khmerWord': 'ផ្កា',
      'syllables': ['ផ្កា'],
      'englishMeaning': 'Flower',
      'difficulty': 'easy',
      'imagePath': 'assets/images/vocabulary/flower.png',
    },
  ]);
  return KhmerPuzzleRepository(
    loader: KhmerVocabularyLoader(
      assetBundle: _InMemoryAssetBundle(sampleJson),
    ),
  );
}

void main() {
  // Unverified test fixtures strictly for UI interaction & layout verification.
  const tiger = VocabularyItem(
    id: 'tiger',
    khmerWord: 'ខ្លា',
    syllables: ['ខ្លា'],
    englishMeaning: 'Tiger',
    difficulty: PuzzleDifficulty.easy,
    imagePath: 'assets/images/vocabulary/tiger.png',
    hints: VocabularyHints(
      easy: 'A wild cat.',
      medium: 'Has orange and black stripes.',
      strong: 'Chases the kid in the maze.',
    ),
    educationalNote: 'ខ្លា means tiger.',
    verification: VocabularyVerification(
      spelling: VerificationStatus.verified,
      meaning: VerificationStatus.verified,
      syllables: VerificationStatus.verified,
    ),
  );

  const elephant = VocabularyItem(
    id: 'elephant',
    khmerWord: 'ដំរី',
    syllables: ['ដំ', 'រី'],
    englishMeaning: 'Elephant',
    difficulty: PuzzleDifficulty.easy,
    imagePath: 'assets/images/vocabulary/elephant.png',
    hints: VocabularyHints(
      easy: 'A huge land animal.',
      medium: 'Has a long trunk.',
      strong: 'Starts with ដំ.',
    ),
    educationalNote: 'ដំរី has two syllables: ដំ and រី.',
    verification: VocabularyVerification(
      spelling: VerificationStatus.verified,
      meaning: VerificationStatus.verified,
      syllables: VerificationStatus.verified,
    ),
  );

  const water = VocabularyItem(
    id: 'water',
    khmerWord: 'ទឹក',
    syllables: ['ទឹក'],
    englishMeaning: 'Water',
    difficulty: PuzzleDifficulty.easy,
    imagePath: 'assets/images/vocabulary/water.png',
    verification: VocabularyVerification(
      spelling: VerificationStatus.verified,
      meaning: VerificationStatus.verified,
      syllables: VerificationStatus.verified,
    ),
  );

  // Synthetic fixture with repeated syllable segment to test unique tile IDs.
  const repeatedSyllableWord = VocabularyItem(
    id: 'synthetic_repeat',
    khmerWord: 'សាសាប',
    syllables: ['សា', 'សា', 'ប'],
    englishMeaning: 'Synthetic Repeat',
    difficulty: PuzzleDifficulty.medium,
    verification: VocabularyVerification(
      spelling: VerificationStatus.verified,
      meaning: VerificationStatus.verified,
      syllables: VerificationStatus.verified,
    ),
  );

  group('Loading and error states', () {
    testWidgets('displays loading and error states with retry callback', (
      tester,
    ) async {
      var retried = false;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PictureMatchingWidget(puzzle: null, isLoading: true),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PictureMatchingWidget(
              puzzle: null,
              errorMessage: 'Failed to load vocabulary.',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );
      expect(find.text('Failed to load vocabulary.'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });
  });

  group('PictureMatchingWidget', () {
    testWidgets(
      'VocabularyImageFrame shows safe fallback when asset image is missing',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: VocabularyImageFrame(
                imagePath: 'assets/images/vocabulary/non_existent_missing.png',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Image unavailable'), findsOneWidget);
      },
    );

    testWidgets(
      'renders vocabulary asset image, highlights selection, shows wrong & correct feedback, prevents double submit, and delivers hints',
      (tester) async {
        final puzzle = PictureMatchingGenerator(random: Random(2)).generate(
          vocabularyPool: const [tiger, elephant, water],
          difficulty: PuzzleDifficulty.easy,
          targetVocabularyId: 'tiger',
        );

        PuzzleResult? completedResult;
        HintResponse? lastHint;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PictureMatchingWidget(
                puzzle: puzzle,
                onCompleted: (result) => completedResult = result,
                onHintRequested: (hint) => lastHint = hint,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Real tiger PNG asset loads inside VocabularyImageFrame without fallback.
        expect(
          find.descendant(
            of: find.byType(VocabularyImageFrame),
            matching: find.byType(Image),
          ),
          findsOneWidget,
        );
        expect(find.text('Image unavailable'), findsNothing);

        // Hint interaction.
        await tester.tap(find.text('Hint (3/3)'));
        await tester.pump();
        expect(lastHint?.hasHint, isTrue);
        expect(find.text(lastHint!.text), findsOneWidget);
        expect(find.text('Hint (2/3)'), findsOneWidget);

        // Select wrong option and submit.
        final wrongOption = puzzle.prompt.options.firstWhere(
          (o) => o.id != puzzle.answerKey.correctOptionId,
        );
        await tester.tap(find.text(wrongOption.label));
        await tester.pump();

        await tester.ensureVisible(find.text('Submit Answer'));
        await tester.tap(find.text('Submit Answer'));
        await tester.pump();
        expect(
          find.text('Not quite right. Try another choice!'),
          findsOneWidget,
        );
        expect(completedResult, isNull);

        // Repeated tap on Submit without changing selection must not penalize.
        await tester.ensureVisible(find.text('Submit Answer'));
        await tester.tap(find.text('Submit Answer'));
        await tester.pump();
        expect(find.text('Attempts left: 3/4'), findsOneWidget);

        // Select correct option and submit.
        final correctOption = puzzle.prompt.options.firstWhere(
          (o) => o.id == puzzle.answerKey.correctOptionId,
        );
        await tester.ensureVisible(find.text(correctOption.label));
        await tester.tap(find.text(correctOption.label));
        await tester.pump();
        await tester.ensureVisible(find.text('Submit Answer'));
        await tester.tap(find.text('Submit Answer'));
        await tester.pump();

        expect(completedResult?.isSolved, isTrue);
        expect(find.textContaining('Correct!'), findsOneWidget);
        expect(find.text('ខ្លា means tiger.'), findsOneWidget);
      },
    );
  });

  group('WordMatchingWidget', () {
    testWidgets(
      'matches pairs, prevents re-selecting matched pairs, handles wrong pairs, and completes round',
      (tester) async {
        final puzzle = WordMatchingGenerator(random: Random(4)).generate(
          vocabularyPool: const [tiger, elephant, water],
          difficulty: PuzzleDifficulty.easy,
        );

        PuzzleResult? completedResult;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WordMatchingWidget(
                puzzle: puzzle,
                onCompleted: (result) => completedResult = result,
              ),
            ),
          ),
        );

        final firstLeft = puzzle.prompt.options.first;
        final firstExpectedRightId =
            puzzle.answerKey.expectedPairs[firstLeft.id]!;
        final wrongRight = puzzle.prompt.rightOptions.firstWhere(
          (r) => r.id != firstExpectedRightId,
        );

        // Wrong pair attempt.
        await tester.tap(find.text(firstLeft.label));
        await tester.pump();
        await tester.tap(find.text(wrongRight.label));
        await tester.pump();
        expect(find.textContaining('do not match'), findsOneWidget);
        expect(completedResult, isNull);

        // Match all 3 pairs correctly.
        for (final left in puzzle.prompt.options) {
          final rightId = puzzle.answerKey.expectedPairs[left.id]!;
          final right = puzzle.prompt.rightOptions.firstWhere(
            (r) => r.id == rightId,
          );
          await tester.tap(find.text(left.label));
          await tester.pump();
          await tester.tap(find.text(right.label));
          await tester.pump();
        }

        expect(completedResult?.isSolved, isTrue);
        expect(find.text('Pairs matched: 3/3'), findsOneWidget);

        // Tapping an already matched item does nothing.
        await tester.tap(find.text(firstLeft.label));
        await tester.pump();
        expect(find.byIcon(Icons.check_circle), findsNWidgets(6));
      },
    );
  });

  group('SyllableOrderingWidget', () {
    testWidgets(
      'supports repeated syllable tiles via unique keys, reset, removal, hints, and validation',
      (tester) async {
        final puzzle = SyllableOrderingGenerator(random: Random(7)).generate(
          vocabularyPool: const [repeatedSyllableWord],
          difficulty: PuzzleDifficulty.medium,
        );

        PuzzleResult? completedResult;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SyllableOrderingWidget(
                puzzle: puzzle,
                onCompleted: (result) => completedResult = result,
              ),
            ),
          ),
        );

        final chips = puzzle.prompt.syllableChips;
        final firstSaIndex = chips.indexOf('សា');
        final secondSaIndex = chips.lastIndexOf('សា');
        final baIndex = chips.indexOf('ប');

        // Tap both repeated 'សា' tiles independently, then test removal & reset.
        await tester.tap(find.byKey(ValueKey('bank_$firstSaIndex')));
        await tester.pump();
        await tester.tap(find.byKey(ValueKey('bank_$secondSaIndex')));
        await tester.pump();
        expect(find.text('Syllables placed: 2/3'), findsOneWidget);

        // Remove one selected tile directly.
        await tester.tap(find.byKey(ValueKey('selected_$secondSaIndex')));
        await tester.pump();
        expect(find.text('Syllables placed: 1/3'), findsOneWidget);

        // Reset clears selection.
        await tester.tap(find.text('Reset'));
        await tester.pump();
        expect(find.text('Syllables placed: 0/3'), findsOneWidget);

        // Place all 3 tiles in correct order ['សា', 'សា', 'ប'] and check.
        await tester.tap(find.byKey(ValueKey('bank_$firstSaIndex')));
        await tester.pump();
        await tester.tap(find.byKey(ValueKey('bank_$secondSaIndex')));
        await tester.pump();
        await tester.tap(find.byKey(ValueKey('bank_$baIndex')));
        await tester.pump();

        await tester.tap(find.text('Check Answer'));
        await tester.pump();

        expect(completedResult?.isSolved, isTrue);
        expect(find.textContaining('សាសាប'), findsOneWidget);
      },
    );
  });

  group('Responsive layout tests (320px to 1024px)', () {
    const widths = [320.0, 375.0, 430.0, 768.0, 1024.0];

    testWidgets('all 3 puzzle widgets render without overflow across widths', (
      tester,
    ) async {
      final picPuzzle = PictureMatchingGenerator(random: Random(1)).generate(
        vocabularyPool: const [tiger, elephant, water],
        difficulty: PuzzleDifficulty.easy,
      );
      final wordPuzzle = WordMatchingGenerator(random: Random(1)).generate(
        vocabularyPool: const [tiger, elephant, water],
        difficulty: PuzzleDifficulty.easy,
      );
      final sylPuzzle = SyllableOrderingGenerator(random: Random(1)).generate(
        vocabularyPool: const [elephant],
        difficulty: PuzzleDifficulty.easy,
      );

      for (final width in widths) {
        await tester.binding.setSurfaceSize(Size(width, 800));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: PictureMatchingWidget(puzzle: picPuzzle)),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: WordMatchingWidget(puzzle: wordPuzzle)),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: SyllableOrderingWidget(puzzle: sylPuzzle)),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      // Reset surface size after responsive checks.
      await tester.binding.setSurfaceSize(null);
    });
  });

  group('Angkor theme extension and preview theme toggle', () {
    testWidgets('supports M4 ThemeExtension override and lerp', (tester) async {
      const customTheme = AngkorPuzzleTheme(
        parchmentSurface: Color(0xFF112233),
        recessedTray: Color(0xFF223344),
        stoneTile: Color(0xFF334455),
        stoneSelected: Color(0xFF445566),
        stoneMatched: Color(0xFF556677),
        inkText: Color(0xFFFFFFFF),
        mutedInk: Color(0xFFCCCCCC),
        sandstoneBorder: Color(0xFF667788),
        stoneShadow: Color(0xFF000000),
        goldAccent: Color(0xFFFFAA00),
        mossAccent: Color(0xFF00AA55),
        terracottaAccent: Color(0xFFDD4422),
      );

      final copied = customTheme.copyWith(goldAccent: const Color(0xFF998877));
      expect(copied.goldAccent, const Color(0xFF998877));
      expect(
        customTheme.lerp(const AngkorPuzzleTheme.light(), 0.5).inkText,
        isNotNull,
      );

      final sylPuzzle = SyllableOrderingGenerator(random: Random(1)).generate(
        vocabularyPool: const [elephant],
        difficulty: PuzzleDifficulty.easy,
      );

      late AngkorPuzzleTheme resolvedTheme;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true, extensions: const [customTheme]),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                resolvedTheme = AngkorPuzzleTheme.of(context);
                return SyllableOrderingWidget(puzzle: sylPuzzle);
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(resolvedTheme.stoneTile, const Color(0xFF334455));
      expect(resolvedTheme.goldAccent, const Color(0xFFFFAA00));
    });

    testWidgets('PuzzlePreviewScreen toggles Angkor Storybook and Host theme', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PuzzlePreviewScreen(repository: _createPreviewRepository()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Angkor Theme'), findsOneWidget);

      await tester.tap(find.byTooltip('Switch to Host M3 Theme'));
      await tester.pumpAndSettle();

      expect(find.text('Host Theme'), findsOneWidget);
    });

    testWidgets(
      'Asset kit widgets render Khmer text cleanly without overflow and handle taps',
      (tester) async {
        var gameButtonTapped = false;
        var iconButtonTapped = false;
        var levelCardTapped = false;
        var replayTapped = false;
        var continueTapped = false;
        var retryTapped = false;
        var backTapped = false;

        const sampleResult = PuzzleResult(
          puzzleId: 'asset_victory_test',
          puzzleType: PuzzleType.pictureMatching,
          difficulty: PuzzleDifficulty.easy,
          vocabularyId: 'elephant',
          isSolved: true,
          attempts: 1,
          hintsUsed: 0,
          score: 150,
          feedbackMessage: 'Correct!',
          educationalNote: 'ដំរី (damrei) means Elephant.',
        );

        for (final width in const [320.0, 768.0]) {
          await tester.binding.setSurfaceSize(Size(width, 900));

          await tester.pumpWidget(
            MaterialApp(
              theme: AngkorPuzzleTheme.storybookThemeData(),
              home: Scaffold(
                body: PuzzleGameBackground(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const PuzzleHeartsBar(remainingLives: 3, maxLives: 4),
                        const PuzzleCoinsBadge(coins: 420),
                        const PuzzleStarsRow(earnedStars: 3),
                        const PuzzleCharacterAvatar(
                          type: PuzzleCharacterType.kid,
                          poseIndex: 0,
                          isHighlighted: true,
                        ),
                        AngkorGameButton(
                          label: 'លេង • Play',
                          assetIconPath: KhmerPuzzleAssets.hintLanternIcon,
                          onPressed: () => gameButtonTapped = true,
                        ),
                        AngkorIconButton(
                          tooltip: 'Pause Game',
                          assetPath: KhmerPuzzleAssets.pauseButton,
                          onPressed: () => iconButtonTapped = true,
                        ),
                        PuzzleLevelCard(
                          levelNumber: 1,
                          title: 'Temple Gate',
                          khmerSubtitle: 'សត្វ • Easy',
                          starsEarned: 3,
                          isCurrent: true,
                          onTap: () => levelCardTapped = true,
                        ),
                        const AchievementBadgeCard(
                          khmerTitle: 'អ្នកចេះខ្មែរ',
                          title: 'First Word',
                          description: 'Completed a puzzle',
                        ),
                        PuzzleVictoryView(
                          result: sampleResult,
                          khmerWord: 'ដំរី',
                          englishMeaning: 'Elephant',
                          onReplay: () => replayTapped = true,
                          onContinue: () => continueTapped = true,
                        ),
                        PuzzleGameOverView(
                          onRetry: () => retryTapped = true,
                          onBack: () => backTapped = true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }

        final tapTargets = <Finder>[
          find.text('លេង • Play'),
          find.byTooltip('Pause Game'),
          find.text('Level 1 • Temple Gate'),
          find.text('Replay'),
          find.text('Next Temple'),
          find.text('Try Again'),
          find.text('Back'),
        ];
        for (final target in tapTargets) {
          await tester.ensureVisible(target);
          await tester.tap(target);
        }
        await tester.pump();

        expect(gameButtonTapped, isTrue);
        expect(iconButtonTapped, isTrue);
        expect(levelCardTapped, isTrue);
        expect(replayTapped, isTrue);
        expect(continueTapped, isTrue);
        expect(retryTapped, isTrue);
        expect(backTapped, isTrue);

        await tester.binding.setSurfaceSize(null);
      },
    );

    testWidgets('PuzzlePreviewScreen switches to Asset Kit Showcase mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PuzzlePreviewScreen(repository: _createPreviewRepository()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Toggle Asset Kit Showcase'));
      await tester.pumpAndSettle();

      expect(find.text('HUD Counters & Stone Controls'), findsOneWidget);
      expect(find.text('Extracted Character Sprites'), findsOneWidget);
      expect(find.text('Temple Level Cards & Achievement'), findsOneWidget);
      expect(find.text('Unified Angkor UI Component Kit'), findsOneWidget);
      expect(find.text('Bayon Temple Gate'), findsOneWidget);
    });

    testWidgets(
      'unified UI components render safely across 320px to 1024px viewports with >=48dp touch targets',
      (tester) async {
        addTearDown(() => tester.binding.setSurfaceSize(null));

        const sampleItem = VocabularyItem(
          id: 'elephant',
          khmerWord: 'ដំរី',
          syllables: ['ដំ', 'រី'],
          englishMeaning: 'Elephant',
          difficulty: PuzzleDifficulty.easy,
          imagePath: 'assets/images/vocabulary/elephant.png',
          exampleKm: 'ដំរីដើរក្នុងព្រៃ។',
        );

        var tileTapped = false;
        var markerTapped = false;
        var promptTapped = false;
        var bannerDismissed = false;

        for (final width in [320.0, 480.0, 1024.0]) {
          await tester.binding.setSurfaceSize(Size(width, 900));
          await tester.pumpWidget(
            MaterialApp(
              theme: AngkorPuzzleTheme.storybookThemeData(),
              home: Scaffold(
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: GamePanel(
                    title: 'Angkor UI Test',
                    khmerSubtitle: 'ក្លោងទ្វារប្រាសាទ',
                    leadingIcon: Icons.temple_hindu_rounded,
                    headerTrailing: const PuzzleStarCounter(
                      earnedStars: 3,
                      maxStars: 9,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const GameIcon(
                          assetPath: KhmerPuzzleAssets.hintLanternIcon,
                          tier: GameIconTier.hudEmblem,
                          semanticLabel: 'Hint Lantern',
                        ),
                        const SizedBox(height: 8),
                        const PuzzleProgressBar(
                          current: 2,
                          total: 4,
                          khmerLabel: 'វឌ្ឍនភាព',
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            PuzzleAnswerTile(
                              label: 'ដំរី',
                              onTap: () => tileTapped = true,
                            ),
                            const PuzzleAnswerTile(
                              label: 'ទឹក',
                              isMatched: true,
                              onTap: null,
                            ),
                            const PuzzleAnswerTile(
                              label: 'ខ្លា',
                              isIncorrect: true,
                              onTap: null,
                            ),
                            const PuzzleAnswerTile(
                              label: 'សាលារៀន',
                              isDisabled: true,
                              onTap: null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const VocabularyCard(
                          item: sampleItem,
                          showExample: true,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            WorldMapMarker(
                              label: 'Village',
                              khmerLabel: 'ភូមិ',
                              isCompleted: true,
                              starsEarned: 3,
                              onTap: () => markerTapped = true,
                            ),
                            const WorldMapMarker(
                              label: 'Locked Gate',
                              isUnlocked: false,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        InteractionPrompt(
                          title: 'Read Stele',
                          khmerPrompt: 'អានពាក្យខ្មែរ',
                          onTap: () => promptTapped = true,
                        ),
                        const SizedBox(height: 8),
                        GameNotificationBanner(
                          title: 'Star Earned',
                          khmerBadge: 'ពូកែ!',
                          message: 'Unlocked new temple clue.',
                          onDismiss: () => bannerDismissed = true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }

        // Verify Khmer height >= 1.5 and >= 48dp touch target sizing.
        final khmerText = tester.widget<Text>(find.text('ដំរី').first);
        expect(khmerText.style?.height, greaterThanOrEqualTo(1.5));

        final tileSize = tester.getSize(find.byType(PuzzleAnswerTile).first);
        expect(tileSize.height, greaterThanOrEqualTo(48.0));
        expect(tileSize.width, greaterThanOrEqualTo(48.0));

        await tester.ensureVisible(find.text('ដំរី').first);
        await tester.tap(find.text('ដំរី').first);
        await tester.ensureVisible(find.text('Village'));
        await tester.tap(find.text('Village'));
        await tester.ensureVisible(find.text('Read Stele'));
        await tester.tap(find.text('Read Stele'));
        await tester.ensureVisible(find.byTooltip('Dismiss notice'));
        await tester.tap(find.byTooltip('Dismiss notice'));
        await tester.pump();

        expect(tileTapped, isTrue);
        expect(markerTapped, isTrue);
        expect(promptTapped, isTrue);
        expect(bannerDismissed, isTrue);
      },
    );

    testWidgets('GameConfirmationDialog returns confirm and cancel booleans', (
      tester,
    ) async {
      bool? dialogResult;
      await tester.pumpWidget(
        MaterialApp(
          theme: AngkorPuzzleTheme.storybookThemeData(),
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  dialogResult = await GameConfirmationDialog.show(
                    context,
                    title: 'Leave Temple?',
                    khmerTitle: 'ចាកចេញពីប្រាសាទ?',
                    message: 'Your current stars are saved.',
                    confirmLabel: 'Leave',
                    cancelLabel: 'Stay',
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();
      expect(find.text('Leave Temple?'), findsOneWidget);
      await tester.tap(find.text('Stay'));
      await tester.pumpAndSettle();
      expect(dialogResult, isFalse);

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Leave'));
      await tester.pumpAndSettle();
      expect(dialogResult, isTrue);
    });
  });
}
