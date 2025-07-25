import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'home_screen.dart';
import '../scene_mode/screens/scene_home_screen.dart';
import '../providers/settings_provider.dart';
import '../widgets/settings_dialog.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const SceneHomeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
          // Settings button overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: BounceInDown(
              delay: const Duration(milliseconds: 500),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.settings, color: Colors.purple),
                  onPressed: () => _showSettingsDialog(context),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
              context.read<SettingsProvider>().playSound('tap.mp3');
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Colors.grey,
            selectedFontSize: 14,
            unselectedFontSize: 12,
            items: [
              BottomNavigationBarItem(
                icon: Pulse(
                  infinite: _selectedIndex == 0,
                  duration: const Duration(seconds: 2),
                  child: const Icon(Icons.grid_on_rounded, size: 28),
                ),
                label: 'Pixels',
              ),
              BottomNavigationBarItem(
                icon: Pulse(
                  infinite: _selectedIndex == 1,
                  duration: const Duration(seconds: 2),
                  child: const Icon(Icons.landscape_rounded, size: 28),
                ),
                label: 'Scenes',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SettingsDialog(),
    );
  }
}