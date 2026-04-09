import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants.dart';
import '../../core/localization.dart';
import '../../providers/game_provider.dart';
import '../../data/models/player_stats.dart';
import 'game_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';
import '../widgets/quest_dialog.dart';

enum GameMode { classic, timeRush }

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(playerStatsProvider);
    final loc = ref.watch(locProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              Color(0xFF1a1a2e),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingL,
                    vertical: AppDimensions.paddingM,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: AppDimensions.paddingL),
                      _buildTitle(context, loc),
                      const SizedBox(height: AppDimensions.paddingM),
                      _buildHighScore(stats.highScore),
                      const SizedBox(height: AppDimensions.paddingS),
                      _buildMenuButtons(context, ref, loc, stats),
                      const SizedBox(height: AppDimensions.paddingS),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, Loc loc) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.accent],
            ),
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusXL),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(128),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.view_in_ar,
            size: 35,
            color: Colors.white,
          ),
        )
            .animate()
            .scale(duration: 600.ms, curve: Curves.elasticOut)
            .shimmer(delay: 600.ms, duration: 1200.ms),
        const SizedBox(height: AppDimensions.paddingM),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.primary, AppColors.accent],
          ).createShader(bounds),
          child: Text(
            loc.appName,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 500.ms)
            .slideY(begin: -0.3, curve: Curves.easeOut),
        const SizedBox(height: 4),
        Text(
          'INFINITY STACK',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 14,
            color: AppColors.textSecondary,
            letterSpacing: 3,
          ),
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }

  Widget _buildHighScore(int highScore) {
    if (highScore == 0) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.paddingM,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(179),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusL),
        border: Border.all(
          color: AppColors.primary.withAlpha(77),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.emoji_events,
            color: AppColors.warning,
            size: AppDimensions.iconSizeM,
          ),
          const SizedBox(width: AppDimensions.paddingS),
          Text(
            '$highScore',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.warning,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).scale();
  }

  Widget _buildMenuButtons(BuildContext context, WidgetRef ref, Loc loc, PlayerStats stats) {
    return Column(
      children: [
        // Mode selection: Classic & Time Rush
        Row(
          children: [
            Expanded(
              child: _buildModeButton(
                context, ref,
                icon: Icons.terrain,
                label: loc.classicMode,
                color: AppColors.primary,
                onPressed: () => _onPlayPressed(context, ref, GameMode.classic),
                delay: 600,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            Expanded(
              child: _buildModeButton(
                context, ref,
                icon: Icons.timer,
                label: loc.timeRush,
                color: AppColors.error,
                onPressed: () => _onPlayPressed(context, ref, GameMode.timeRush),
                delay: 700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingS),
        Row(
          children: [
            Expanded(
              child: _buildQuestButton(context, ref, loc, stats),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            Expanded(
              child: _buildIconButton(
                context,
                icon: Icons.storefront,
                label: loc.shop,
                onPressed: () => _onShopPressed(context, ref),
                delay: 750,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingS),
        Row(
          children: [
            Expanded(
              child: _buildIconButton(
                context,
                icon: Icons.bar_chart,
                label: loc.stats,
                onPressed: () => _onStatsPressed(context, ref),
                delay: 800,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            Expanded(
              child: _buildIconButton(
                context,
                icon: Icons.settings,
                label: loc.settings,
                onPressed: () => _onSettingsPressed(context, ref),
                delay: 850,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestButton(BuildContext context, WidgetRef ref, Loc loc, PlayerStats stats) {
    final bool hasUnclaimed = stats.dailyQuests.any((q) => q.isCompleted && !q.isClaimed);
    
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusL),
      child: InkWell(
        onTap: () => _onQuestsPressed(context, ref),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusL),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingS),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Column(
                children: [
                  const Icon(Icons.assignment, size: 24, color: AppColors.primary),
                  Text(loc.quests), 
                ],
              ),
              if (hasUnclaimed)
                Positioned(
                  top: -2,
                  right: 12,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ).animate(onPlay: (c) => c.repeat())
                   .scale(duration: 800.ms, begin: Offset(1, 1), end: Offset(1.3, 1.3))
                   .shimmer(),
                ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 720.ms).slideX(begin: -0.2);
  }

  Widget _buildModeButton(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required int delay,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusXL),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withAlpha(60), color.withAlpha(25)],
            ),
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusXL),
            border: Border.all(color: color.withAlpha(100), width: 1.5),
          ),
          child: Column(
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(height: AppDimensions.paddingXS),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideY(begin: 0.2);
  }

  Widget _buildIconButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required int delay,
  }) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusL),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusL),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Icon(icon, size: 24),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: 0.2);
  }

  void _onPlayPressed(BuildContext context, WidgetRef ref, GameMode mode) {
    ref.read(audioServiceProvider).playClick();
    ref.read(hapticServiceProvider).light();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameScreen(gameMode: mode)),
    );
  }

  void _onShopPressed(BuildContext context, WidgetRef ref) {
    ref.read(audioServiceProvider).playClick();
    ref.read(hapticServiceProvider).light();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ShopScreen()),
    );
  }

  void _onStatsPressed(BuildContext context, WidgetRef ref) {
    ref.read(audioServiceProvider).playClick();
    ref.read(hapticServiceProvider).light();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StatsScreen()),
    );
  }

  void _onSettingsPressed(BuildContext context, WidgetRef ref) {
    ref.read(audioServiceProvider).playClick();
    ref.read(hapticServiceProvider).light();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  void _onQuestsPressed(BuildContext context, WidgetRef ref) {
    ref.read(audioServiceProvider).playClick();
    ref.read(hapticServiceProvider).light();
    showDialog(
      context: context,
      builder: (_) => const QuestDialog(),
    );
  }
}
