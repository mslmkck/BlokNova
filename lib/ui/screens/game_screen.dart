import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame/game.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants.dart';
import '../../core/localization.dart';
import '../../game/tower_game.dart';
import '../../providers/game_provider.dart';
import '../widgets/combo_indicator.dart';
import '../widgets/game_over_dialog.dart';
import 'menu_screen.dart';

class GameScreen extends ConsumerStatefulWidget {
  final GameMode gameMode;
  const GameScreen({super.key, this.gameMode = GameMode.classic});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> with TickerProviderStateMixin {
  late TowerGame _game;
  OverlayEntry? _levelUpOverlay;
  int _displayScore = 0;
  int _displayLevel = 1;

  bool _initialized = false;
  int _lives = 3;

  // Time Rush fields
  double _timeLeft = 30.0;
  late final bool _isTimeRush;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _isTimeRush = widget.gameMode == GameMode.timeRush;
      _game = TowerGame(
        providerContainer: ProviderScope.containerOf(context),
        isTimeRush: _isTimeRush,
      );

      // Set up callbacks from game engine → UI
      _game.onScoreChanged = _onScoreChanged;
      _game.onGameOver = _onGameOver;
      _game.onPlacement = _onPlacement;
      _game.onTimeUpdate = _onTimeUpdate;
      _game.onLevelUp = _onLevelUp;
      _game.onLivesChanged = _onLivesChanged;

      _lives = _game.lives;
      _initialized = true;
    }
  }

  void _onScoreChanged() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _displayScore = _game.score;
        _displayLevel = _game.currentLevel;
      });
    });
  }

  void _onGameOver() {
    if (!mounted) return;
    _dismissLevelUpOverlay();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showGameOverDialog();
    });
  }

  void _onLevelUp(int level) {
    if (!mounted) return;
    _dismissLevelUpOverlay();
    _levelUpOverlay = OverlayEntry(
      builder: (ctx) => _LevelUpBanner(level: level, onDone: _dismissLevelUpOverlay),
    );
    Overlay.of(context).insert(_levelUpOverlay!);
  }

  void _dismissLevelUpOverlay() {
    _levelUpOverlay?.remove();
    _levelUpOverlay = null;
  }

  void _onPlacement() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _displayScore = _game.score;
        _displayLevel = _game.currentLevel;
      });
    });
  }

  void _onTimeUpdate(double time) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _timeLeft = time;
      });
    });
  }

  void _onLivesChanged(int lives) {
    if (!mounted) return;
    setState(() {
      _lives = lives;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(locProvider);
    return Scaffold(
      body: GestureDetector(
        onTap: _onTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // Game canvas
            GameWidget(game: _game),

            // UI overlay
            _buildUI(loc),
          ],
        ),
      ),
    );
  }

  Widget _buildUI(Loc loc) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM, vertical: AppDimensions.paddingS),
        child: Column(
          children: [
            _buildTopBar(loc),
            const SizedBox(height: 12),
            if (_isTimeRush && _game.status == GameStatus.playing)
              _buildTimerBar(),
            const SizedBox(height: 12),
            _buildLivesRow(),
            if (_game.combo > 1)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ComboIndicator(combo: _game.combo),
              ),
            const Spacer(),
            if (_game.status == GameStatus.playing) _buildPowerUpHub(),
            if (_game.status == GameStatus.waiting) _buildStartOverlay(loc),
            if (_game.status == GameStatus.paused) _buildPauseOverlay(loc),
            const SizedBox(height: 20), // Bottom padding
          ],
        ),
      ),
    );
  }
  Widget _buildPowerUpHub() {
    final stats = ref.watch(playerStatsProvider);
    
    return Align(
      alignment: Alignment.bottomRight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPowerUpButton(
            icon: Icons.slow_motion_video,
            label: 'YAVAŞLAT',
            count: stats.slowMoCount,
            color: Colors.lightBlueAccent,
            onPressed: () => _handlePowerUp('slowMo'),
          ),
          const SizedBox(height: 12),
          _buildPowerUpButton(
            icon: Icons.unfold_more,
            label: 'GENİŞLET',
            count: stats.expandCount,
            color: AppColors.success,
            onPressed: () => _handlePowerUp('expand'),
          ),
          const SizedBox(height: 12),
          _buildPowerUpButton(
            icon: Icons.auto_fix_high,
            label: 'MIKNATIS',
            count: stats.magnetCount,
            color: AppColors.secondary,
            onPressed: () => _handlePowerUp('magnet'),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.5),
    );
  }

  Widget _buildPowerUpButton({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
    required VoidCallback onPressed,
  }) {
    final bool hasStock = count > 0;
    
    return GestureDetector(
      onTap: hasStock ? onPressed : null,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.surface.withAlpha(hasStock ? 220 : 100),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasStock ? color.withAlpha(150) : Colors.white10,
            width: 2,
          ),
          boxShadow: hasStock ? [
            BoxShadow(color: color.withAlpha(40), blurRadius: 10, spreadRadius: 1),
          ] : [],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: hasStock ? color : Colors.white24, size: 28),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: hasStock ? Colors.white70 : Colors.white10,
                  ),
                ),
              ],
            ),
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: hasStock ? AppColors.primary : AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 2),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePowerUp(String type) async {
    final success = await ref.read(playerStatsProvider.notifier).usePowerUp(type);
    if (success) {
      if (type == 'slowMo') _game.activateSlowMo();
      if (type == 'expand') _game.activateExpand();
      if (type == 'magnet') _game.activateMagnet();
      setState(() {});
    }
  }

  Widget _buildTimerBar() {
    final fraction = (_timeLeft / 30.0).clamp(0.0, 1.0);
    final isCritical = _timeLeft <= 7.0;
    
    final color = fraction > 0.6
        ? AppColors.success
        : fraction > 0.3
            ? AppColors.warning
            : AppColors.error;

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(40),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Glow Background
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: color.withAlpha(60),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                // Main Progress
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 8,
                    width: double.infinity,
                    color: Colors.white.withAlpha(20),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: fraction,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              color.withAlpha(150),
                              color,
                              color.withAlpha(150),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ).animate(target: isCritical ? 1 : 0)
             .shake(duration: 500.ms, hz: 10, offset: const Offset(2, 0))
             .shimmer(duration: 1000.ms, color: Colors.white.withAlpha(50)),
            
            const SizedBox(height: 4),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer_outlined, size: 14, color: color.withAlpha(200)),
                const SizedBox(width: 4),
                Text(
                  '${_timeLeft.toStringAsFixed(1)}s',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(color: color.withAlpha(120), blurRadius: 6),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLivesRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final active = index < _lives;
        var heart = Icon(
            active ? Icons.favorite : Icons.favorite_border,
            color: active ? Colors.redAccent : Colors.white.withAlpha(50),
            size: 28,
          ).animate(target: active ? 1 : 0)
           .scale(duration: 400.ms, curve: Curves.elasticOut);
        
        if (active && _lives == 1) {
          heart = heart.shimmer(duration: 1200.ms);
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: heart,
        );
      }),
    );
  }

  Widget _buildTopBar(Loc loc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildScoreCard(loc),
        _buildTopActions(),
        _buildLevelCard(loc),
      ],
    );
  }

  Widget _buildScoreCard(Loc loc) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(220),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
        border: Border.all(color: AppColors.primary.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.score,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: child,
            ),
            child: Text(
              '$_displayScore',
              key: ValueKey(_displayScore),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.3);
  }

  Widget _buildLevelCard(Loc loc) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(220),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
        border: Border.all(color: AppColors.secondary.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            loc.level,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: child,
            ),
            child: Text(
              '$_displayLevel',
              key: ValueKey(_displayLevel),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.3);
  }

  Widget _buildTopActions() {
    if (_game.status != GameStatus.playing && _game.status != GameStatus.paused) {
      return const SizedBox.shrink();
    }
    return GestureDetector(
      onTap: () {
        _game.togglePause();
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingS),
        decoration: BoxDecoration(
          color: AppColors.surface.withAlpha(180),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _game.status == GameStatus.paused ? Icons.play_arrow : Icons.pause,
          color: AppColors.textPrimary,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildStartOverlay(Loc loc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 80),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingXL,
          vertical: AppDimensions.paddingL,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface.withAlpha(230),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusXL),
          border: Border.all(color: AppColors.primary.withAlpha(100), width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(40),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.touch_app,
              size: 56,
              color: AppColors.primary,
            ).animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15), duration: 800.ms),
            const SizedBox(height: AppDimensions.paddingM),
            Text(
              loc.tapToStart,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingS),
            Text(
              loc.tapToDrop,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPauseOverlay(Loc loc) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.surface.withAlpha(245),
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusXL),
            border: Border.all(color: AppColors.primary.withAlpha(120), width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 30, spreadRadius: 5),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.pause_circle_filled, size: 48, color: AppColors.primary),
                const SizedBox(height: 12),
                Text(
                  loc.paused,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _game.togglePause();
                      setState(() {});
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: Text(loc.continueGame),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _game.restart();
                      setState(() {
                        _displayScore = 0;
                        _displayLevel = 1;
                      });
                    },
                    icon: const Icon(Icons.replay),
                    label: Text(loc.restart),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: BorderSide(color: AppColors.primary.withAlpha(100)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white10),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.home, size: 20),
                  label: Text(loc.menu),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTap() {
    if (_game.status == GameStatus.waiting) {
      _game.startGame();
      setState(() {});
    } else if (_game.status == GameStatus.playing) {
      _game.dropBlock();
    } else if (_game.status == GameStatus.paused) {
      // Don't propagate taps when paused (handled by pause overlay buttons)
    }
  }

  void _showGameOverDialog() {
    if (!mounted) return;
    final stats = ref.read(playerStatsProvider);
    final isHighScore = _game.score >= stats.highScore && _game.score > 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameOverDialog(
        score: _game.score,
        level: _game.currentLevel,
        maxCombo: _game.maxCombo,
        perfectCount: _game.perfectCount,
        isHighScore: isHighScore,
        onRestart: _onRestart,
        onMenu: _onMenu,
      ),
    );
  }

  void _onRestart() {
    Navigator.pop(context); // close dialog
    _dismissLevelUpOverlay();
    _game.restart();
    setState(() {
      _displayScore = 0;
      _displayLevel = 1;
    });
  }

  void _onMenu() {
    Navigator.pop(context); // close dialog
    Navigator.pop(context); // go back to menu
  }
}

// ─── Level Up Banner Overlay ─────────────────────────────────────
class _LevelUpBanner extends StatefulWidget {
  final int level;
  final VoidCallback onDone;
  const _LevelUpBanner({required this.level, required this.onDone});

  @override
  State<_LevelUpBanner> createState() => _LevelUpBannerState();
}

class _LevelUpBannerState extends State<_LevelUpBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward().then((_) => widget.onDone());

    _slide = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: const Offset(0, -1.5), end: Offset.zero)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: ConstantTween(Offset.zero),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Offset.zero, end: const Offset(0, -1.5))
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
    ]).animate(_ctrl);

    _fade = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tierName = _tierName(widget.level);
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFB45309), Color(0xFFFBBF24), Color(0xFFB45309)],
                ),
                borderRadius: BorderRadius.circular(40),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x99FBBF24),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'LEVEL ${widget.level}',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 3,
                      shadows: [Shadow(color: Colors.black38, blurRadius: 6)],
                    ),
                  ),
                  if (tierName.isNotEmpty)
                    Text(
                      tierName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C1917),
                        letterSpacing: 2,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _tierName(int level) {
    if (level <= 10) return '● KOLAY';
    if (level <= 25) return '●● ORTA';
    if (level <= 40) return '●●● ZOR';
    return '●●●● İMKANSIZ';
  }
}
