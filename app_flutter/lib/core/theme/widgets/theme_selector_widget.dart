import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_themes.dart';
import '../theme_controller.dart';

class ThemeSelectorWidget extends StatelessWidget {
  const ThemeSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Theme Mode', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode, size: 18), label: Text('Light')),
            ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode, size: 18), label: Text('Dark')),
            ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.settings_brightness, size: 18), label: Text('System')),
          ],
          selected: {themeController.themeMode},
          onSelectionChanged: (Set<ThemeMode> newSelection) {
            themeController.updateThemeMode(newSelection.first);
          },
        ),
        const SizedBox(height: 8),
        Text('Color Scheme', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(AppThemes.customSchemes.length, (index) {
            final scheme = AppThemes.customSchemes[index];
            final isSelected = index == themeController.currentThemeIndex;
            return InkWell(
              onTap: () => themeController.updateThemeScheme(index),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3), blurRadius: 8)]
                      : null,
                ),
                child: ClipOval(
                  child: Container(
                    color: scheme.light.primary,
                    alignment: Alignment.center,
                    child: Text(
                      scheme.name[0].toUpperCase(),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
