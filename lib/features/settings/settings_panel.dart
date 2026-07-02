import 'package:flutter/material.dart';
import 'package:pipeline_app/core/theme_controller.dart';
import 'package:pipeline_app/core/text_scaler.dart';

/// A modal bottom-sheet panel for theme mode, colour scheme, and text scale.
///
/// Binds to a [ThemeController] and [TextScaleController] via constructor
/// injection. Colour swatches cycle through the built-in [SchemeDef] palettes.
class SettingsPanel extends StatelessWidget {
  final ThemeController themeController;
  final TextScaleController textScaleController;

  const SettingsPanel({
    super.key,
    required this.themeController,
    required this.textScaleController,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeController, textScaleController]),
      builder: (context, _) {
        final cs = Theme.of(context).colorScheme;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Theme', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode, size: 18)),
                  ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode, size: 18)),
                  ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.settings_brightness, size: 18)),
                ],
                selected: {themeController.mode},
                onSelectionChanged: (selected) {
                  themeController.updateThemeMode(selected.first);
                },
              ),
              const SizedBox(height: 16),
              Text('Colour', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(ThemeController.schemes.length, (i) {
                  final scheme = ThemeController.schemes[i];
                  final isSelected = i == themeController.schemeIndex;
                  return GestureDetector(
                    onTap: () => themeController.updateScheme(i),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? cs.primary : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: Container(
                          color: scheme.primary,
                          alignment: Alignment.center,
                          child: isSelected
                              ? Icon(Icons.check, size: 16, color: cs.onPrimary)
                              : null,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              Text('Text Size', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.text_fields, size: 16, color: cs.onSurface.withAlpha(128)),
                  Expanded(
                    child: Slider(
                      value: textScaleController.scale,
                      min: 0.7,
                      max: 1.5,
                      divisions: 8,
                      label: '${(textScaleController.scale * 100).round()}%',
                      onChanged: (value) => textScaleController.setScale(value),
                    ),
                  ),
                  Icon(Icons.text_fields, size: 22, color: cs.onSurface),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
