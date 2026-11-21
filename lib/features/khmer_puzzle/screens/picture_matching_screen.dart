import 'package:flutter/material.dart';

import '../models/puzzle_enums.dart';
import '../models/puzzle_result.dart';
import '../repositories/khmer_puzzle_repository.dart';
import '../widgets/puzzle_state_views.dart';
import 'khmer_puzzle_screen.dart';

/// Screen wrapper for launching a Picture Matching puzzle directly.
class PictureMatchingScreen extends StatelessWidget {
  const PictureMatchingScreen({
    super.key,
    required this.difficulty,
    this.repository,
    this.onCompleted,
    this.imageBuilder,
  });

  final PuzzleDifficulty difficulty;
  final KhmerPuzzleRepository? repository;
  final ValueChanged<PuzzleResult>? onCompleted;
  final VocabularyImageBuilder? imageBuilder;

  @override
  Widget build(BuildContext context) {
    return KhmerPuzzleScreen(
      puzzleType: PuzzleType.pictureMatching,
      difficulty: difficulty,
      repository: repository,
      onCompleted: onCompleted,
      imageBuilder: imageBuilder,
    );
  }
}
