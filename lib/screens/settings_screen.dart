import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nexus_link/core/constants/app_colors.dart';
import 'package:nexus_link/core/constants/app_dimensions.dart';
import 'package:nexus_link/managers/settings_manager.dart';
import 'package:nexus_link/widgets/common/glass_panel.dart';
import 'package:nexus_link/widgets/common/gradient_background.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsManager>();

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingL),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_ios_new),
                    ),
                    Expanded(
                      child: Text(
                        'SETTINGS',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingL),
                Expanded(
                  child: ListView(
                    children: [
                      _toggleRow(
                        'Audio',
                        settings.audioEnabled,
                        (value) => settings.setAudioEnabled(value),
                      ),
                      _toggleRow(
                        'Music',
                        settings.musicEnabled,
                        (value) => settings.setMusicEnabled(value),
                      ),
                      _volumeRow(
                        'Music volume',
                        settings.musicVolume,
                        (value) => settings.setMusicVolume(value),
                      ),
                      _toggleRow(
                        'Sound FX',
                        settings.sfxEnabled,
                        (value) => settings.setSfxEnabled(value),
                      ),
                      _volumeRow(
                        'SFX volume',
                        settings.sfxVolume,
                        (value) => settings.setSfxVolume(value),
                      ),
                      _toggleRow(
                        'Voice',
                        settings.voiceEnabled,
                        (value) => settings.setVoiceEnabled(value),
                      ),
                      _volumeRow(
                        'Voice volume',
                        settings.voiceVolume,
                        (value) => settings.setVoiceVolume(value),
                      ),
                      _toggleRow(
                        'Haptics',
                        settings.hapticsEnabled,
                        (value) => settings.setHapticsEnabled(value),
                      ),
                      _qualityRow(settings),
                      const SizedBox(height: AppDimensions.spacingM),
                      _linkRow('Privacy', Icons.privacy_tip_outlined),
                      _linkRow('Help', Icons.help_outline),
                      _linkRow('About', Icons.info_outline),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _toggleRow(
    String title,
    bool value,
    Future<void> Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: GlassPanel(
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: (newValue) => onChanged(newValue),
              activeThumbColor: AppColors.primaryCyan,
            ),
          ],
        ),
      ),
    );
  }

  Widget _volumeRow(
    String title,
    double value,
    Future<void> Function(double) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: GlassPanel(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingM,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Slider(
                value: value,
                min: 0,
                max: 1,
                onChanged: (newValue) => onChanged(newValue),
                activeColor: AppColors.primaryCyan,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _qualityRow(SettingsManager settings) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: GlassPanel(
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Graphics',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            DropdownButton<GraphicsQuality>(
              value: settings.graphicsQuality,
              underline: const SizedBox(),
              items: GraphicsQuality.values
                  .map(
                    (quality) => DropdownMenuItem(
                      value: quality,
                      child: Text(quality.name.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  settings.setGraphicsQuality(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _linkRow(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: GlassPanel(
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryCyan),
            const SizedBox(width: AppDimensions.spacingM),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
