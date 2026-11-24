import 'package:flame/game.dart';
import 'package:material_ui/material_ui.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final FlameGame game;

  @override
  void initState() {
    super.initState();
    game = FlameGame();
  }

  @override
  void dispose() {
    game.pauseEngine();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: GameWidget(game: game)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: IconButton.filled(
                key: const Key('return-to-home'),
                tooltip: 'Return to Home',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
