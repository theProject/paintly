import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../data/demo_scenes.dart';
import 'scene_coloring_screen.dart';
import '../../providers/settings_provider.dart';
import '../../providers/scene_provider.dart';
import 'package:provider/provider.dart';

class SceneHomeScreen extends StatelessWidget {
  const SceneHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scenes = DemoScenes.getAllScenes();
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: FadeInDown(
                child: Text(
                  '🎨 Color Scenes',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            // Scene grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 250,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: scenes.length,
                itemBuilder: (context, index) {
                  return FadeInUp(
                    delay: Duration(milliseconds: index * 100),
                    child: _buildSceneTile(context, scenes[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSceneTile(BuildContext context, SceneData scene) {
    final scenes = DemoScenes.getAllScenes();
    return GestureDetector(
      onTap: () {
        context.read<SettingsProvider>().playSound('tap.mp3');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SceneColoringScreen(scene: scene),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
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
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Scene preview
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.purple.shade100,
                      Colors.orange.shade100,
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    scene.name.split(' ').map((word) => 
                      word.isNotEmpty ? word[0].toUpperCase() : ''
                    ).join(),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ),
              // Title overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    scene.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              // New badge
              if (scenes.indexOf(scene) == 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Pulse(
                    infinite: true,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
