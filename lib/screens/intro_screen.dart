import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_navigation_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<IntroPage> _pages = [
    IntroPage(
      title: 'Welcome to Colorful Adventures!',
      description: 'A magical world of pixel art and creative coloring awaits you',
      icon: Icons.palette_rounded,
      color: Color(0xFFE93A45), // Red
    ),
    IntroPage(
      title: 'Pixel Perfect Fun',
      description: 'Choose from dozens of pixel art designs and bring them to life with vibrant colors',
      icon: Icons.grid_on_rounded,
      color: Color(0xFFFABF23), // Yellow
    ),
    IntroPage(
      title: 'Scene Coloring',
      description: 'Create beautiful scenes with our vector-based coloring mode',
      icon: Icons.landscape_rounded,
      color: Color(0xFF51BAA3), // Teal
    ),
    IntroPage(
      title: 'Import Your Photos',
      description: 'Turn your favorite photos into pixel art masterpieces',
      icon: Icons.add_photo_alternate_rounded,
      color: Color(0xFF9B72AA), // Purple
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeIntro() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('intro_completed', true);
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainNavigationScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _pages[_currentPage].color.withValues(alpha: 0.3),
                  _pages[_currentPage].color.withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
          
          // Page content
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeInDown(
                      delay: const Duration(milliseconds: 200),
                      child: ElasticIn(
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: _pages[index].color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _pages[index].color.withValues(alpha: 0.5),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Icon(
                            _pages[index].icon,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: Text(
                        _pages[index].title,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _pages[index].color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeInUp(
                      delay: const Duration(milliseconds: 600),
                      child: Text(
                        _pages[index].description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Navigation controls
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Page indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 30 : 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? _pages[_currentPage].color
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Action buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Skip button
                      if (_currentPage < _pages.length - 1)
                        TextButton(
                          onPressed: _completeIntro,
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 80),
                      
                      // Next/Get Started button
                      BounceInRight(
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            if (_currentPage < _pages.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              _completeIntro();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _pages[_currentPage].color,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 8,
                            shadowColor: _pages[_currentPage].color.withValues(alpha: 0.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentPage < _pages.length - 1
                                    ? 'Next'
                                    : 'Get Started',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _currentPage < _pages.length - 1
                                    ? Icons.arrow_forward_rounded
                                    : Icons.check_rounded,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class IntroPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  IntroPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
