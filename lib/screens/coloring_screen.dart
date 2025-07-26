import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:confetti/confetti.dart';
import '../models/pixel_art.dart';
import '../providers/coloring_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/pixel_grid_widget.dart';
import '../widgets/color_palette_widget.dart';

class ColoringScreen extends StatefulWidget {
  final PixelArt pixelArt;

  const ColoringScreen({super.key, required this.pixelArt});

  @override
  State<ColoringScreen> createState() => _ColoringScreenState();
}

class _ColoringScreenState extends State<ColoringScreen> {
  late ConfettiController _confettiController;
  bool _hasShownConfetti = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    // Initialize the coloring provider with the selected pixel art
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ColoringProvider>();
      provider.initializePixelArt(widget.pixelArt);
      
      // Add listener to check for completion
      provider.addListener(_checkCompletion);
    });
  }
  
  void _checkCompletion() {
    final provider = context.read<ColoringProvider>();
    
    if (provider.isInitialized) {
      // Check for completion
      if (provider.getProgress() >= 1.0 && !_hasShownConfetti) {
        _hasShownConfetti = true;
        _confettiController.play();
        context.read<SettingsProvider>().playSound('complete.mp3');
      }
    }
  }
  
  @override
  void dispose() {
    context.read<ColoringProvider>().removeListener(_checkCompletion);
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        title: FadeIn(
          child: Text(
            widget.pixelArt.name,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          Consumer<ColoringProvider>(
            builder: (context, provider, child) {
              final progress = provider.getProgress();
              return Container(
                margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      progress >= 1.0 ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: progress >= 1.0 ? Colors.amber : colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: Colors.grey[700]),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (value) {
              if (value == 'reset') {
                _showResetDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.refresh_rounded, size: 20),
                    SizedBox(width: 12),
                    Text('Reset Progress'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Main canvas area
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Consumer<ColoringProvider>(
                      builder: (context, provider, child) {
                        if (!provider.isInitialized) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 10.0,
                          boundaryMargin: const EdgeInsets.all(100),
                          child: Center(
                            child: Hero(
                              tag: 'pixel_art_${widget.pixelArt.name}',
                              child: PixelGridWidget(
                                pixelArt: widget.pixelArt,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              // Color palette
              const ColorPaletteWidget(),
            ],
          ),
          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [
                colorScheme.primary,
                colorScheme.secondary,
                colorScheme.tertiary,
                Colors.pink,
                Colors.yellow,
                const Color(0xFF9DDAC8), // Mint color
              ],
              numberOfParticles: 50,
              gravity: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Reset Progress?'),
        content: const Text('This will clear all your coloring progress for this image.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final provider = context.read<ColoringProvider>();
              
              provider.resetProgress();
              _hasShownConfetti = false;
              
              Navigator.pop(context);
            },
            child: Text(
              'Reset',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}