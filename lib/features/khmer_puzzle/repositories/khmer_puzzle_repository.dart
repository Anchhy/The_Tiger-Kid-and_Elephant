import '../data/khmer_vocabulary_loader.dart';
import '../models/puzzle_enums.dart';
import '../models/vocabulary_item.dart';

/// Filter options for selecting suitable vocabulary entries for a puzzle.
class VocabularyQuery {
  const VocabularyQuery({
    this.difficulty,
    this.category,
    this.onlyVerifiedSpelling = false,
    this.onlyVerifiedMeaning = false,
    this.onlyVerifiedSyllables = false,
    this.requireImage = false,
    this.requireMultiSyllable = false,
  });

  final PuzzleDifficulty? difficulty;
  final String? category;
  final bool onlyVerifiedSpelling;
  final bool onlyVerifiedMeaning;
  final bool onlyVerifiedSyllables;
  final bool requireImage;
  final bool requireMultiSyllable;
}

/// Provides cached and filtered Khmer vocabulary data to puzzle generators.
class KhmerPuzzleRepository {
  KhmerPuzzleRepository({KhmerVocabularyLoader? loader})
    : _loader = loader ?? KhmerVocabularyLoader();

  final KhmerVocabularyLoader _loader;
  List<VocabularyItem>? _cachedItems;

  /// Returns all vocabulary items, loading from JSON once and caching in memory.
  Future<List<VocabularyItem>> getAllVocabulary() async {
    _cachedItems ??= await _loader.loadVocabulary();
    return List<VocabularyItem>.unmodifiable(_cachedItems!);
  }

  /// Returns vocabulary items matching the given [query] rules.
  Future<List<VocabularyItem>> queryVocabulary(VocabularyQuery query) async {
    final items = await getAllVocabulary();
    final targetCategory = query.category?.trim().toLowerCase();

    return items
        .where((item) {
          if (query.difficulty != null && item.difficulty != query.difficulty) {
            return false;
          }
          if (targetCategory != null &&
              targetCategory.isNotEmpty &&
              item.category.toLowerCase() != targetCategory) {
            return false;
          }
          if (query.onlyVerifiedSpelling &&
              !item.verification.isSpellingVerified) {
            return false;
          }
          if (query.onlyVerifiedMeaning &&
              !item.verification.isMeaningVerified) {
            return false;
          }
          if (query.onlyVerifiedSyllables &&
              !item.verification.areSyllablesVerified) {
            return false;
          }
          if (query.requireImage && !item.hasImage) {
            return false;
          }
          if (query.requireMultiSyllable && !item.supportsSyllableOrdering) {
            return false;
          }
          return true;
        })
        .toList(growable: false);
  }

  /// Returns vocabulary items filtered by [difficulty].
  Future<List<VocabularyItem>> getVocabularyByDifficulty(
    PuzzleDifficulty difficulty,
  ) {
    return queryVocabulary(VocabularyQuery(difficulty: difficulty));
  }

  /// Returns vocabulary items filtered by [category].
  Future<List<VocabularyItem>> getVocabularyByCategory(String category) {
    return queryVocabulary(VocabularyQuery(category: category));
  }

  /// Returns vocabulary items for [difficulty] that have 2+ syllable segments.
  Future<List<VocabularyItem>> getSyllableOrderingVocabulary(
    PuzzleDifficulty difficulty, {
    bool requireVerifiedSyllables = false,
  }) {
    return queryVocabulary(
      VocabularyQuery(
        difficulty: difficulty,
        requireMultiSyllable: true,
        onlyVerifiedSyllables: requireVerifiedSyllables,
      ),
    );
  }

  /// Looks up a single vocabulary item by [id], or `null` if not found.
  Future<VocabularyItem?> findById(String id) async {
    final items = await getAllVocabulary();
    for (final item in items) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  /// Looks up a single vocabulary item by [id], throwing [StateError] if missing.
  Future<VocabularyItem> getByIdOrThrow(String id) async {
    final item = await findById(id);
    if (item == null) {
      throw StateError('Vocabulary item "$id" was not found.');
    }
    return item;
  }

  /// Clears the in-memory cache so the next query reloads from JSON.
  void clearCache() {
    _cachedItems = null;
  }
}
