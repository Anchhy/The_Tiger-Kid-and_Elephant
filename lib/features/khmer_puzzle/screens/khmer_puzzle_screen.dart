import 'package:flutter/material.dart';

import '../models/puzzle.dart';
import '../models/puzzle_enums.dart';
import '../models/puzzle_result.dart';
import '../repositories/khmer_puzzle_repository.dart';
import '../services/puzzle_generator.dart';
import '../services/puzzle_hint_service.dart';
import '../services/puzzle_validation_service.dart';
import '../widgets/picture_matching_widget.dart';
import '../widgets/puzzle_state_views.dart';
import '../widgets/syllable_ordering_widget.dart';
import '../widgets/word_matching_widget.dart';

/// Public entry-point screen for launching any M3 Khmer puzzle mode.
///
/// External modules (such as M2 gameplay checkpoints or M5 navigation) can
/// push or embed this widget without knowing internal puzzle details.
class KhmerPuzzleScreen extends StatefulWidget {
  const KhmerPuzzleScreen({
    super.key,
    required this.puzzleType,
    required this.difficulty,
    this.repository,
    this.category,
    this.targetVocabularyId,
    this.requireVerifiedSyllables = true,
    this.requireImage = false,
    this.onCompleted,
    this.imageBuilder,
  });

  final PuzzleType puzzleType;
  final PuzzleDifficulty difficulty;
  final KhmerPuzzleRepository? repository;
  final String? category;
  final String? targetVocabularyId;
  final bool requireVerifiedSyllables;
  final bool requireImage;
  final ValueChanged<PuzzleResult>? onCompleted;
  final VocabularyImageBuilder? imageBuilder;

  @override
  State<KhmerPuzzleScreen> createState() => _KhmerPuzzleScreenState();
}

class _KhmerPuzzleScreenState extends State<KhmerPuzzleScreen> {
  late KhmerPuzzleRepository _repository;
  late PuzzleGenerator _generator;

  Puzzle? _puzzle;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initAndLoad();
  }

  @override
  void didUpdateWidget(covariant KhmerPuzzleScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.puzzleType != widget.puzzleType ||
        oldWidget.difficulty != widget.difficulty ||
        oldWidget.repository != widget.repository ||
        oldWidget.category != widget.category ||
        oldWidget.targetVocabularyId != widget.targetVocabularyId ||
        oldWidget.requireVerifiedSyllables != widget.requireVerifiedSyllables) {
      _initAndLoad();
    }
  }

  void _initAndLoad() {
    _repository = widget.repository ?? KhmerPuzzleRepository();
    _generator = PuzzleGenerator(repository: _repository);
    _loadPuzzle();
  }

  Future<void> _loadPuzzle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final generated = await _generator.generate(
        type: widget.puzzleType,
        difficulty: widget.difficulty,
        category: widget.category,
        targetVocabularyId: widget.targetVocabularyId,
        requireVerifiedSyllables: widget.requireVerifiedSyllables,
        requireImage: widget.requireImage,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _puzzle = generated;
        _isLoading = false;
      });
    } on Exception catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _puzzle = null;
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  void _closeScreen() {
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    const validator = PuzzleValidationService();
    const hintService = PuzzleHintService();

    final body = switch (widget.puzzleType) {
      PuzzleType.pictureMatching => PictureMatchingWidget(
        puzzle: _puzzle,
        isLoading: _isLoading,
        errorMessage: _errorMessage,
        onRetry: _loadPuzzle,
        onClose: _closeScreen,
        onCompleted: widget.onCompleted,
        validator: validator,
        hintService: hintService,
        imageBuilder: widget.imageBuilder,
      ),
      PuzzleType.wordMatching => WordMatchingWidget(
        puzzle: _puzzle,
        isLoading: _isLoading,
        errorMessage: _errorMessage,
        onRetry: _loadPuzzle,
        onClose: _closeScreen,
        onCompleted: widget.onCompleted,
        validator: validator,
        hintService: hintService,
      ),
      PuzzleType.syllableOrdering => SyllableOrderingWidget(
        puzzle: _puzzle,
        isLoading: _isLoading,
        errorMessage: _errorMessage,
        onRetry: _loadPuzzle,
        onClose: _closeScreen,
        onCompleted: widget.onCompleted,
        validator: validator,
        hintService: hintService,
      ),
    };

    return Scaffold(body: SafeArea(child: body));
  }
}
