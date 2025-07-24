import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../models/pixel_art.dart';
import 'coloring_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PixelArt> coloringPages = [];
  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
    loadColoringPages();
  }

  /// Load coloring pages from assets
  Future<void> loadColoringPages() async {
    try {
      // List of all available coloring pages
      final List<String> jsonFiles = [
        'assets/data/heart.json',
        'assets/data/cat.json',
        'assets/data/flower.json',
        'assets/data/house.json',
        'assets/data/star.json',
        'assets/data/butterfly.json',
        'assets/data/tree.json',
        'assets/data/rainbow.json',
        'assets/data/smiley.json',
      ];
      
      List<PixelArt> loadedPages = [];
      
      for (String jsonFile in jsonFiles) {
        try {
          final String jsonString = await rootBundle.loadString(jsonFile);
          final Map<String, dynamic> jsonData = json.decode(jsonString);
          final PixelArt pixelArt = PixelArt.fromJson(jsonData);
          loadedPages.add(pixelArt);
        } catch (e) {
          debugPrint('Error loading $jsonFile: $e');
        }
      }
      
      setState(() {
        coloringPages = loadedPages;
      });
    } catch (e) {
      debugPrint('Error loading coloring pages: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top navigation tabs
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildTab('New', 0),
                  const SizedBox(width: 16),
                  _buildTab('Texture', 1),
                  const SizedBox(width: 16),
                  _buildTab('Manga', 2),
                  const SizedBox(width: 16),
                  _buildTab('Animal', 3),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            // Grid of coloring pages
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 1,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: coloringPages.length,
                  itemBuilder: (context, index) {
                    return _buildColoringPageTile(coloringPages[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) {
                // Replace with your import photo screen or a placeholder
                return Scaffold(
                  appBar: AppBar(title: const Text('Import Photo')),
                  body: const Center(child: Text('Import Photo Screen')),
                );
              },
            ),
          );
        },
        icon: const Icon(Icons.add_photo_alternate),
        label: const Text('Import Photo'),
        backgroundColor: Colors.purple,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'My',
          ),
        ],
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }
  /// Build a tab widget
  Widget _buildTab(String label, int index) {
    final isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// Build a coloring page tile
  Widget _buildColoringPageTile(PixelArt pixelArt) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ColoringScreen(pixelArt: pixelArt),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Placeholder background
              Container(
                color: Colors.grey[200],
                child: const Icon(
                  Icons.image,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
              // Title overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
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
                    pixelArt.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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