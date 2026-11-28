import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiger_kid_elephant/features/khmer_puzzle/khmer_puzzle.dart';

class _InMemoryVocabBundle extends CachingAssetBundle {
  _InMemoryVocabBundle(this._payload);

  final String _payload;

  @override
  Future<ByteData> load(String key) async => ByteData(0);

  @override
  Future<String> loadString(String key, {bool cache = true}) async => _payload;
}

void main() {
  final sampleJson = jsonEncode([
    {
      'id': 'tiger',
      'khmer': 'ខ្លា',
      'verified_syllables': ['ខ្លា'],
      'english': 'Tiger',
      'category': 'animals',
      'difficulty': 'easy',
      'image': 'assets/images/vocabulary/tiger.png',
      'hints': {
        'easy': 'A wild striped cat.',
        'medium': 'Orange fur with black stripes.',
        'strong': 'Chases the kid in the maze.',
      },
      'educationalNote': 'ខ្លា (klaa) means tiger.',
      'verification': {
        'spelling': 'verified',
        'meaning': 'verified',
        'syllables': 'verified',
        'example': 'needs_review',
      },
    },
    {
      'id': 'elephant',
      'khmer': 'ដំរី',
      'verified_syllables': ['ដំ', 'រី'],
      'english': 'Elephant',
      'category': 'animals',
      'difficulty': 'easy',
      'image': 'assets/images/vocabulary/elephant.png',
      'hints': {
        'easy': 'A large gentle animal.',
        'medium': 'Has a long trunk.',
        'strong': 'Starts with ដំ.',
      },
      'educationalNote': 'ដំរី (damrei) means elephant.',
      'verification': {
        'spelling': 'verified',
        'meaning': 'verified',
        'syllables': 'verified',
        'example': 'needs_review',
      },
    },
    {
      'id': 'dog',
      'khmer': 'ឆ្កែ',
      'verified_syllables': ['ឆ្កែ'],
      'english': 'Dog',
      'category': 'animals',
      'difficulty': 'easy',
      'image': 'assets/images/vocabulary/dog.png',
      'hints': {
        'easy': 'A loyal pet.',
        'medium': 'Barks near the house.',
        'strong': 'Starts with ឆ.',
      },
      'educationalNote': 'ឆ្កែ (chkae) means dog.',
      'verification': {
        'spelling': 'verified',
        'meaning': 'verified',
        'syllables': 'verified',
        'example': 'needs_review',
      },
    },
    {
      'id': 'water',
      'khmer': 'ទឹក',
      'verified_syllables': ['ទឹក'],
      'english': 'Water',
      'category': 'food',
      'difficulty': 'easy',
      'image': 'assets/images/vocabulary/water.png',
      'verification': {
        'spelling': 'verified',
        'meaning': 'verified',
        'syllables': 'verified',
        'example': 'needs_review',
      },
    },
    {
      'id': 'rice',
      'khmer': 'បាយ',
      'verified_syllables': ['បាយ'],
      'english': 'Cooked Rice',
      'category': 'food',
      'difficulty': 'easy',
      'image': 'assets/images/vocabulary/rice.png',
      'verification': {
        'spelling': 'verified',
        'meaning': 'verified',
        'syllables': 'verified',
        'example': 'needs_review',
      },
    },
    {
      'id': 'cake',
      'khmer': 'នំខេក',
      'verified_syllables': ['នំ', 'ខេក'],
      'english': 'Cake',
      'category': 'food',
      'difficulty': 'easy',
      'image': 'assets/images/vocabulary/cake.png',
      'verification': {
        'spelling': 'verified',
        'meaning': 'verified',
        'syllables': 'verified',
        'example': 'needs_review',
      },
    },
    {
      'id': 'school',
      'khmer': 'សាលារៀន',
      'verified_syllables': ['សា', 'លា', 'រៀន'],
      'english': 'School',
      'category': 'education',
      'difficulty': 'hard',
      'image': 'assets/images/vocabulary/school.png',
      'verification': {
        'spelling': 'verified',
        'meaning': 'verified',
        'syllables': 'verified',
        'example': 'needs_review',
      },
    },
    {
      'id': 'butterfly',
      'khmer': 'មេអំបៅ',
      'verified_syllables': ['មេ', 'អំ', 'បៅ'],
      'english': 'Butterfly',
      'category': 'animals',
      'difficulty': 'hard',
      'image': 'assets/images/vocabulary/butterfly.png',
      'verification': {
        'spelling': 'verified',
        'meaning': 'verified',
        'syllables': 'verified',
        'example': 'needs_review',
      },
    },
    {
      'id': 'farmer',
      'khmer': 'កសិករ',
      'verified_syllables': ['ក', 'សិ', 'ករ'],
      'english': 'Farmer',
      'category': 'daily_life',
      'difficulty': 'hard',
      'image': 'assets/images/vocabulary/farmer.png',
      'verification': {
        'spelling': 'verified',
        'meaning': 'verified',
        'syllables': 'verified',
        'example': 'needs_review',
      },
    },
    {
      'id': 'weather',
      'khmer': 'អាកាសធាតុ',
      'verified_syllables': ['អា', 'កាស', 'ធាតុ'],
      'english': 'Weather',
      'category': 'nature',
      'difficulty': 'hard',
      'image': 'assets/images/vocabulary/weather.png',
      'verification': {
        'spelling': 'verified',
        'meaning': 'verified',
        'syllables': 'verified',
        'example': 'needs_review',
      },
    },
    {
      'id': 'milk',
      'khmer': 'ទឹកដោះគោ',
      'verified_syllables': ['ទឹក', 'ដោះ', 'គោ'],
      'english': 'Milk',
      'category': 'food',
      'difficulty': 'hard',
      'image': 'assets/images/vocabulary/milk.png',
      'verification': {
        'spelling': 'verified',
        'meaning': 'verified',
        'syllables': 'verified',
        'example': 'needs_review',
      },
    },
  ]);

  KhmerPuzzleRepository createRepository() => KhmerPuzzleRepository(
    loader: KhmerVocabularyLoader(
      assetBundle: _InMemoryVocabBundle(sampleJson),
    ),
  );

  PuzzleIntegrationAdapter createDeterministicAdapter(
    KhmerPuzzleRepository repo, {
    PuzzleScoreCalculator? scoreCalculator,
  }) {
    return PuzzleIntegrationAdapter(
      repository: repo,
      generator: PuzzleGenerator(repository: repo, random: Random(7)),
      scoreCalculator: scoreCalculator,
    );
  }

  group('Week 2 Integration: PuzzleRequest -> Screen -> CompletionEvent', () {
    testWidgets(
      'PictureMatching emits hint feedback, wrong-answer feedback, and single completion event',
      (tester) async {
        final repo = createRepository();
        final adapter = createDeterministicAdapter(
          repo,
          scoreCalculator: (result) => 95,
        );
        const request = PuzzleRequest(
          levelId: 'level_01_village',
          puzzleType: PuzzleType.pictureMatching,
          difficulty: PuzzleDifficulty.easy,
          category: 'animals',
          configuration: PuzzleRequestConfig(targetVocabularyId: 'tiger'),
        );

        final feedbackHistory = <PuzzleResult>[];
        final hints = <HintResponse>[];
        final events = <PuzzleCompletionEvent>[];

        await tester.pumpWidget(
          MaterialApp(
            home: KhmerPuzzleScreen.fromRequest(
              request: request,
              repository: repo,
              adapter: adapter,
              onAnswerFeedback: feedbackHistory.add,
              onHintRequested: hints.add,
              onCompletionEvent: events.add,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Request hint.
        await tester.ensureVisible(find.text('Hint (3/3)'));
        await tester.tap(find.text('Hint (3/3)'));
        await tester.pump();
        expect(hints, hasLength(1));
        expect(hints.single.hasHint, isTrue);

        // Wrong choice triggers answer feedback without completion event.
        final pmWidget = tester.widget<PictureMatchingWidget>(
          find.byType(PictureMatchingWidget),
        );
        final wrongOption = pmWidget.puzzle!.prompt.options.firstWhere(
          (o) => o.label != 'ខ្លា',
        );
        await tester.ensureVisible(find.text(wrongOption.label));
        await tester.tap(find.text(wrongOption.label));
        await tester.pump();
        await tester.ensureVisible(find.text('Submit Answer'));
        await tester.tap(find.text('Submit Answer'));
        await tester.pump();

        expect(feedbackHistory, hasLength(1));
        expect(feedbackHistory.single.isSolved, isFalse);
        expect(events, isEmpty);

        // Correct choice completes puzzle and emits a single event.
        await tester.ensureVisible(find.text('ខ្លា'));
        await tester.tap(find.text('ខ្លា'));
        await tester.pump();
        await tester.ensureVisible(find.text('Submit Answer'));
        await tester.tap(find.text('Submit Answer'));
        await tester.pump();

        expect(feedbackHistory, hasLength(2));
        expect(feedbackHistory.last.isSolved, isTrue);
        expect(events, hasLength(1));
        expect(events.single.levelId, 'level_01_village');
        expect(events.single.vocabularyId, 'tiger');
        expect(events.single.isCompleted, isTrue);
        expect(events.single.isCorrect, isTrue);
        expect(events.single.attempts, 2);
        expect(events.single.hintsUsed, 1);
        expect(events.single.score, 95);
        expect(events.single.educationalNote, 'ខ្លា (klaa) means tiger.');
      },
    );

    testWidgets(
      'PictureMatching emits terminal failure event when max attempts are exhausted',
      (tester) async {
        final repo = createRepository();
        final adapter = createDeterministicAdapter(repo);
        const request = PuzzleRequest(
          levelId: 'level_hard_chase',
          puzzleType: PuzzleType.pictureMatching,
          difficulty: PuzzleDifficulty.hard,
          configuration: PuzzleRequestConfig(targetVocabularyId: 'school'),
        );

        final feedbackHistory = <PuzzleResult>[];
        final events = <PuzzleCompletionEvent>[];

        await tester.pumpWidget(
          MaterialApp(
            home: KhmerPuzzleScreen.fromRequest(
              request: request,
              repository: repo,
              adapter: adapter,
              onAnswerFeedback: feedbackHistory.add,
              onCompletionEvent: events.add,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final pmWidget = tester.widget<PictureMatchingWidget>(
          find.byType(PictureMatchingWidget),
        );
        final wrongOptions = pmWidget.puzzle!.prompt.options
            .where((o) => o.label != 'សាលារៀន')
            .toList();

        // Attempt 1 (wrong).
        await tester.ensureVisible(find.text(wrongOptions[0].label));
        await tester.tap(find.text(wrongOptions[0].label));
        await tester.pump();
        await tester.ensureVisible(find.text('Submit Answer'));
        await tester.tap(find.text('Submit Answer'));
        await tester.pump();
        expect(events, isEmpty);

        // Attempt 2 (different wrong choice -> exhausts hard maxAttempts=2).
        await tester.ensureVisible(find.text(wrongOptions[1].label));
        await tester.tap(find.text(wrongOptions[1].label));
        await tester.pump();
        await tester.ensureVisible(find.text('Submit Answer'));
        await tester.tap(find.text('Submit Answer'));
        await tester.pump();

        expect(feedbackHistory, hasLength(2));
        expect(events, hasLength(1));
        expect(events.single.levelId, 'level_hard_chase');
        expect(events.single.isCompleted, isTrue);
        expect(events.single.isCorrect, isFalse);
        expect(events.single.score, isNull);
        expect(events.single.attempts, 2);
      },
    );

    testWidgets(
      'WordMatching emits mismatch and match feedback plus final completion event',
      (tester) async {
        final repo = createRepository();
        final adapter = createDeterministicAdapter(repo);
        const request = PuzzleRequest(
          levelId: 'level_02_tonle_sap',
          puzzleType: PuzzleType.wordMatching,
          difficulty: PuzzleDifficulty.easy,
          category: 'food',
        );

        final feedbackHistory = <PuzzleResult>[];
        final events = <PuzzleCompletionEvent>[];

        await tester.pumpWidget(
          MaterialApp(
            home: KhmerPuzzleScreen.fromRequest(
              request: request,
              repository: repo,
              adapter: adapter,
              onAnswerFeedback: feedbackHistory.add,
              onCompletionEvent: events.add,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Mismatch pair (ទឹក with Cake).
        await tester.ensureVisible(find.text('ទឹក'));
        await tester.tap(find.text('ទឹក'));
        await tester.pump();
        await tester.ensureVisible(find.text('Cake'));
        await tester.tap(find.text('Cake'));
        await tester.pump();

        expect(feedbackHistory, hasLength(1));
        expect(feedbackHistory.single.isSolved, isFalse);
        expect(events, isEmpty);

        // Match all 3 food pairs cleanly.
        const pairs = [
          ('ទឹក', 'Water'),
          ('បាយ', 'Cooked Rice'),
          ('នំខេក', 'Cake'),
        ];
        for (final (khmer, english) in pairs) {
          await tester.ensureVisible(find.text(khmer));
          await tester.tap(find.text(khmer));
          await tester.pump();
          await tester.ensureVisible(find.text(english));
          await tester.tap(find.text(english));
          await tester.pump();
        }

        expect(feedbackHistory, hasLength(4));
        expect(events, hasLength(1));
        expect(events.single.levelId, 'level_02_tonle_sap');
        expect(events.single.puzzleType, PuzzleType.wordMatching);
        expect(events.single.isCompleted, isTrue);
        expect(events.single.isCorrect, isTrue);
      },
    );

    testWidgets(
      'SyllableOrdering emits wrong-order feedback and completion event after correction',
      (tester) async {
        final repo = createRepository();
        final adapter = createDeterministicAdapter(repo);
        const request = PuzzleRequest(
          levelId: 'level_03_angkor',
          puzzleType: PuzzleType.syllableOrdering,
          difficulty: PuzzleDifficulty.easy,
          category: 'animals',
          configuration: PuzzleRequestConfig(targetVocabularyId: 'elephant'),
        );

        final feedbackHistory = <PuzzleResult>[];
        final events = <PuzzleCompletionEvent>[];

        await tester.pumpWidget(
          MaterialApp(
            home: KhmerPuzzleScreen.fromRequest(
              request: request,
              repository: repo,
              adapter: adapter,
              onAnswerFeedback: feedbackHistory.add,
              onCompletionEvent: events.add,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Wrong syllable order: រី then ដំ.
        await tester.ensureVisible(find.text('រី'));
        await tester.tap(find.text('រី'));
        await tester.pump();
        await tester.ensureVisible(find.text('ដំ'));
        await tester.tap(find.text('ដំ'));
        await tester.pump();
        await tester.ensureVisible(find.text('Check Answer'));
        await tester.tap(find.text('Check Answer'));
        await tester.pump();

        expect(feedbackHistory, hasLength(1));
        expect(feedbackHistory.single.isSolved, isFalse);
        expect(events, isEmpty);

        // Reset and pick correct order: ដំ then រី.
        await tester.ensureVisible(find.text('Reset'));
        await tester.tap(find.text('Reset'));
        await tester.pump();
        await tester.ensureVisible(find.text('ដំ'));
        await tester.tap(find.text('ដំ'));
        await tester.pump();
        await tester.ensureVisible(find.text('រី'));
        await tester.tap(find.text('រី'));
        await tester.pump();
        await tester.ensureVisible(find.text('Check Answer'));
        await tester.tap(find.text('Check Answer'));
        await tester.pump();

        expect(feedbackHistory, hasLength(2));
        expect(feedbackHistory.last.isSolved, isTrue);
        expect(events, hasLength(1));
        expect(events.single.levelId, 'level_03_angkor');
        expect(events.single.vocabularyId, 'elephant');
        expect(events.single.isCompleted, isTrue);
        expect(events.single.isCorrect, isTrue);
        expect(events.single.attempts, 2);
      },
    );

    testWidgets(
      'Invalid PuzzleRequest triggers onLoadError and renders PuzzleErrorView cleanly',
      (tester) async {
        final repo = createRepository();
        const invalidRequest = PuzzleRequest(
          levelId: '',
          puzzleType: PuzzleType.pictureMatching,
          difficulty: PuzzleDifficulty.easy,
        );
        PuzzleIntegrationError? capturedError;

        await tester.pumpWidget(
          MaterialApp(
            home: KhmerPuzzleScreen.fromRequest(
              request: invalidRequest,
              repository: repo,
              onLoadError: (err) => capturedError = err,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(capturedError, isNotNull);
        expect(capturedError!.code, 'INVALID_REQUEST');
        expect(find.byType(PuzzleErrorView), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      },
    );

    testWidgets(
      'PuzzleIntegrationExampleScreen works in landscape viewports and unlocks checkpoint on solve',
      (tester) async {
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final repo = createRepository();
        final adapter = createDeterministicAdapter(repo);

        for (final size in [const Size(844, 390), const Size(1024, 600)]) {
          await tester.binding.setSurfaceSize(size);
          await tester.pumpWidget(
            MaterialApp(
              home: PuzzleIntegrationExampleScreen(
                repository: repo,
                adapter: adapter,
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }

        // Trigger Village Gate Picture checkpoint in landscape mode (1024x600).
        await tester.ensureVisible(find.text('Village Gate (Picture)'));
        await tester.tap(find.text('Village Gate (Picture)'));
        await tester.pumpAndSettle();

        expect(find.text('Picture Matching'), findsOneWidget);
        await tester.ensureVisible(find.text('ខ្លា'));
        await tester.tap(find.text('ខ្លា'));
        await tester.pump();
        await tester.ensureVisible(find.text('Submit Answer'));
        await tester.tap(find.text('Submit Answer'));
        await tester.pump();

        // Close puzzle screen back to Integration Example.
        await tester.tap(find.byTooltip('Close'));
        await tester.pumpAndSettle();

        expect(find.text('Checkpoint Unlocked!'), findsOneWidget);
        expect(find.text('Unlocked'), findsOneWidget);
        expect(find.textContaining('level_01_village_picture'), findsWidgets);
      },
    );

    testWidgets(
      'KhmerPuzzleScreen.showAsDialog returns PuzzleCompletionEvent after overlay closes',
      (tester) async {
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.binding.setSurfaceSize(const Size(1024, 600));

        final repo = createRepository();
        final adapter = createDeterministicAdapter(repo);
        PuzzleCompletionEvent? dialogEvent;

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      dialogEvent = await KhmerPuzzleScreen.showAsDialog(
                        context,
                        request: const PuzzleRequest(
                          levelId: 'flame_checkpoint_dialog',
                          puzzleType: PuzzleType.pictureMatching,
                          difficulty: PuzzleDifficulty.easy,
                          category: 'animals',
                          configuration: PuzzleRequestConfig(
                            targetVocabularyId: 'tiger',
                          ),
                        ),
                        repository: repo,
                        adapter: adapter,
                      );
                    },
                    child: const Text('Open Checkpoint Puzzle'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Checkpoint Puzzle'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await tester.ensureVisible(find.text('ខ្លា'));
        await tester.tap(find.text('ខ្លា'));
        await tester.pump();
        await tester.ensureVisible(find.text('Submit Answer'));
        await tester.tap(find.text('Submit Answer'));
        await tester.pump();

        await tester.tap(find.byTooltip('Close'));
        await tester.pumpAndSettle();

        expect(dialogEvent, isNotNull);
        expect(dialogEvent!.levelId, 'flame_checkpoint_dialog');
        expect(dialogEvent!.isCompleted, isTrue);
        expect(dialogEvent!.isCorrect, isTrue);
      },
    );
  });
}
