import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants.dart';
import '../../core/localization.dart';
import '../../providers/game_provider.dart';
import '../../data/models/player_stats.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(playerStatsProvider);
    final loc = ref.watch(locProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.stats),
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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                   children: [
                    _buildHighScoreCard(stats.highScore, loc),
                    const SizedBox(height: AppDimensions.paddingL),
                    _buildStatsGrid(stats, loc),
                    const SizedBox(height: AppDimensions.paddingL),
                    _buildRecentScores(stats.recentScores, loc),
                    const SizedBox(height: AppDimensions.paddingL),
                    _buildResetButton(context, ref, loc),
                  ],
                 ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHighScoreCard(int highScore, Loc loc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingXL),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(102),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.emoji_events,
            size: 48,
            color: AppColors.warning,
          ),
          const SizedBox(height: AppDimensions.paddingS),
          Text(
            loc.best,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          Text(
            '$highScore',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _buildStatsGrid(PlayerStats stats, Loc loc) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppDimensions.paddingM,
      crossAxisSpacing: AppDimensions.paddingM,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          icon: Icons.sports_esports,
          label: loc.gamesPlayed,
          value: '${stats.gamesPlayed}',
          color: AppColors.secondary,
        ),
        _buildStatCard(
          icon: Icons.trending_up,
          label: loc.highestLevel,
          value: '${stats.highestLevel}',
          color: AppColors.success,
        ),
        _buildStatCard(
          icon: Icons.star,
          label: loc.totalScore,
          value: '${stats.totalScore}',
          color: AppColors.warning,
        ),
        _buildStatCard(
          icon: Icons.check_circle,
          label: loc.perfectCount,
          value: '${stats.perfectPlacements}',
          color: AppColors.accent,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusL),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AppDimensions.paddingXS),
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2);
  }

  Widget _buildRecentScores(List<int> recentScores, Loc loc) {
    if (recentScores.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Son Skorlar',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingM),
        Wrap(
          spacing: AppDimensions.paddingS,
          runSpacing: AppDimensions.paddingS,
          children: recentScores
              .asMap()
              .entries
              .map((entry) => _buildScoreChip(entry.key + 1, entry.value))
              .toList(),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildScoreChip(int index, int score) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$index.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingXS),
          Text(
            '$score',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton(BuildContext context, WidgetRef ref, Loc loc) {
    return TextButton.icon(
      onPressed: () => _showResetDialog(context, ref, loc),
      icon: const Icon(Icons.delete_outline, color: AppColors.error),
      label: Text(
        loc.resetStats,
        style: const TextStyle(color: AppColors.error),
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref, Loc loc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('${loc.resetStats}?'),
        content: const Text('...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              ref.read(playerStatsProvider.notifier).reset();
              Navigator.pop(context);
            },
            child: const Text(
              'Sıfırla',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
