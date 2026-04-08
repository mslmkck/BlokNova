import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants.dart';
import '../../providers/game_provider.dart';
import '../../data/models/player_stats.dart';

class QuestDialog extends ConsumerWidget {
  const QuestDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(playerStatsProvider);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary.withAlpha(50), width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(30),
              blurRadius: 40,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            const Divider(color: Colors.white10, height: 1),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: stats.dailyQuests.isEmpty
                    ? const Center(child: Text('Daha fazla görev için yarın gel!', style: TextStyle(color: Colors.white38)))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: stats.dailyQuests.length,
                        itemBuilder: (context, index) {
                          return _buildQuestItem(context, ref, stats.dailyQuests[index]);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GÜNLÜK GÖREVLER',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Her gün 00:00\'da yenilenir',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white38),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestItem(BuildContext context, WidgetRef ref, Quest quest) {
    final progress = (quest.progress / quest.goal).clamp(0.0, 1.0);
    final isDone = quest.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone ? AppColors.success.withAlpha(50) : Colors.white10,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  quest.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDone ? AppColors.success : AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (quest.isClaimed)
                const Icon(Icons.check_circle, color: AppColors.success, size: 20)
              else
                Row(
                  children: [
                    const Icon(Icons.monetization_on, color: AppColors.warning, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${quest.rewardCoins}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.warning),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDone ? AppColors.success : AppColors.primary,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${quest.progress} / ${quest.goal}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              if (isDone && !quest.isClaimed)
                ElevatedButton(
                  onPressed: () async {
                    final success = await ref.read(playerStatsProvider.notifier).claimQuestReward(quest.id);
                    if (success) {
                      ref.read(audioServiceProvider).playPerfect(12); // Play a high note for success
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    minimumSize: const Size(0, 32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('AL', style: TextStyle(fontWeight: FontWeight.bold)),
                ).animate(onPlay: (controller) => controller.repeat())
                 .shimmer(duration: 1500.ms, color: Colors.white54)
              else if (quest.isClaimed)
                const Text('TAMAMLANDI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white38))
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}
