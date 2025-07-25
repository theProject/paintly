import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:confetti/confetti.dart';
import '../../providers/scene_provider.dart';
import '../../providers/settings_provider.dart';
import '../widgets/scene_canvas.dart';
import '../widgets/scene_color_palette.dart';

class SceneColoringScreen extends StatefulWidget {
  final SceneData scene;

  const SceneColoringScreen({super.key, required this.scene});

  @override
  State<SceneColoringScreen> createState() => _SceneColoringScreenState();
}

class _SceneColoringScreenState extends State<SceneColoringScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    // Load the scene
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SceneProvider>().loadScene(widget.scene);
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: FadeIn(
          child: Text(
            widget.scene.name,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          Consumer<SceneProvider>(
            builder: (context, provider, child) {
              final progress = provider.getProgress();
              return Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: progress > 0 ? Colors.orange : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Scene canvas
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Consumer<SceneProvider>(
                      builder: (context, provider, child) {
                        // Check for completion
                        if (provider.isComplete() && _confettiController.state != ConfettiControllerState.playing) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _confettiController.play();
                            context.read<SettingsProvider>().playSound('complete.mp3');
                          });
                        }
                        
                        return const SceneCanvas();
                      },
                    ),
                  ),
                ),
              ),
              // Color palette
              const SceneColorPalette(),
            ],
          ),
          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.yellow,
                Colors.purple,
                Colors.orange,
              ],
              numberOfParticles: 50,
            ),
          ),
        ],
      ),
    );
  }
}