import 'dart:ui'; // for ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'home_screen.dart';
import 'import_image_screen.dart';
import 'magic_mode_screen.dart';
import '../scene_mode/screens/scene_home_screen.dart';
import '../providers/settings_provider.dart';
import '../widgets/settings_dialog.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  int _selectedTopTab = 0; // For top navigation tabs
  late AnimationController _animationController;
  late AnimationController _bounceController;
  late AnimationController _liquidController; // For liquid glass effect

  List<Widget> get _screens => [
        HomeScreen(
          selectedTab: _selectedTopTab,
          onTabChanged: () => setState(() {}),
        ),
        const MagicModeScreen(),
        const SceneHomeScreen(),
      ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..forward();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _liquidController = AnimationController(
      duration: const Duration(seconds: 10), // Slow liquid motion
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bounceController.dispose();
    _liquidController.dispose();
    super.dispose();
  }

  void _handleAddPixel() {
    // Navigate to ImportImageScreen
    HapticFeedback.lightImpact();
    context.read<SettingsProvider>().playSound('audio/bubbletap.wav');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ImportImageScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // LAYER 1: Valley background SVG - Full screen wallpaper
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/svg/valley.svg',
              width: screenW,
              height: screenH,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          // LAYER 2: Main content
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Top glass bar with navigation buttons and logo
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: AnimatedBuilder(
                      animation: _liquidController,
                      builder: (context, child) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: LinearGradient(
                                  begin: Alignment(
                                    -1 + 2 * _liquidController.value,
                                    -1 + 2 * _liquidController.value,
                                  ),
                                  end: Alignment(
                                    1 - 2 * _liquidController.value,
                                    1 - 2 * _liquidController.value,
                                  ),
                                  colors: [
                                    Colors.white.withValues(alpha: 0.05),
                                    Colors.blue.withValues(alpha: 0.03),
                                    Colors.purple.withValues(alpha: 0.02),
                                    Colors.pink.withValues(alpha: 0.03),
                                    Colors.white.withValues(alpha: 0.05),
                                  ],
                                  stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                                ),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  width: 0.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Navigation buttons (from HomeScreen)
                                  _buildTopNavButton(Icons.grid_on_rounded, _selectedTopTab == 0, () {
                                    setState(() => _selectedTopTab = 0);
                                  }),
                                  const SizedBox(width: 8),
                                  _buildTopNavButton(Icons.pets_rounded, _selectedTopTab == 1, () {
                                    setState(() => _selectedTopTab = 1);
                                  }),
                                  const SizedBox(width: 8),
                                  _buildTopNavButton(Icons.local_florist_rounded, _selectedTopTab == 2, () {
                                    setState(() => _selectedTopTab = 2);
                                  }),
                                  const SizedBox(width: 8),
                                  _buildTopNavButton(Icons.category_rounded, _selectedTopTab == 3, () {
                                    setState(() => _selectedTopTab = 3);
                                  }),
                                  const SizedBox(width: 8),
                                  _buildTopNavButton(Icons.star_rounded, _selectedTopTab == 4, () {
                                    setState(() => _selectedTopTab = 4);
                                  }),
                                  
                                  const Spacer(),
                                  
                                  // Settings button
                                  AnimatedBuilder(
                                    animation: _bounceController,
                                    builder: (context, child) => Transform.scale(
                                      scale: 1.0 + (_bounceController.value * 0.05),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.9),
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: colorScheme.primary.withValues(alpha: 0.2),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(20),
                                            onTap: () {
                                              HapticFeedback.lightImpact();
                                              _showSettingsDialog(context);
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Icon(Icons.settings_rounded, size: 20),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  
                                  // Logo with palette on the right
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.palette_rounded,
                                        color: colorScheme.primary,
                                        size: 28,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'TasaiYsume',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Main content area - NO background, cards will have their own glass
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.1, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                            child: child,
                          ),
                        ),
                        child: IndexedStack(
                          key: ValueKey<int>(_selectedIndex),
                          index: _selectedIndex,
                          children: _screens,
                        ),
                      ),
                    ),
                  ),
                  
                  // Space for bottom nav
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // LAYER 3: Foreground SVG anchored to bottom (2.5D effect)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: SvgPicture.asset(
                'assets/svg/TasaiYumeForeground.svg',
                width: screenW,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
        ],
      ),

      // LAYER 4: Ultra-transparent glass bottom nav bar with add button
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: AnimatedBuilder(
            animation: _liquidController,
            builder: (context, child) {
              return BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  height: 65,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    gradient: LinearGradient(
                      begin: Alignment(
                        -1 + 2 * (_liquidController.value * 0.5),
                        -0.5,
                      ),
                      end: Alignment(
                        1 - 2 * (_liquidController.value * 0.5),
                        0.5,
                      ),
                      colors: [
                        Colors.white.withValues(alpha: 0.05),
                        Colors.cyan.withValues(alpha: 0.02),
                        Colors.blue.withValues(alpha: 0.03),
                        Colors.purple.withValues(alpha: 0.02),
                        Colors.white.withValues(alpha: 0.05),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 0.5,
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(
                          index: 0,
                          icon: Icons.grid_on_rounded,
                          label: 'Pixels',
                          color: colorScheme.primary,
                        ),
                        _buildNavItem(
                          index: 1,
                          icon: Icons.auto_fix_high_rounded,
                          label: 'Magic',
                          color: colorScheme.secondary,
                        ),
                        // Add button (was floating action button)
                        _buildAddButton(colorScheme),
                        _buildNavItem(
                          index: 2,
                          icon: Icons.landscape_rounded,
                          label: 'Scene',
                          color: colorScheme.tertiary,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopNavButton(IconData icon, bool isSelected, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          HapticFeedback.lightImpact();
          context.read<SettingsProvider>().playSound('audio/bubbletap.wav');
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.3)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: isSelected ? colorScheme.primary : Colors.grey[600],
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(ColorScheme colorScheme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _handleAddPixel,
        child: Container(
          width: 56,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary,
                colorScheme.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isSelected = _selectedIndex == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _selectedIndex = index);
          context.read<SettingsProvider>().playSound('audio/bubbletap.wav');
        },
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: isSelected ? 1 : 0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale: 1.0 + (value * 0.15),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.9)
                            : Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(9 + (value * 2)),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : [],
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected
                            ? Colors.white
                            : color.withValues(alpha: 0.8),
                        size: 8 + (value * 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: 10 + value,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? color : Colors.grey[600],
                    ),
                    child: Text(label),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Settings',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SettingsDialog();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
          child: child,
        );
      },
    );
  }
}