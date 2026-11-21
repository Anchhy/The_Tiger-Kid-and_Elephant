import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/vocabulary_item.dart';

/// Loads and validates Khmer vocabulary records from the bundled JSON dataset.
class KhmerVocabularyLoader {
  KhmerVocabularyLoader({
    AssetBundle? assetBundle,
    this.assetPath = defaultAssetPath,
  }) : _assetBundle = assetBundle ?? rootBundle;

  static const String defaultAssetPath = 'assets/data/khmer_vocabulary.json';

  final AssetBundle _assetBundle;
  final String assetPath;

  /// Reads, decodes, and validates vocabulary items from [assetPath].
  ///
  /// Throws a [FormatException] when the JSON structure, required fields,
  /// Khmer syllable segments, or ID uniqueness are invalid.
  Future<List<VocabularyItem>> loadVocabulary() async {
    final rawJson = await _assetBundle.loadString(assetPath);
    if (rawJson.trim().isEmpty) {
      throw const FormatException('Vocabulary JSON dataset is empty.');
    }

    final dynamic decoded = jsonDecode(rawJson);
    if (decoded is! List) {
      throw const FormatException(
        'Vocabulary JSON root must be a list of vocabulary entries.',
      );
    }

    final items = <VocabularyItem>[];
    final seenIds = <String>{};

    for (var i = 0; i < decoded.length; i++) {
      final entry = decoded[i];
      if (entry is! Map<String, dynamic>) {
        throw FormatException(
          'Vocabulary entry at index $i must be a JSON object.',
        );
      }

      final item = VocabularyItem.fromJson(entry);
      if (!seenIds.add(item.id)) {
        throw FormatException('Duplicate vocabulary id "${item.id}".');
      }
      items.add(item);
    }

    if (items.isEmpty) {
      throw const FormatException('Vocabulary dataset contains no items.');
    }

    return List<VocabularyItem>.unmodifiable(items);
  }
}
