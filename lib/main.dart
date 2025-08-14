// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/main_navigation_screen.dart';
import 'providers/coloring_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/scene_provider.dart';
import 'providers/svg_coloring_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ColoringProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => SceneProvider()),
        ChangeNotifierProvider(create: (_) => SvgColoringProvider()), // Added SVG provider
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'TasaiYume: Winters Magical Dream',
            theme: ThemeData(
              primarySwatch: Colors.pink,
              useMaterial3: true,
              textTheme: GoogleFonts.baloo2TextTheme(
                Theme.of(context).textTheme,
              ),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFFFABF23),
                brightness: Brightness.light,
              ).copyWith(
                primary: const Color(0xFFE93A45),
                secondary: const Color(0xFFFABF23),
                tertiary: const Color(0xFF51BAA3),
                surface: const Color(0xFFFFF8F0),
                onPrimary: Colors.white,
                onSecondary: Colors.black,
                primaryContainer: const Color(0xFFFF8A3D),
                secondaryContainer: const Color(0xFF9B72AA),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  elevation: 0,
                ),
              ),
              cardTheme: CardThemeData(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            home: const MainNavigationScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}