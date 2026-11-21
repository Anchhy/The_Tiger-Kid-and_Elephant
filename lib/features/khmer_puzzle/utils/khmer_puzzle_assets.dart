/// Semantic folder categories for Khmer vocabulary illustrations.
enum VocabularyAssetCategory {
  animals('animals'),
  fruits('fruits'),
  food('food'),
  nature('nature'),
  transportation('transportation'),
  occupations('occupations'),
  household('household'),
  cambodianCulture('cambodian_culture');

  const VocabularyAssetCategory(this.folderName);

  final String folderName;
}

/// Centralized asset path configuration for all M3 Khmer puzzle & game visuals.
///
/// Prevents hardcoded asset strings across widgets and screens while keeping
/// full backward compatibility with flat `assets/images/vocabulary/<id>.png`
/// paths referenced in `assets/data/khmer_vocabulary.json`.
abstract final class KhmerPuzzleAssets {
  // ---------------------------------------------------------------------------
  // Backgrounds
  // ---------------------------------------------------------------------------
  static const String angkorMazeBackground =
      'assets/images/backgrounds/angkor_temple_maze_bg.jpg';
  static const String angkorHeaderBanner =
      'assets/images/backgrounds/angkor_parchment_header_bg.png';

  // ---------------------------------------------------------------------------
  // Extracted Character Sprites (Transparent PNGs)
  // ---------------------------------------------------------------------------
  static const String kidHero = 'assets/images/characters/kid_hero.png';
  static const String kidIdleMap = 'assets/images/characters/kid_idle_map.png';
  static const String kidWalkMap = 'assets/images/characters/kid_walk_map.png';
  static const String kidRun = 'assets/images/characters/kid_run.png';
  static const String kidStartled = 'assets/images/characters/kid_startled.png';

  static const String tigerHero = 'assets/images/characters/tiger_hero.png';
  static const List<String> tigerWalkFrames = [
    'assets/images/characters/tiger_walk_1.png',
    'assets/images/characters/tiger_walk_2.png',
    'assets/images/characters/tiger_walk_3.png',
    'assets/images/characters/tiger_walk_4.png',
  ];

  static const String elephantHero =
      'assets/images/characters/elephant_hero.png';
  static const List<String> elephantWalkFrames = [
    'assets/images/characters/elephant_walk_1.png',
    'assets/images/characters/elephant_walk_2.png',
    'assets/images/characters/elephant_walk_3.png',
    'assets/images/characters/elephant_walk_4.png',
  ];

  // ---------------------------------------------------------------------------
  // Carved Stone & HUD Buttons
  // ---------------------------------------------------------------------------
  static const String playStoneButton =
      'assets/images/buttons/btn_play_stone.png';
  static const String dictionaryButton =
      'assets/images/buttons/btn_dictionary_round.png';
  static const String soundButton = 'assets/images/buttons/btn_sound_round.png';
  static const String settingsButton =
      'assets/images/buttons/btn_settings_round.png';
  static const String pauseButton = 'assets/images/buttons/btn_pause_round.png';
  static const String mapPeekButton =
      'assets/images/buttons/btn_map_peek_round.png';
  static const String sprintButton =
      'assets/images/buttons/btn_sprint_round.png';

  // ---------------------------------------------------------------------------
  // HUD Icons
  // ---------------------------------------------------------------------------
  static const String tigerThreatIcon =
      'assets/images/icons/icon_tiger_threat.png';
  static const String checkpointSteleIcon =
      'assets/images/icons/icon_checkpoint_stele.png';
  static const String angkorCoinIcon =
      'assets/images/icons/icon_angkor_coin.png';
  static const String hintLanternIcon =
      'assets/images/icons/icon_hint_lantern.png';

  // ---------------------------------------------------------------------------
  // Rewards & Outcome Visuals
  // ---------------------------------------------------------------------------
  static const String threeStars =
      'assets/images/rewards/reward_three_stars.png';
  static const String singleStar =
      'assets/images/rewards/reward_single_star.png';
  static const String victoryDuo =
      'assets/images/rewards/reward_victory_duo.png';

  // ---------------------------------------------------------------------------
  // Level Nodes & Stele Landmarks
  // ---------------------------------------------------------------------------
  static const String levelCompleted =
      'assets/images/levels/level_node_completed.png';
  static const String levelActive =
      'assets/images/levels/level_node_active.png';
  static const String levelLocked =
      'assets/images/levels/level_gate_locked.png';
  static const String checkpointStele =
      'assets/images/levels/level_stele_checkpoint.png';

  // ---------------------------------------------------------------------------
  // Categorized Vocabulary Resolution
  // ---------------------------------------------------------------------------
  static const Map<String, VocabularyAssetCategory> _idToCategory = {
    'tiger': VocabularyAssetCategory.animals,
    'elephant': VocabularyAssetCategory.animals,
    'butterfly': VocabularyAssetCategory.animals,
    'cow': VocabularyAssetCategory.animals,
    'dog': VocabularyAssetCategory.animals,
    'cat': VocabularyAssetCategory.animals,
    'fish': VocabularyAssetCategory.animals,
    'duck': VocabularyAssetCategory.animals,
    'chicken': VocabularyAssetCategory.animals,
    'crab': VocabularyAssetCategory.animals,
    'monkey': VocabularyAssetCategory.animals,
    'bird': VocabularyAssetCategory.animals,
    'frog': VocabularyAssetCategory.animals,
    'honeybee': VocabularyAssetCategory.animals,
    'fruit': VocabularyAssetCategory.fruits,
    'banana': VocabularyAssetCategory.fruits,
    'coconut': VocabularyAssetCategory.fruits,
    'corn': VocabularyAssetCategory.fruits,
    'lemon': VocabularyAssetCategory.fruits,
    'water': VocabularyAssetCategory.food,
    'rice': VocabularyAssetCategory.food,
    'cake': VocabularyAssetCategory.food,
    'bread': VocabularyAssetCategory.food,
    'egg': VocabularyAssetCategory.food,
    'vegetables': VocabularyAssetCategory.food,
    'milk': VocabularyAssetCategory.food,
    'flower': VocabularyAssetCategory.nature,
    'forest': VocabularyAssetCategory.nature,
    'environment': VocabularyAssetCategory.nature,
    'weather': VocabularyAssetCategory.nature,
    'mountain': VocabularyAssetCategory.nature,
    'rain': VocabularyAssetCategory.nature,
    'moon': VocabularyAssetCategory.nature,
    'star': VocabularyAssetCategory.nature,
    'river': VocabularyAssetCategory.nature,
    'boat': VocabularyAssetCategory.transportation,
    'bicycle': VocabularyAssetCategory.transportation,
    'car': VocabularyAssetCategory.transportation,
    'bus': VocabularyAssetCategory.transportation,
    'farmer': VocabularyAssetCategory.occupations,
    'teacher': VocabularyAssetCategory.occupations,
    'house': VocabularyAssetCategory.household,
    'book': VocabularyAssetCategory.household,
    'chair': VocabularyAssetCategory.household,
    'pencil': VocabularyAssetCategory.household,
    'pen': VocabularyAssetCategory.household,
    'clock': VocabularyAssetCategory.household,
    'bell': VocabularyAssetCategory.household,
    'lamp': VocabularyAssetCategory.household,
    'key': VocabularyAssetCategory.household,
    'kid': VocabularyAssetCategory.cambodianCulture,
    'country': VocabularyAssetCategory.cambodianCulture,
    'school': VocabularyAssetCategory.cambodianCulture,
    'grandfather': VocabularyAssetCategory.cambodianCulture,
    'grandmother': VocabularyAssetCategory.cambodianCulture,
    'father': VocabularyAssetCategory.cambodianCulture,
    'student': VocabularyAssetCategory.cambodianCulture,
    'bridge': VocabularyAssetCategory.cambodianCulture,
    'drum': VocabularyAssetCategory.cambodianCulture,
    'crown': VocabularyAssetCategory.cambodianCulture,
  };

  /// Returns either the categorized asset path (when [category] is passed)
  /// or the dataset-compatible flat vocabulary path `assets/images/vocabulary/$id.png`.
  static String vocabularyPath(String id, {VocabularyAssetCategory? category}) {
    final normalizedId = id.trim();
    if (category != null) {
      return 'assets/images/vocabulary/${category.folderName}/$normalizedId.png';
    }
    return 'assets/images/vocabulary/$normalizedId.png';
  }

  /// Resolves the categorized path for known starter vocabulary [id]s,
  /// falling back to the flat path when unmapped.
  static String categorizedVocabularyPath(String id) {
    final normalizedId = id.trim();
    final category = _idToCategory[normalizedId];
    return vocabularyPath(normalizedId, category: category);
  }

  /// Complete registry of verified extracted & vocabulary image assets
  /// for automated bundle validation in tests.
  static const String gameIconCompass = 'assets/icons/game_icons/compass.png';
  static const String gameIconOpenBook =
      'assets/icons/game_icons/open_book.png';
  static const String gameIconCoins = 'assets/icons/game_icons/coins.png';
  static const String gameIconCog = 'assets/icons/game_icons/cog.png';
  static const String gameIconSpeaker = 'assets/icons/game_icons/speaker.png';
  static const String gameIconPadlock = 'assets/icons/game_icons/padlock.png';
  static const String gameIconTrophy = 'assets/icons/game_icons/trophy.png';
  static const String gameIconStarsStack =
      'assets/icons/game_icons/stars_stack.png';
  static const String gameIconCandleFlame =
      'assets/icons/game_icons/candle_flame.png';
  static const String gameIconLightBulb =
      'assets/icons/game_icons/light_bulb.png';
  static const String gameIconTiedScroll =
      'assets/icons/game_icons/tied_scroll.png';

  static const String kenneyUiButton =
      'assets/ui/kenney_ui/button_rectangle_depth_flat.png';
  static const String kenneyUiButtonBorder =
      'assets/ui/kenney_ui/button_rectangle_border.png';

  static const List<String> angkorHeritagePlates = [
    'assets/environments/angkor_reference/delaporte_1880_angkor_p014.jpg',
    'assets/environments/angkor_reference/delaporte_1880_angkor_p156.jpg',
    'assets/environments/angkor_reference/delaporte_1880_angkor_p469.jpg',
  ];

  static const List<String> kenneyFoliageSamples = [
    'assets/environments/foliage/sprite_0001.png',
    'assets/environments/foliage/sprite_0002.png',
    'assets/environments/foliage/sprite_0003.png',
  ];

  static const String kenneyDockWaterSample =
      'assets/environments/docks/tile_01.png';
  static const String uiClickAudio = 'assets/audio/ui/click_001.ogg';
  static const String uiSuccessAudio = 'assets/audio/ui/bong_001.ogg';
  static const String rpgBookOpenAudio = 'assets/audio/rpg/bookOpen.ogg';

  static List<String> get allRegisteredImageAssets => [
    angkorMazeBackground,
    angkorHeaderBanner,
    kidHero,
    kidIdleMap,
    kidWalkMap,
    kidRun,
    kidStartled,
    tigerHero,
    ...tigerWalkFrames,
    elephantHero,
    ...elephantWalkFrames,
    playStoneButton,
    dictionaryButton,
    soundButton,
    settingsButton,
    pauseButton,
    mapPeekButton,
    sprintButton,
    tigerThreatIcon,
    checkpointSteleIcon,
    angkorCoinIcon,
    hintLanternIcon,
    threeStars,
    singleStar,
    victoryDuo,
    levelCompleted,
    levelActive,
    levelLocked,
    checkpointStele,
    gameIconCompass,
    gameIconOpenBook,
    gameIconCoins,
    gameIconCog,
    gameIconSpeaker,
    gameIconPadlock,
    gameIconTrophy,
    gameIconStarsStack,
    gameIconCandleFlame,
    gameIconLightBulb,
    gameIconTiedScroll,
    kenneyUiButton,
    kenneyUiButtonBorder,
    ...angkorHeritagePlates,
    ...kenneyFoliageSamples,
    kenneyDockWaterSample,
    for (final entry in _idToCategory.entries) ...[
      vocabularyPath(entry.key),
      vocabularyPath(entry.key, category: entry.value),
    ],
  ];
}
