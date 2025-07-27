import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/main_navigation_screen.dart';
import 'providers/coloring_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/scene_provider.dart';

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
                seedColor: const Color(0xFFFABF23), // Yellow from new palette
                brightness: Brightness.light,
              ).copyWith(
                primary: const Color(0xFFE93A45), // Red
                secondary: const Color(0xFFFABF23), // Yellow
                tertiary: const Color(0xFF51BAA3), // Teal
                surface: const Color(0xFFFFF8F0), // Light cream surface
                onPrimary: Colors.white,
                onSecondary: Colors.black,
                primaryContainer: const Color(0xFFFF8A3D), // Orange
                secondaryContainer: const Color(0xFF9B72AA), // Purple
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