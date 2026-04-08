import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants.dart';
import '../../core/localization.dart';

class GameOverDialog extends ConsumerWidget {
  final int score;
  final int level;
  final int maxCombo;
  final int perfectCount;
  final bool isHighScore;
  final VoidCallback onRestart;
  final VoidCallback onMenu;

  const GameOverDialog({
    super.key,
    required this.score,
    required this.level,
    required this.maxCombo,
    required this.perfectCount,
    this.isHighScore = false,
    required this.onRestart,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.watch(locProvider);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E293B),
              Color(0xFF0F172A),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusXL),
          border: Border.all(
            color: isHighScore ? AppColors.warning.withAlpha(180) : AppColors.error.withAlpha(128),
            width: isHighScore ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (isHighScore ? AppColors.warning : AppColors.error).withAlpha(51),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isHighScore) _buildHighScoreBadge(loc),
            _buildHeader(loc),
            const SizedBox(height: AppDimensions.paddingL),
            _buildStats(loc),
            const SizedBox(height: AppDimensions.paddingXL),
            _buildButtons(loc),
          ],
        ),
      ),
    ).animate().scale(duration: 300.ms, curve: Curves.easeOut);
  }

  Widget _buildHighScoreBadge(Loc loc) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.paddingS,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withAlpha(100),
            blurRadius: 15,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events, color: Colors.white, size: 20),
          const SizedBox(width: 6),
          Text(
            loc.newHighScore,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    )
        .animate()
        .scale(delay: 200.ms, duration: 400.ms, curve: Curves.elasticOut)
        .shimmer(delay: 600.ms, duration: 1000.ms);
  }

  Widget _buildHeader(Loc loc) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: (isHighScore ? AppColors.warning : AppColors.error).withAlpha(51),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isHighScore ? Icons.star : Icons.sentiment_dissatisfied,
            size: 48,
            color: isHighScore ? AppColors.warning : AppColors.error,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingM),
        Text(
          loc.gameOver,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isHighScore ? AppColors.warning : AppColors.error,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingS),
        Text(
          '$score',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          '${loc.level} $level',
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStats(Loc loc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(Icons.flash_on, '$maxCombo', loc.maxCombo),
        _buildStatItem(Icons.star, '$perfectCount', loc.perfectCount),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.warning, size: 24),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(Loc loc) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onRestart,
            icon: const Icon(Icons.replay),
            label: Text(loc.restart),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingS),
        TextButton.icon(
          onPressed: onMenu,
          icon: const Icon(Icons.home),
          label: Text(loc.menu),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
