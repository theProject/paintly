import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../services/image_processor.dart';
import '../providers/settings_provider.dart';
import 'coloring_screen.dart';

class ImportImageScreen extends StatefulWidget {
  const ImportImageScreen({super.key});

  @override
  State<ImportImageScreen> createState() => _ImportImageScreenState();
}

class _ImportImageScreenState extends State<ImportImageScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isProcessing = false;
  String _imageName = 'My Pixel Art';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: FadeIn(
          child: Text(
            'Create from Photo',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions card
            FadeInDown(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'How it works',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '1. Choose a photo from your gallery\n'
                      '2. We\'ll turn it into pixel art magic! ✨\n'
                      '3. Color your creation and have fun!',
                      style: TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Image selection area
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: GestureDetector(
                onTap: _showImagePicker,
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _buildImageArea(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Name input
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Name your masterpiece',
                    hintText: 'My Amazing Creation',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(
                      Icons.edit_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _imageName = value.isEmpty ? 'My Pixel Art' : value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showImagePicker,
                      icon: const Icon(Icons.photo_library_rounded),
                      label: const Text('Gallery'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: const Text('Camera'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Process button
            if (_selectedImage != null)
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.auto_awesome, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'Create Pixel Art',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageArea() {
    if (_isProcessing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spin(
              infinite: true,
              child: Icon(
                Icons.auto_awesome,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Creating magic...',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.contain,
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_rounded,
            size: 72,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Tap to select a photo',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePicker() {
    context.read<SettingsProvider>().playSound('tap.mp3');
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ElasticIn(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.photo_library_rounded,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  title: const Text(
                    'Choose from Gallery',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: const Text(
                    'Take a Photo',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        if (mounted) {
          context.read<SettingsProvider>().playSound('tap.mp3');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Oops! Something went wrong: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
    });
    
    if (mounted) {
      context.read<SettingsProvider>().playSound('processing.mp3');
    }

    try {
      final pixelArt = await ImageProcessor.processImage(
        _selectedImage!,
        _imageName,
      );

      if (pixelArt != null) {
        // Navigate to coloring screen
        if (mounted) {
          context.read<SettingsProvider>().playSound('success.mp3');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ColoringScreen(pixelArt: pixelArt),
            ),
          );
        }
      } else {
        throw Exception('Failed to process image');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not create pixel art: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
}