import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/settings_provider.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return ElasticIn(
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '⚙️ Settings',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Consumer<SettingsProvider>(
                builder: (context, settings, child) {
                  return Column(
                    children: [
                      _buildSettingTile(
                        context,
                        icon: Icons.music_note,
                        title: 'Background Music',
                        value: settings.musicEnabled,
                        onChanged: (_) => settings.toggleMusic(),
                        color: Colors.pink,
                      ),
                      const SizedBox(height: 12),
                      _buildSettingTile(
                        context,
                        icon: Icons.volume_up,
                        title: 'Sound Effects',
                        value: settings.soundEnabled,
                        onChanged: (_) => settings.toggleSound(),
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      _buildSettingTile(
                        context,
                        icon: Icons.brush,
                        title: 'Drag to Paint',
                        subtitle: 'Swipe to color multiple pixels',
                        value: settings.dragToPaintEnabled,
                        onChanged: (_) => settings.toggleDragToPaint(),
                        color: Colors.blue,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(120, 44),
                ),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: color,
          ),
        ],
      ),
    );
  }
}