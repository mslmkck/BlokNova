import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants.dart';
import '../../core/localization.dart';
import '../../providers/game_provider.dart';

class PrivacyPolicyDialog extends ConsumerStatefulWidget {
  const PrivacyPolicyDialog({super.key});

  @override
  ConsumerState<PrivacyPolicyDialog> createState() => _PrivacyPolicyDialogState();
}

class _PrivacyPolicyDialogState extends ConsumerState<PrivacyPolicyDialog> {
  bool _hasAccepted = false;

  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(locProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340, maxHeight: 500),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withAlpha(50), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.shield_outlined, color: AppColors.primary, size: 28),
                const SizedBox(width: 10),
                Text(
                  loc.privacyPolicy,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(loc.dataCollection),
                    const SizedBox(height: 8),
                    _buildText(loc.privacyText1),
                    const SizedBox(height: 12),
                    _buildSectionTitle(loc.dataUsage),
                    const SizedBox(height: 8),
                    _buildText(loc.privacyText2),
                    const SizedBox(height: 12),
                    _buildSectionTitle(loc.dataStorage),
                    const SizedBox(height: 8),
                    _buildText(loc.privacyText3),
                    const SizedBox(height: 12),
                    _buildSectionTitle(loc.yourRights),
                    const SizedBox(height: 8),
                    _buildText(loc.privacyText4),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 8),
                    _buildContactSection(loc),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _hasAccepted,
                  onChanged: (value) {
                    setState(() {
                      _hasAccepted = value ?? false;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _hasAccepted = !_hasAccepted;
                      });
                    },
                    child: Text(
                      loc.iAccept,
                      style: TextStyle(
                        fontSize: 11,
                        color: _hasAccepted ? AppColors.textPrimary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(loc.decline),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    },
                    child: Text(
                      loc.decline,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _hasAccepted
                        ? () async {
                            await ref.read(settingsProvider.notifier).setPrivacyAccepted(true);
                            await ref.read(playerStatsProvider.notifier).acceptPrivacy();
                            if (context.mounted) {
                              Navigator.of(context).pop(true);
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(loc.accept),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.secondary,
      ),
    );
  }

  Widget _buildText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.textSecondary,
        height: 1.4,
      ),
    );
  }

  Widget _buildContactSection(Loc loc) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background.withAlpha(100),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.contactUs,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () => _launchUrl('mailto:contact@blocktower.game'),
            child: const Text(
              'contact@blocktower.game',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
