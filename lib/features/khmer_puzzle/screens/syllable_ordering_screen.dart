import 'package:flutter/material.dart';

import '../models/puzzle_enums.dart';
import '../models/puzzle_result.dart';
import '../repositories/khmer_puzzle_repository.dart';
import 'khmer_puzzle_screen.dart';

/// Screen wrapper for launching a Syllable Ordering puzzle directly.
class SyllableOrderingScreen extends StatelessWidget {
  const SyllableOrderingScreen({
    super.key,
    required this.difficulty,
    this.repository,
    this.requireVerifiedSyllables = true,
    this.onCompleted,
  });

  final PuzzleDifficulty difficulty;
  final KhmerPuzzleRepository? repository;
  final bool requireVerifiedSyllables;
  final ValueChanged<PuzzleResult>? onCompleted;

  @override
  Widget build(BuildContext context) {
    return KhmerPuzzleScreen(
      puzzleType: PuzzleType.syllableOrdering,
      difficulty: difficulty,
      repository: repository,
      requireVerifiedSyllables: requireVerifiedSyllables,
      onCompleted: onCompleted,
    );
  }
}
