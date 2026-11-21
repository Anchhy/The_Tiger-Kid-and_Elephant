import 'package:flutter/material.dart';

import '../models/puzzle_enums.dart';
import '../models/puzzle_result.dart';
import '../repositories/khmer_puzzle_repository.dart';
import 'khmer_puzzle_screen.dart';

/// Screen wrapper for launching a Word Matching puzzle directly.
class WordMatchingScreen extends StatelessWidget {
  const WordMatchingScreen({
    super.key,
    required this.difficulty,
    this.repository,
    this.onCompleted,
  });

  final PuzzleDifficulty difficulty;
  final KhmerPuzzleRepository? repository;
  final ValueChanged<PuzzleResult>? onCompleted;

  @override
  Widget build(BuildContext context) {
    return KhmerPuzzleScreen(
      puzzleType: PuzzleType.wordMatching,
      difficulty: difficulty,
      repository: repository,
      onCompleted: onCompleted,
    );
  }
}
