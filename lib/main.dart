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
            title: 'Colorful Adventures',
            theme: ThemeData(
              primarySwatch: Colors.purple,
              useMaterial3: true,
              textTheme: GoogleFonts.baloo2TextTheme(
                Theme.of(context).textTheme,
              ),
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.purple,
                brightness: Brightness.light,
              ).copyWith(
                primary: const Color(0xFF8B5CF6),
                secondary: const Color(0xFFF59E0B),
                surface: const Color(0xFFF3F4F6),
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