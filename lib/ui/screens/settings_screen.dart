import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/localization.dart';
import '../../providers/game_provider.dart';
import '../widgets/privacy_policy_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final loc = ref.watch(locProvider);
    final currentLang = ref.watch(localizationNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settings),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.background, Color(0xFF1a1a2e)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            children: [
              _buildLanguageSelector(context, ref, loc, currentLang),
              const SizedBox(height: AppDimensions.paddingM),
              _buildSettingCard(
                title: loc.sound,
                subtitle: loc.soundSubtitle,
                icon: Icons.volume_up,
                value: settings['soundEnabled'] ?? true,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setSoundEnabled(value);
                  ref.read(audioServiceProvider).setSoundEnabled(value);
                },
              ),
              const SizedBox(height: AppDimensions.paddingM),
              _buildSettingCard(
                title: loc.vibration,
                subtitle: loc.vibrationSubtitle,
                icon: Icons.vibration,
                value: settings['vibrationEnabled'] ?? true,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setVibrationEnabled(value);
                  ref.read(hapticServiceProvider).setEnabled(value);
                },
              ),
              const SizedBox(height: AppDimensions.paddingM),
              _buildSettingCard(
                title: loc.music,
                subtitle: loc.musicSubtitle,
                icon: Icons.music_note,
                value: settings['musicEnabled'] ?? true,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setMusicEnabled(value);
                  ref.read(audioServiceProvider).setMusicEnabled(value);
                },
              ),
              const SizedBox(height: AppDimensions.paddingM),
              _buildSettingCard(
                title: loc.weatherEffects,
                subtitle: loc.weatherEffectsSubtitle,
                icon: Icons.ac_unit,
                value: settings['weatherEffectsEnabled'] ?? true,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setWeatherEffectsEnabled(value);
                },
              ),
              const SizedBox(height: AppDimensions.paddingXL),
              _buildAboutSection(loc),
              const SizedBox(height: AppDimensions.paddingM),
              _buildPrivacyButton(context, loc),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context, WidgetRef ref, Loc loc, AppLang currentLang) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusL),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(26),
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
            ),
            child: const Icon(Icons.language, color: AppColors.primary),
          ),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Text(
              loc.language,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DropdownButton<AppLang>(
            value: currentLang,
            dropdownColor: AppColors.surfaceLight,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: AppLang.tr, child: Text('Türkçe')),
              DropdownMenuItem(value: AppLang.en, child: Text('English')),
              DropdownMenuItem(value: AppLang.de, child: Text('Deutsch')),
              DropdownMenuItem(value: AppLang.ru, child: Text('Русский')),
            ],
            onChanged: (AppLang? newLang) {
              if (newLang != null) {
                ref.read(localizationNotifierProvider.notifier).setLanguage(newLang);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusL),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(26),
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: AppDimensions.paddingM),
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
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(Loc loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.about,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingM),
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusL),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                      ),
                      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
                    ),
                    child: const Icon(
                      Icons.view_in_ar,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.appName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          loc.version,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingM),
              Text(
                loc.aboutDesc,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyButton(BuildContext context, Loc loc) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusL),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: ListTile(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => const PrivacyPolicyDialog(),
          );
        },
        leading: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(26),
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
          ),
          child: const Icon(Icons.shield_outlined, color: AppColors.primary),
        ),
        title: Text(
          loc.privacyPolicy,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
      ),
    );
  }
}
