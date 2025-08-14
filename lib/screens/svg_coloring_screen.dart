// lib/screens/svg_coloring_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:confetti/confetti.dart';

// Hide the model's SvgColorPalette to avoid the ambiguous_import
import '../models/svg_art.dart' hide SvgColorPalette;

import '../providers/svg_coloring_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/svg_paint_widget.dart';
import '../widgets/svg_color_palette.dart';

class SvgColoringScreen extends StatefulWidget {
  final SvgArt svgArt;

  const SvgColoringScreen({super.key, required this.svgArt});

  @override
  State<SvgColoringScreen> createState() => _SvgColoringScreenState();
}

class _SvgColoringScreenState extends State<SvgColoringScreen> {
  late ConfettiController _confettiController;
  bool _hasShownConfetti = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<SvgColoringProvider>();
      provider.initializeSvgArt(widget.svgArt);
      provider.addListener(_checkCompletion);
    });
  }

  void _checkCompletion() {
    final provider = context.read<SvgColoringProvider>();
    if (provider.isInitialized) {
      if (provider.getProgress() >= 1.0 && !_hasShownConfetti) {
        _hasShownConfetti = true;
        _confettiController.play();
        context.read<SettingsProvider>().playSound('celebration.wav');
      }
    }
  }

  @override
  void dispose() {
    context.read<SvgColoringProvider>().removeListener(_checkCompletion);
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
            widget.svgArt.name,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          Consumer<SvgColoringProvider>(
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
                    child: Consumer<SvgColoringProvider>(
                      builder: (context, provider, child) {
                        if (!provider.isInitialized) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 10.0,
                          boundaryMargin: const EdgeInsets.all(100),
                          child: Center(
                            child: SvgPaintWidget(
                              svgArt: widget.svgArt,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              // This is the widget one.
              const SvgColorPalette(),
            ],
          ),
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
                const Color(0xFF9DDAC8),
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
              final provider = context.read<SvgColoringProvider>();
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
