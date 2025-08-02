import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import 'package:animate_do/animate_do.dart';

import '../../providers/settings_provider.dart';
import '../../providers/scene_provider.dart';
import '../../models/magic_object.dart';
import '../data/magic_categories.dart';
import '../widgets/advanced_svg_coloring_widget.dart';

class MagicColoringScreen extends StatefulWidget {
  final MagicObject object;
  final MagicCategory category;
  final bool isCustomizing;

  const MagicColoringScreen({
    super.key,
    required this.object,
    required this.category,
    this.isCustomizing = false,
  });

  @override
  State<MagicColoringScreen> createState() => _MagicColoringScreenState();
}

class _MagicColoringScreenState extends State<MagicColoringScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _progressController;
  late AnimationController _hintController;
  late AnimationController _completionController;
  
  Map<String, Color> coloredRegions = {};
  Map<String, String> regionNumbers = {};
  String? selectedRegion;
  Color? selectedColor;
  bool isCompleted = false;
  bool showHint = false;
  int coloredCount = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _hintController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _completionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _initializeColoring();
    _showHintIfNeeded();
  }

  void _initializeColoring() {
    // Load existing progress if any
    _loadProgress();
    
    // Set up region numbers
    regionNumbers = widget.object.getNumberedRegions(isCustomizing: widget.isCustomizing);
    
    // Initialize predefined colors for first-time coloring
    if (!widget.isCustomizing) {
      coloredRegions.addAll(widget.object.predefinedColors);
      coloredCount = widget.object.predefinedColors.length;
    }
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('magic_colors_${widget.category.id}_${widget.object.id}');
    
    if (savedData != null) {
      final Map<String, dynamic> data = json.decode(savedData);
      setState(() {
        coloredRegions = data.map((key, value) => MapEntry(key, Color(value)));
        if (widget.isCustomizing) {
          // Count only customizable regions
          coloredCount = widget.object.customizableRegions.keys
              .where((region) => coloredRegions.containsKey(region))
              .length;
        } else {
          coloredCount = coloredRegions.length;
        }
      });
    }
  }

  void _showHintIfNeeded() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && !widget.isCustomizing && coloredCount == widget.object.predefinedColors.length) {
        setState(() => showHint = true);
        _hintController.forward();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _progressController.dispose();
    _hintController.dispose();
    _completionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.category.color.withOpacity(0.05),
                  widget.category.color.withOpacity(0.1),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildCanvas()),
                if (selectedRegion != null) _buildColorPalette(),
              ],
            ),
          ),
          
          // Hint overlay
          if (showHint) _buildHintOverlay(),
          
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
              colors: [
                widget.category.color,
                Colors.yellow,
                Colors.pink,
                Colors.purple,
                Colors.orange,
              ],
            ),
          ),
          
          // Completion overlay
          if (isCompleted) _buildCompletionOverlay(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final progress = _calculateProgress();
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.grey[800],
              padding: const EdgeInsets.all(12),
              elevation: 2,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.object.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  widget.isCustomizing 
                      ? 'Customize your ${widget.object.name.toLowerCase()}'
                      : 'Color by numbers',
                  style: TextStyle(
                    color: widget.category.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Progress indicator
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(widget.category.color),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: widget.category.color,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: widget.category.color.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 3.0,
          boundaryMargin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: AdvancedSvgColoringWidget(
              svgPath: widget.object.svgPath,
              coloredRegions: coloredRegions,
              regionNumbers: regionNumbers,
              predefinedColors: widget.object.predefinedColors,
              customizableRegions: widget.object.customizableRegions,
              isCustomizing: widget.isCustomizing,
              onRegionTap: _onRegionTapped,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorPalette() {
    final colors = widget.object.customizableRegions[selectedRegion] ?? [];
    
    if (colors.isEmpty) return const SizedBox.shrink();
    
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Region info
          Text(
            'Choose color for ${regionNumbers[selectedRegion]} - ${selectedRegion?.replaceAll('_', ' ')}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Color options
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: colors.length,
              itemBuilder: (context, index) {
                final color = colors[index];
                final isSelected = coloredRegions[selectedRegion] == color;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: GestureDetector(
                    onTap: () => _selectColor(color),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isSelected ? 72 : 64,
                      height: isSelected ? 72 : 64,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.grey[300]!,
                          width: isSelected ? 3 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: isSelected ? 12 : 8,
                            spreadRadius: isSelected ? 2 : 0,
                          ),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 32,
                            )
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHintOverlay() {
    return GestureDetector(
      onTap: () {
        setState(() => showHint = false);
        _hintController.reverse();
      },
      child: AnimatedBuilder(
        animation: _hintController,
        builder: (context, child) {
          return Container(
            color: Colors.black.withValues(alpha: 0.5 * _hintController.value),
            child: Center(
              child: ScaleTransition(
                scale: _hintController,
                child: Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        size: 64,
                        color: widget.category.color,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Tap the numbered areas!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Each number shows where you can add color',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompletionOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (true) // Replace with actual Lottie file check
              const Icon(
                Icons.celebration_rounded,
                size: 120,
                color: widget.category.color,
              )
            else
              Lottie.asset(
                'assets/animations/confetti.json',
                width: 300,
                height: 300,
                repeat: false,
              ),
            const SizedBox(height: 24),
            ElasticIn(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: widget.category.color,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Amazing Work! 🎉',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Continue',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onRegionTapped(String regionId) {
    // Check if region is colorable
    if (!widget.object.isRegionColorable(regionId, isCustomizing: widget.isCustomizing)) {
      // Show locked message
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('This part is locked'),
                            backgroundColor: widget.category.color,
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }
    
    setState(() {
      selectedRegion = regionId;
      selectedColor = coloredRegions[regionId];
      showHint = false;
    });
    
    HapticFeedback.selectionClick();
  }

  void _selectColor(Color color) {
    if (selectedRegion == null) return;
    
    setState(() {
      final wasColored = coloredRegions.containsKey(selectedRegion);
      coloredRegions[selectedRegion!] = color;
      selectedColor = color;
      
      if (!wasColored) {
        coloredCount++;
        _checkCompletion();
      }
    });
    
    HapticFeedback.lightImpact();
    _saveProgress();
  }

  double _calculateProgress() {
    final total = widget.object.getTotalRegions(isCustomizing: widget.isCustomizing);
    if (total == 0) return 0;
    
    if (widget.isCustomizing) {
      // Count only customizable regions
      final coloredCustomizable = widget.object.customizableRegions.keys
          .where((region) => coloredRegions.containsKey(region))
          .length;
      return coloredCustomizable / widget.object.customizableRegions.length;
    } else {
      return coloredCount / total;
    }
  }

  void _checkCompletion() {
    final progress = _calculateProgress();
    if (progress >= 1.0 && !isCompleted) {
      setState(() => isCompleted = true);
      _completionController.forward();
      _confettiController.play();
      HapticFeedback.heavyImpact();
      context.read<SettingsProvider>().playSound('audio/celebration.wav');
      
      _saveCompletion();
    }
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save color data
    final colorData = coloredRegions.map((key, value) => MapEntry(key, value.toARGB32()));
    await prefs.setString(
      'magic_colors_${widget.category.id}_${widget.object.id}',
      json.encode(colorData),
    );
  }

  Future<void> _saveCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Mark as completed
    await prefs.setBool(
      'magic_completed_${widget.category.id}_${widget.object.id}',
      true,
    );
    
    // Add to Scene Mode
    if (mounted) {
      final sceneProvider = context.read<SceneProvider>();
      sceneProvider.addMagicObject(
        categoryId: widget.category.id,
        objectId: widget.object.id,
        name: widget.object.name,
        svgPath: widget.object.svgPath,
        colors: coloredRegions,
      );
    }
    
    // Navigate back after delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }
}