import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/settings_provider.dart';
import 'providers/scene_provider.dart';
import 'screens/intro_screen.dart';
import 'screens/main_navigation_screen.dart';

void main() {
  runApp(const PaintedApp());
}

class PaintedApp extends StatelessWidget {
  const PaintedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => SceneProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Painted',
            debugShowCheckedModeBanner: false,
            theme: _buildTheme(),
            home: settings.hasSeenIntro ? const MainNavigationScreen() : const IntroScreen(),
          );
        },
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFF6B6B),
        primary: const Color(0xFFFF6B6B),
        secondary: const Color(0xFF4ECDC4),
        tertiary: const Color(0xFF45B7D1),
        surface: const Color(0xFFF5F5F5),
      ),
      textTheme: GoogleFonts.quicksandTextTheme().copyWith(
        headlineLarge: const TextStyle(fontWeight: FontWeight.bold),
        headlineMedium: const TextStyle(fontWeight: FontWeight.bold),
        headlineSmall: const TextStyle(fontWeight: FontWeight.bold),
        titleLarge: const TextStyle(fontWeight: FontWeight.w600),
        titleMedium: const TextStyle(fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 4,
      ),
    );
  }
}