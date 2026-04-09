import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../core/localization.dart';
import '../providers/game_provider.dart';
import 'levels/level_config.dart';
import '../data/models/player_stats.dart';
import 'components/weather_systems.dart';

enum GameStatus {
  waiting,
  playing,
  paused,
  gameOver,
}

enum BlockState {
  moving,
  falling,
  placed,
}

enum PlacementResult {
  perfect,
  good,
  ok,
  miss,
}



// ─── Particle Burst ─────────────────────────────────────────────
class ParticleBurst extends PositionComponent {
  final Color color;
  final int count;
  final String activeSkin;
  final List<_Particle> _particles = [];
  final Random _rng = Random();
  double life = 0;
  static const double maxLife = 0.8;

  ParticleBurst({
    required this.color,
    this.count = 12,
    this.activeSkin = 'default',
    required Vector2 position,
  }) : super(position: position);

  @override
  void onMount() {
    super.onMount();
    for (int i = 0; i < count; i++) {
      final angle = _rng.nextDouble() * pi * 2;
      final speed = 80 + _rng.nextDouble() * 160;
      _particles.add(_Particle(
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 60,
        size: 3 + _rng.nextDouble() * 5,
      ));
    }
  }

  @override
  void render(Canvas canvas) {
    final opacity = (1.0 - (life / maxLife)).clamp(0.0, 1.0);
    
    if (activeSkin == 'hologram') {
      final paint = Paint()..color = color.withAlpha((opacity * 255).round())
         ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      for (final p in _particles) {
        canvas.drawRect(Rect.fromCenter(center: Offset(p.x, p.y), width: p.size*1.5, height: p.size*1.5), paint);
      }
    } else if (activeSkin == 'ice') {
      final paint = Paint()..color = Colors.white.withAlpha((opacity * 200).round());
      for (final p in _particles) {
        canvas.drawRect(Rect.fromCenter(center: Offset(p.x, p.y), width: p.size, height: p.size), paint);
      }
    } else {
      final paint = Paint()..color = color.withAlpha((opacity * 255).round());
      for (final p in _particles) {
        canvas.drawCircle(Offset(p.x, p.y), p.size * opacity, paint);
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    life += dt;
    for (final p in _particles) {
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.vy += 300 * dt; // gravity
    }
    if (life >= maxLife) {
      removeFromParent();
    }
  }
}

class _Particle {
  double x = 0, y = 0;
  double vx, vy;
  double size;
  _Particle({required this.vx, required this.vy, required this.size});
}

// ─── Flash Joint ────────────────────────────────────────────────
class FlashLine extends PositionComponent {
  final double lineWidth;
  double life = 0;
  static const double maxLife = 0.2;

  FlashLine({
    required this.lineWidth,
    required Vector2 position,
  }) : super(position: position, anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    final t = life / maxLife; // 0 to 1
    final opacity = (1.0 - t).clamp(0.0, 1.0);
    
    // Scale X stretches outwards rapidly
    final currentWidth = lineWidth * (1.0 + t * 2);
    
    final paint = Paint()
      ..color = Colors.white.withAlpha((opacity * 100).round()) // Reduced brightness
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: currentWidth, height: 4), 
      paint
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    life += dt;
    if (life >= maxLife) removeFromParent();
  }
}

// ─── Game Block ─────────────────────────────────────────────────
class GameBlock extends PositionComponent {
  double blockWidth;
  double blockHeight;
  int colorIndex;
  late double moveSpeed;
  bool movingRight = true;
  BlockState state = BlockState.moving;
  int level;
  double fallVelocity = 0;
  double bounceTime = 0;
  bool isBouncing = false;
  String activeSkin;
  
  // Squash and Stretch
  double squashTime = 0;
  bool isSquashing = false;

  // Effect trackers
  double lifeTime = 0;
  bool isGiftBlock = false;

  GameBlock({
    required this.blockWidth,
    required this.blockHeight,
    required this.colorIndex,
    required this.level,
    required this.moveSpeed,
    required this.activeSkin,
    super.position,
  }) : super(
    size: Vector2(blockWidth, blockHeight),
    anchor: Anchor.center,
  );

  @override
  void render(Canvas canvas) {
    if (level >= 6 && state == BlockState.moving) {
      // Blinking/Blind effect for higher levels (disappears briefly)
      if (sin(lifeTime * (level * 1.5)) > 0.5) {
         // render faint ghost representation or skip completely to be ruthless
         final faintPaint = Paint()..color = AppColors.blockColors[colorIndex % AppColors.blockColors.length].withAlpha(20)..style = PaintingStyle.stroke;
         canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: blockWidth, height: blockHeight), faintPaint);
         return; // Skip normal rendering!
      }
    }

    canvas.save();
    
    // Apply Squash and Stretch scaling
    if (isSquashing) {
       // A quick spring: scale down Y, scale up X, then bounce back.
       final t = squashTime / 0.15; // Complete animation in 0.15s
       if (t <= 1.0) {
         final squashY = 1.0 - sin(t * pi) * 0.3; // dips to 0.7
         final squashX = 1.0 + sin(t * pi) * 0.15; // stretches to 1.15
         // Anchor scale to the center of the block
         canvas.translate(blockWidth / 2, blockHeight / 2);
         canvas.scale(squashX, squashY);
         canvas.translate(-blockWidth / 2, -blockHeight / 2);
       }
    }
  
    Color baseColor = AppColors.blockColors[colorIndex % AppColors.blockColors.length];
    
    if (activeSkin == 'classic') {
       final shades = [const Color(0xFF2D3436), const Color(0xFF636E72), const Color(0xFFB2BEC3)];
       baseColor = shades[colorIndex % shades.length];
    } else if (activeSkin == 'ice') {
       final shades = [const Color(0xFFE0F7FA), const Color(0xFF80DEEA), const Color(0xFF4DD0E1)];
       baseColor = shades[colorIndex % shades.length];
    } else if (activeSkin == 'hologram') {
       final shades = [const Color(0xFF00F5FF), const Color(0xFFBF00FF), const Color(0xFF39FF14)];
       baseColor = shades[colorIndex % shades.length];
    }

    final rect = Rect.fromLTWH(0, 0, blockWidth, blockHeight);
    
    // Draw Gift Box icon if it's a gift block
    if (isGiftBlock) {
      final giftPaint = Paint()
        ..color = Colors.amber
        ..style = PaintingStyle.fill;
      // Draw a simple cube icon or star for the gift
      canvas.drawRect(Rect.fromCenter(center: Offset(blockWidth/2, blockHeight/2), width: 14, height: 14), giftPaint);
      final ribbonPaint = Paint()..color = Colors.red..style = PaintingStyle.stroke..strokeWidth = 2;
      canvas.drawLine(Offset(blockWidth/2, blockHeight/2 - 7), Offset(blockWidth/2, blockHeight/2 + 7), ribbonPaint);
      canvas.drawLine(Offset(blockWidth/2 - 7, blockHeight/2), Offset(blockWidth/2 + 7, blockHeight/2), ribbonPaint);
    }

    // Removing the ugly long shadow to keep it clean, just a tiny dark edge if classic
    if (activeSkin == 'classic' || activeSkin == 'ice') {
      final outlinePaint = Paint()
        ..color = Colors.black.withAlpha(20)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), outlinePaint);
    }

    if (activeSkin == 'hologram') {
      final paint = Paint()
        ..color = baseColor.withAlpha(50)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), paint);
      
      final strokePaint = Paint()
        ..color = baseColor.withAlpha(180)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 4);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), strokePaint);

      final scanline = Paint()
        ..color = baseColor.withAlpha(100)
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, 0, blockWidth, 4), scanline);

    } else if (activeSkin == 'ice') {
      final paint = Paint()..color = baseColor.withAlpha(180);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(0)), paint);
      
      final topFrost = Paint()
        ..color = Colors.white.withAlpha(200);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, blockWidth, 6), const Radius.circular(0)), topFrost);
      
      final stroke = Paint()..color = Colors.white.withAlpha(100)..style=PaintingStyle.stroke;
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(0)), stroke);
    } else {
      final paint = Paint()..color = baseColor;
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), paint);

      final highlightPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [ Colors.white.withAlpha(90), Colors.transparent ],
        ).createShader(Rect.fromLTWH(0, 0, blockWidth, blockHeight / 2));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(3, 2, blockWidth - 6, blockHeight / 2 - 2),
          const Radius.circular(4),
        ),
        highlightPaint,
      );

      final edgePaint = Paint()..color = baseColor.withAlpha(150);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, blockHeight / 2 - 4, blockWidth, 4),
          const Radius.circular(2),
        ),
        edgePaint,
      );
    }

    if (state == BlockState.moving) {
      final glowPaint = Paint()
        ..color = Colors.white.withAlpha(100)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), glowPaint);
    }
    
    canvas.restore();
  }

  void triggerSquash() {
    isSquashing = true;
    squashTime = 0;
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    lifeTime += dt;
    if (isSquashing) {
      squashTime += dt;
      if (squashTime > 0.15) {
        isSquashing = false;
      }
    }
  }

  void updateMovement(double dt, double gameWidth) {
    if (state != BlockState.moving) return;

    final newX = position.x + (movingRight ? moveSpeed * dt : -moveSpeed * dt);
    final halfWidth = blockWidth / 2;

    if (newX + halfWidth >= gameWidth) {
      movingRight = false;
    } else if (newX - halfWidth <= 0) {
      movingRight = true;
    }

    position = Vector2(newX.clamp(halfWidth, gameWidth - halfWidth), position.y);
  }
}

// ─── Falling Piece (cut-off overhang) ───────────────────────────
class FallingPiece extends PositionComponent {
  final double pieceWidth;
  final double pieceHeight;
  final Color color;
  double fallVelocity = -200; // Kickback bounce
  double rotation = 0;
  double rotSpeed;
  final String activeSkin;
  double _time = 0; // added for tremble animation

  FallingPiece({
    required this.pieceWidth,
    required this.pieceHeight,
    required this.color,
    required this.rotSpeed,
    required this.activeSkin,
    required Vector2 position,
  }) : super(position: position, anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    canvas.save();
    
    // Add tremble effect
    final tremble = sin(_time * 40) * 3.0; // vibrate left and right rapidly
    canvas.translate(tremble, 0);
    
    canvas.rotate(rotation);
    
    final rect = Rect.fromCenter(center: Offset.zero, width: pieceWidth, height: pieceHeight);
    
    if (activeSkin == 'hologram') {
       final fill = Paint()..color = color.withAlpha(50);
       final stroke = Paint()..color = color.withAlpha(200)..style = PaintingStyle.stroke..strokeWidth=2;
       canvas.drawRect(rect, fill);
       canvas.drawRect(rect, stroke);
    } else if (activeSkin == 'ice') {
       final paint = Paint()..color = color.withAlpha(180);
       canvas.drawRect(rect, paint);
       final frost = Paint()..color = Colors.white.withAlpha(100);
       canvas.drawRect(Rect.fromLTWH(-pieceWidth/2, -pieceHeight/2, pieceWidth, 4), frost);
    } else {
       final paint = Paint()..color = color.withAlpha(180);
       canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), paint);
    }
    canvas.restore();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    fallVelocity += 1100 * dt; // gravity
    position.y += fallVelocity * dt;
    position.x += (rotSpeed * 25) * dt; // lateral momentum
    rotation += rotSpeed * dt;
    if (position.y > 1000) {
      removeFromParent();
    }
  }
}

// ─── Game Platform ──────────────────────────────────────────────
class GamePlatform extends PositionComponent {
  double platformWidth;
  double platformHeight;

  GamePlatform({
    required this.platformWidth,
    required this.platformHeight,
    required Vector2 position,
  }) : super(
    position: position,
    size: Vector2(platformWidth, platformHeight),
    anchor: Anchor.center,
  );

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, platformWidth, platformHeight);

    // Shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.translate(2, 3), const Radius.circular(8)),
      Paint()..color = Colors.black.withAlpha(40),
    );

    // Main
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()..color = AppColors.surfaceLight,
    );

    // Top highlight
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(4, 2, platformWidth - 8, platformHeight / 3),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.white.withAlpha(20),
    );

    // Border
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()
        ..color = AppColors.primary.withAlpha(100)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }
}

// ─── Guide Line ──────────────────────────────────────────────────
class GuideLine extends PositionComponent {
  double guideY;
  double guideWidth;
  double dashPhase = 0;

  GuideLine({required this.guideY, required this.guideWidth})
      : super(position: Vector2(0, guideY));

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(25)
      ..strokeWidth = 1;

    const dashWidth = 8.0;
    const gapWidth = 6.0;
    double startX = dashPhase % (dashWidth + gapWidth);
    while (startX < 360) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset((startX + dashWidth).clamp(0, 360), 0),
        paint,
      );
      startX += dashWidth + gapWidth;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    dashPhase += 20 * dt;
  }
}

// ═══════════════════════════════════════════════════════════════
//  MAIN GAME
// ═══════════════════════════════════════════════════════════════
class TowerGame extends FlameGame {
  final ProviderContainer providerContainer;
  Loc get loc => providerContainer.read(locProvider);

  static const double gameWidth = 360.0;
  static const double gameHeight = 640.0;
  static const double platformWidth = 200.0;
  static const double platformHeight = 30.0;

  final List<GameBlock> placedBlocks = [];
  GameBlock? currentBlock;
  GamePlatform? platform;
  GuideLine? _guideLine;

  int currentLevel = 1;
  int score = 0;
  int combo = 0;
  int lives = 3;
  static const int maxLives = 3;
  int maxCombo = 0;
  int perfectCount = 0;
  int blocksPlaced = 0;
  double currentBlockWidth = 0;
  bool _nextSpawnFromRight = true;

  GameStatus status = GameStatus.waiting;
  LevelConfig? currentLevelConfig;
  PlacementResult? lastPlacement;

  double targetCameraY = 0;
  double currentCameraY = 0;
  double basePlatformY = 0;
  double _hitStopTime = 0;

  // Level Progression Tracker
  int blocksInCurrentLevel = 0;

  // Game Feel variables
  double _shakeIntensity = 0;
  double _shakeTime = 0;
  double _punchY = 0; // Compress dip simulation
  double _currentZoom = 1.0;
  double _targetZoom = 1.0;
  double _globalTime = 0; // For swaying
  
  final Random _random = Random();

  // Callbacks for UI
  VoidCallback? onScoreChanged;
  VoidCallback? onGameOver;
  VoidCallback? onPlacement;
  void Function(double)? onTimeUpdate;
  void Function(int)? onLevelUp;
  void Function(int)? onLivesChanged;
  void Function(String)? onGiftOpened;

  // Time Rush mode
  final bool isTimeRush;
  double timeLeft = 30.0;

  // Power-Ups state
  bool isSlowMoActive = false;
  double _slowMoTimer = 0;
  // Weather and Physics
  late WeatherSystem _weatherSystem;
  double _windForce = 0;

  String activeTheme = 'default';
  List<Color> _bgColors = [AppColors.background, const Color(0xFF1a1a2e)];
  Paint? _bgPaint;
  final Paint _bgSfxPaint = Paint();

  TowerGame({required this.providerContainer, this.isTimeRush = false}) {
    final stats = providerContainer.read(playerStatsProvider);
    activeTheme = stats.activeTheme;
    _updateThemeColors();
  }

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Scale game to any screen: treat world as fixed 360x640, let viewport handle scaling.
    camera.viewport = FixedResolutionViewport(resolution: Vector2(gameWidth, gameHeight));
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.zoom = 1.0;

    // Moving the base up so it is not pushed at the bottom edge.
    // Center of screen is 320. 470 is 150 pixels below center.
    basePlatformY = gameHeight / 2 + 150; 


    _weatherSystem = WeatherSystem();
    world.add(_weatherSystem);

    _initPlatform();
    _spawnNewBlock();
    _updateWeatherForLevel();
  }

  void _initPlatform() {
    platform = GamePlatform(
      platformWidth: platformWidth,
      platformHeight: platformHeight,
      position: Vector2(gameWidth / 2, basePlatformY),
    );
    world.add(platform!);
    currentBlockWidth = platformWidth;
  }

  void _spawnNewBlock() {
    currentLevelConfig = LevelManager.getLevel(currentLevel);

    // Block width is determined by the last placed block (slicing mechanic)
    final spawnWidth = placedBlocks.isEmpty
        ? currentLevelConfig!.blockWidth.clamp(30.0, platformWidth)
        : currentBlockWidth.clamp(8.0, 300.0);

    if (spawnWidth < 8) {
      _triggerGameOver();
      return;
    }

    final spawnY = _getStackTopY() - 50;

    // Alternating spawn sides
    final spawnX = _nextSpawnFromRight ? gameWidth + spawnWidth / 2 : -spawnWidth / 2;
    final moveDirRight = !_nextSpawnFromRight; // Come from left? move right. Come from right? move left.

    currentBlock = GameBlock(
      blockWidth: spawnWidth,
      blockHeight: currentLevelConfig!.blockHeight,
      colorIndex: currentLevelConfig!.colorIndex,
      level: currentLevel,
      moveSpeed: currentLevelConfig!.moveSpeed,
      activeSkin: providerContainer.read(playerStatsProvider).activeSkin,
      position: Vector2(spawnX, spawnY),
    );
    currentBlock!.movingRight = moveDirRight;

    // 1 in 30 blocks is a gift block
    if (blocksPlaced > 0 && (blocksPlaced + 1) % 30 == 0) {
      currentBlock!.isGiftBlock = true;
    }

    _nextSpawnFromRight = !_nextSpawnFromRight; // Flip for next time

    world.add(currentBlock!);

    // Update guide line
    if (_guideLine != null) {
      _guideLine!.removeFromParent();
    }
    final landingY = _getLandingSurfaceY();
    _guideLine = GuideLine(guideY: landingY, guideWidth: gameWidth);
    world.add(_guideLine!);

    _updateCamera();
  }

  double _getStackTopY() {
    if (placedBlocks.isEmpty) {
      return basePlatformY - platformHeight / 2;
    }
    return placedBlocks.last.position.y - placedBlocks.last.blockHeight / 2;
  }

  double _getLandingSurfaceY() {
    if (placedBlocks.isEmpty) {
      // Platform top surface
      return basePlatformY - platformHeight / 2;
    }
    // Last block's top surface
    return placedBlocks.last.position.y - placedBlocks.last.blockHeight / 2;
  }

  void startGame() {
    if (status == GameStatus.waiting) {
      status = GameStatus.playing;
      try {
        providerContainer.read(audioServiceProvider).playClick();
        providerContainer.read(audioServiceProvider).startMusic();
      } catch (_) {}
    }
  }

  void togglePause() {
    if (status == GameStatus.playing) {
      status = GameStatus.paused;
    } else if (status == GameStatus.paused) {
      status = GameStatus.playing;
    }
  }

  void dropBlock() {
    if (currentBlock == null || status != GameStatus.playing) return;
    if (currentBlock!.state != BlockState.moving) return;

    currentBlock!.state = BlockState.falling;
    currentBlock!.fallVelocity = 0;
    try {
      providerContainer.read(hapticServiceProvider).light();
    } catch (_) {}
  }

  void _onBlockLanded(GameBlock block) {
    // Check for gift block reward
    if (block.isGiftBlock) {
      _handleGiftReward();
    }

    final landingY = _getLandingSurfaceY();
    final result = _calculatePlacement(block);
    lastPlacement = result;

    if (result == PlacementResult.miss) {
      _handleMiss(block);
      return;
    }

    // Snap Y position before slicing to ensure correct stack height (Anchor.center)
    block.position.y = landingY - block.blockHeight / 2;

    // Slice the block
    _sliceBlock(block, result);

    try {
      // Nota sistemi: Kulenin yüksekliğine göre nota çal
      providerContainer.read(audioServiceProvider).playNote(placedBlocks.length);
    } catch (_) {}

    // Level progression
    final blocksNeeded = LevelManager.getBlocksRequiredForLevel(currentLevel);
    if (blocksInCurrentLevel >= blocksNeeded) {
      blocksInCurrentLevel = 0;
      currentLevel++;
      _updateWeatherForLevel();
      
      // Full-screen level-up flash
      world.add(LevelUpFlash(level: currentLevel));
      onLevelUp?.call(currentLevel);
      _targetZoom = 1.0; 
      
      // Time Rush: Bonus +5 seconds on level up
      if (isTimeRush) {
        timeLeft = (timeLeft + 5.0).clamp(0.0, 30.0);
        onTimeUpdate?.call(timeLeft);
      }
    }

    onScoreChanged?.call();
    onPlacement?.call();

    _updateCamera();

    _spawnNewBlock();
  }

  PlacementResult _calculatePlacement(GameBlock block) {
    final targetX = placedBlocks.isEmpty ? platform!.position.x : placedBlocks.last.position.x;
    final targetWidth = placedBlocks.isEmpty ? platformWidth : placedBlocks.last.blockWidth;
    final blockX = block.position.x;

    final overlap = (block.blockWidth / 2 + targetWidth / 2) - (blockX - targetX).abs();

    if (overlap <= 0) {
      return PlacementResult.miss;
    }

    final accuracy = overlap / block.blockWidth;
    if (accuracy >= 0.92) return PlacementResult.perfect;
    if (accuracy >= 0.65) return PlacementResult.good;
    return PlacementResult.ok;
  }

  void _sliceBlock(GameBlock block, PlacementResult result) {
    final targetX = placedBlocks.isEmpty ? platform!.position.x : placedBlocks.last.position.x;
    final targetWidth = placedBlocks.isEmpty ? platformWidth : placedBlocks.last.blockWidth;
    final blockX = block.position.x;
    final diff = blockX - targetX;

    final overlap = (block.blockWidth / 2 + targetWidth / 2) - diff.abs();
    final landingY = _getLandingSurfaceY(); // Calculate landing surface up front

    if (result == PlacementResult.perfect) {
      // Perfect: snap to center, no slicing
      block.position.x = targetX;

      combo++;
      maxCombo = max(maxCombo, combo);
      perfectCount++;

      // Regrowth logic
      if (combo >= 5) {
        final maxAllowedWidth = LevelManager.getLevel(currentLevel).blockWidth;
        if (currentBlockWidth < maxAllowedWidth) {
          final newWidth = min(currentBlockWidth + 5.0, maxAllowedWidth);
          currentBlockWidth = newWidth;
          block.blockWidth = newWidth;
          block.size = Vector2(newWidth, block.blockHeight);

          // Flash particle
          world.add(ParticleBurst(
            color: Colors.white,
            count: 30,
            activeSkin: block.activeSkin,
            position: block.position.clone(),
          ));
        } else {
          currentBlockWidth = block.blockWidth;
        }
      } else {
        currentBlockWidth = block.blockWidth;
      }

      // Scoring: Minimal points
      final int basePoints = 10;
      final int comboBonus = (combo > 2) ? (combo - 2) * 2 : 0;
      final int totalPoints = basePoints + comboBonus;
      score += totalPoints;

      // Coin Earning
      int earnedCoins = 2;
      if (combo >= 5) earnedCoins += 5; // Bonus coins for long combos
      providerContainer.read(playerStatsProvider.notifier).addCoins(earnedCoins);

      // Particle burst and flash line
      world.add(ParticleBurst(
        color: AppColors.success,
        count: 20,
        activeSkin: block.activeSkin,
        position: block.position.clone(),
      ));
      
      world.add(FlashLine(
        lineWidth: block.blockWidth,
        position: Vector2(block.position.x, landingY), // at the seam
      ));

      // Floating text & Motivational messages
      String msg = loc.perfect;
      if (combo >= 15) {
        msg = 'EFSANEVİ! 🔥';
      } else if (combo >= 10) {
        msg = 'İNANILMAZ! ✨';
      } else if (combo >= 5) {
        msg = 'HARİKA! 🌟';
      } else if (combo >= 3) {
        msg = 'SÜPER! 👍';
      }

      _showFloatingText('$msg +$totalPoints', AppColors.success, block.position.clone()..y -= 30, fontSize: combo >= 5 ? 28 : 22);

      _shakeScreen(2.0); 
      _hitStopTime = 0.05; 
      _punchY = 12.0; 
      _targetZoom = min(1.0 + (combo * 0.02), 1.15); 

      try {
        providerContainer.read(hapticServiceProvider).perfect();
        providerContainer.read(audioServiceProvider).playNote(placedBlocks.length, isPerfect: true);
      } catch (_) {}

      // Life recovery: 10 perfects in a row = +1 life
      if (combo > 0 && combo % 10 == 0) {
        if (lives < maxLives) {
          lives++;
          onLivesChanged?.call(lives);
          _showFloatingText('+1 CAN! ❤️', AppColors.success, block.position.clone()..y -= 60, fontSize: 30);
        }
      }

      // Time Rush: +2 seconds for perfect
      if (isTimeRush) {
        timeLeft = (timeLeft + 2.0).clamp(0.0, 30.0);
        onTimeUpdate?.call(timeLeft);
      }
    } else {
      // Slice: cut off the overhang
      final newWidth = overlap;
      final overhangWidth = block.blockWidth - newWidth;

      // Determine which side the overhang is on
      final overhangOnRight = diff > 0;
      final newCenterX = overhangOnRight
          ? blockX - overhangWidth / 2
          : blockX + overhangWidth / 2;

      // Create falling piece for the overhang
      final overhangX = overhangOnRight
          ? blockX + newWidth / 2
          : blockX - newWidth / 2;

      world.add(FallingPiece(
        pieceWidth: overhangWidth,
        pieceHeight: block.blockHeight,
        color: AppColors.blockColors[block.colorIndex % AppColors.blockColors.length],
        rotSpeed: (overhangOnRight ? 1 : -1) * (2 + _random.nextDouble() * 3),
        activeSkin: block.activeSkin,
        position: Vector2(overhangX, block.position.y),
      ));

      // Resize the block
      block.blockWidth = newWidth;
      block.size = Vector2(newWidth, block.blockHeight);
      block.position.x = newCenterX;
      currentBlockWidth = newWidth;

      combo = 0;
      _targetZoom = 1.0; // Reset zoom on slice

      if (result == PlacementResult.good) {
        final int basePoints = 5;
        score += basePoints;
        
        // Earn 1 coin for good placement
        providerContainer.read(playerStatsProvider.notifier).addCoins(1);

        _showFloatingText('${loc.good} +$basePoints', AppColors.warning, block.position.clone()..y -= 30);
        _shakeScreen(2.5); 
        _hitStopTime = 0.02; 
        _punchY = 5.0; 
        
        world.add(FlashLine(
          lineWidth: newWidth,
          position: Vector2(newCenterX, landingY), 
        ));

        // Small particle burst
        world.add(ParticleBurst(
          color: AppColors.warning,
          count: 8,
          activeSkin: block.activeSkin,
          position: Vector2(overhangX, block.position.y),
        ));

        try {
          providerContainer.read(hapticServiceProvider).medium();
        } catch (_) {}

        // Time Rush: +1 second for good
        if (isTimeRush) {
          timeLeft = (timeLeft + 1.0).clamp(0.0, 30.0);
          onTimeUpdate?.call(timeLeft);
        }
      } else {
        final int basePoints = 2;
        score += basePoints;
        _showFloatingText('+$basePoints', AppColors.textSecondary, block.position.clone()..y -= 30, fontSize: 18);
        _shakeScreen(4.0);
    _punchY = -15.0; // Upward jerk on miss

        world.add(ParticleBurst(
          color: AppColors.error,
          count: 6,
          activeSkin: block.activeSkin,
          position: Vector2(overhangX, block.position.y),
        ));

        try {
          providerContainer.read(hapticServiceProvider).heavy();
        } catch (_) {}
      }
    }

    // Snap Y position
    block.position.y = landingY - block.blockHeight / 2;
    
    placedBlocks.add(block);
    blocksPlaced++;
    blocksInCurrentLevel++;
  }

  void _handleMiss(GameBlock block) {
    combo = 0;
    _targetZoom = 1.0;
    lastPlacement = PlacementResult.miss;

    // Make the block fall off
    block.state = BlockState.falling;
    world.add(FallingPiece(
      pieceWidth: block.blockWidth,
      pieceHeight: block.blockHeight,
      color: AppColors.blockColors[block.colorIndex % AppColors.blockColors.length],
      rotSpeed: (_random.nextBool() ? 1 : -1) * (3 + _random.nextDouble() * 4),
      activeSkin: block.activeSkin,
      position: block.position.clone(),
    ));
    block.removeFromParent();

    _shakeScreen(15.0);
    _showFloatingText(loc.miss, AppColors.error, block.position.clone()..y -= 30, fontSize: 32);

    try {
      providerContainer.read(hapticServiceProvider).error();
      providerContainer.read(audioServiceProvider).playMiss();
    } catch (_) {}

    lives--;
    onLivesChanged?.call(lives);

    if (lives <= 0) {
      _triggerGameOver();
      try {
        providerContainer.read(audioServiceProvider).playGameOver();
      } catch (_) {}
    } else {
      // Don't game over, just spawn next block on top of existing tower
      _spawnNewBlock();
    }
  }

  void _showFloatingText(String text, Color color, Vector2 pos, {double fontSize = 22}) {
    // Manual floating text via a simple component
    world.add(_FloatingTextComponent(text: text, color: color, pos: pos, fontSize: fontSize));
  }

  void _shakeScreen(double intensity) {
    _shakeIntensity = intensity;
    _shakeTime = 0;
  }

  void _updateCamera() {
    if (placedBlocks.isEmpty) {
      targetCameraY = 0;
      return;
    }

    final stackTop = _getStackTopY();
    // Start tracking earlier: keep stack top at Y = 400 (which is lower on screen)
    // The screen height is 640. So Y=400 means the camera starts moving up
    // when the tower reaches roughly just 140 units above base (540 -> 400).
    final desiredScreenY = 400.0;
    final cameraOffset = stackTop - desiredScreenY;

    if (cameraOffset < targetCameraY) {
      targetCameraY = cameraOffset;
    }
  }

  void _triggerGameOver() {
    if (status == GameStatus.gameOver) return;
    status = GameStatus.gameOver;

    try {
      providerContainer.read(playerStatsProvider.notifier).updateAfterGame(
        score: score,
        level: currentLevel,
        perfectCount: perfectCount,
        maxCombo: maxCombo,
        lastPlacement: combo > 0 ? PlacementQuality.perfect : PlacementQuality.miss,
      );
    } catch (_) {}

    onGameOver?.call();
  }

  void restart() {
    // Remove all game objects from world
    for (final block in placedBlocks) {
      block.removeFromParent();
    }
    placedBlocks.clear();

    if (currentBlock != null) {
      currentBlock!.removeFromParent();
      currentBlock = null;
    }

    if (platform != null) {
      platform!.removeFromParent();
      platform = null;
    }

    if (_guideLine != null) {
      _guideLine!.removeFromParent();
      _guideLine = null;
    }

    // Remove floating texts and particles
    world.children.whereType<_FloatingTextComponent>().forEach((c) => c.removeFromParent());
    world.children.whereType<ParticleBurst>().forEach((c) => c.removeFromParent());
    world.children.whereType<FallingPiece>().forEach((c) => c.removeFromParent());
    world.children.whereType<FlashLine>().forEach((c) => c.removeFromParent());

    currentLevel = 1;
    score = 0;
    combo = 0;
    maxCombo = 0;
    perfectCount = 0;
    blocksPlaced = 0;
    blocksInCurrentLevel = 0;
    currentBlockWidth = platformWidth;
    targetCameraY = 0;
    currentCameraY = 0;
    status = GameStatus.waiting;
    lastPlacement = null;
    _nextSpawnFromRight = true;
    _shakeIntensity = 0;
    lives = maxLives;
    onLivesChanged?.call(lives);
    _punchY = 0;
    _currentZoom = 1.0;
    _targetZoom = 1.0;
    _globalTime = 0;

    // Reset Time Rush
    timeLeft = 30.0;
    onTimeUpdate?.call(timeLeft);

    _initPlatform();
    _spawnNewBlock();

    onScoreChanged?.call();
  }

  @override
  void update(double dt) {
    if (_hitStopTime > 0) {
      _hitStopTime -= dt;
      return; // Freeze the game physics
    }

    _globalTime += dt;
    super.update(dt);

    // Smooth camera Y tracking
    if ((currentCameraY - targetCameraY).abs() > 0.5) {
      currentCameraY += (targetCameraY - currentCameraY) * 3.0 * dt;
    } else {
      currentCameraY = targetCameraY;
    }

    // Camera Zoom Spring
    _currentZoom += (_targetZoom - _currentZoom) * 4.0 * dt;
    camera.viewfinder.zoom = _currentZoom;
    
    // Camera Punch Spring (recovers back to 0)
    _punchY += (0 - _punchY) * 15.0 * dt;

    // Apply camera + screen shake + Sway (Wind effect for level >= 4)
    double shakeX = 0, shakeY = 0;
    
    // Slow-Mo Logic: scale delta time if active
    double activeDt = dt;
    if (isSlowMoActive) {
      _slowMoTimer -= dt;
      activeDt *= 0.4; // 60% slower
      if (_slowMoTimer <= 0) {
        isSlowMoActive = false;
      }
    }

    if (_shakeIntensity > 0.1) {
      _shakeTime += dt;
      final decay = exp(-_shakeTime * 8);
      shakeX = _random.nextDouble() * _shakeIntensity * decay * 2 - _shakeIntensity * decay;
      shakeY = _random.nextDouble() * _shakeIntensity * decay * 2 - _shakeIntensity * decay;
      if (decay < 0.01) _shakeIntensity = 0;
    }

    double swayX = 0;
    if (currentLevel >= 4 && status == GameStatus.playing) {
      // Wind heavily increases on higher levels
      swayX = sin(_globalTime * (currentLevel * 0.4)) * (currentLevel * 2.5);
    }

    camera.viewfinder.position = Vector2(gameWidth / 2 + shakeX + swayX, currentCameraY + gameHeight / 2 + shakeY + _punchY);

    // Block movement and falling
    if (currentBlock != null && status == GameStatus.playing) {
      // Wind Physics: Push block if level >= 5
      if (currentLevel >= 5) {
        final windStrength = (currentLevel - 4) * 15.0; // Increases with level
        _windForce = sin(_globalTime * 0.8) * windStrength;
        currentBlock!.position.x += _windForce * activeDt;
      }

      if (currentBlock!.state == BlockState.moving) {
        currentBlock!.updateMovement(activeDt, gameWidth);
      } else if (currentBlock!.state == BlockState.falling) {
        // Accelerated falling — uses LevelConfig gravity for increasing difficulty feel
        final gravity = currentLevelConfig?.gravity ?? 2500;
        currentBlock!.fallVelocity += gravity * activeDt;
        currentBlock!.position.y += currentBlock!.fallVelocity * activeDt;

        final targetY = _getLandingSurfaceY() - currentBlock!.blockHeight / 2;

        if (currentBlock!.position.y >= targetY) {
          currentBlock!.position.y = targetY;
          _onBlockLanded(currentBlock!);
        }
      }
    }

    // Time Rush: countdown
    if (isTimeRush && status == GameStatus.playing) {
      // Time flows faster as levels increase
      final timeSpeed = 1.0 + (currentLevel * 0.05);
      timeLeft -= dt * timeSpeed;
      
      onTimeUpdate?.call(timeLeft);
      if (timeLeft <= 0) {
        timeLeft = 0;
        _triggerGameOver();
      }
    }
  }

  // Power-up activation methods
  void activateSlowMo() {
    isSlowMoActive = true;
    _slowMoTimer = 5.0; // 5 seconds duration
  }

  void activateExpand() {
    // Reset block to a healthy width
    currentBlockWidth = platformWidth * 0.8; 
    if (currentBlock != null && currentBlock!.state == BlockState.moving) {
       currentBlock!.blockWidth = currentBlockWidth;
       currentBlock!.size = Vector2(currentBlockWidth, currentBlock!.blockHeight);
    }
    _showFloatingText('GENISLEDI!', AppColors.success, Vector2(180, 320), fontSize: 24);
  }

  void activateMagnet() {
    if (currentBlock != null && currentBlock!.state == BlockState.moving) {
       final targetX = placedBlocks.isEmpty ? platform!.position.x : placedBlocks.last.position.x;
       currentBlock!.position.x = targetX;
       dropBlock(); // Force drop immediately at perfect X
       _showFloatingText('MIKNATIS!', AppColors.secondary, Vector2(180, 320), fontSize: 24);
    }
  }

  void _handleGiftReward() {
    final rng = Random();
    final chance = rng.nextDouble();
    String rewardText = '';
    
    if (chance < 0.8) {
      // 80% chance for coins
      final coins = 50 + rng.nextInt(51);
      providerContainer.read(playerStatsProvider.notifier).addCoins(coins);
      rewardText = '+$coins COIN!';
    } else {
      // 20% chance for power-up
      final puRng = rng.nextInt(3);
      if (puRng == 0) {
        providerContainer.read(playerStatsProvider.notifier).buyPowerUp('slowMo', 0); // 0 price means free add
        rewardText = '+1 YAVAŞLAT!';
      } else if (puRng == 1) {
        providerContainer.read(playerStatsProvider.notifier).buyPowerUp('expand', 0);
        rewardText = '+1 GENİŞLET!';
      } else {
        providerContainer.read(playerStatsProvider.notifier).buyPowerUp('magnet', 0);
        rewardText = '+1 MIKNATIS!';
      }
    }
    
    onGiftOpened?.call(rewardText);
    _showFloatingText(rewardText, Colors.amber, Vector2(180, 280), fontSize: 28);
  }

  void _updateThemeColors() {
    switch (activeTheme) {
      case 'cyberpunk':
        _bgColors = [const Color(0xFF0F0C29), const Color(0xFF302B63), const Color(0xFF24243E)];
        break;
      case 'space':
        _bgColors = [const Color(0xFF000000), const Color(0xFF141E30), const Color(0xFF243B55)];
        break;
      case 'sunset':
        _bgColors = [const Color(0xFFFF512F), const Color(0xFFDD2476)];
        break;
      default:
        _bgColors = [AppColors.background, const Color(0xFF1a1a2e)];
    }
    _bgPaint = null; // Forces re-creation in render if needed, or we can pre-create
  }

  @override
  void render(Canvas canvas) {
    // Draw background gradient
    _bgPaint ??= Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: _bgColors,
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
    
    // Fill the background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), _bgPaint!);

    // Draw some theme-specific subtle effects
    if (activeTheme == 'cyberpunk') {
      _drawCyberGrid(canvas);
    } else if (activeTheme == 'space') {
      _drawSpaceStars(canvas);
    }

    super.render(canvas);
  }

  void _drawCyberGrid(Canvas canvas) {
    final gridPaint = _bgSfxPaint
      ..color = const Color(0xFF00F5FF).withAlpha(15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    // Parallax movement for grid
    final double offset = (_globalTime * 20) % 40;
    
    const double spacing = 40;
    for (double x = 0; x < size.x; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), gridPaint);
    }
    for (double y = offset; y < size.y; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), gridPaint);
    }
  }

  final List<Offset> _starPositions = [];
  final List<double> _starSizes = [];

  void _drawSpaceStars(Canvas canvas) {
    if (_starPositions.isEmpty) {
      final rng = Random(42);
      for (int i = 0; i < 40; i++) {
         _starPositions.add(Offset(rng.nextDouble() * size.x, rng.nextDouble() * size.y));
         _starSizes.add(rng.nextDouble() * 1.5);
      }
    }

    final starPaint = _bgSfxPaint..color = Colors.white.withAlpha(80);
    for (int i = 0; i < _starPositions.length; i++) {
       canvas.drawCircle(_starPositions[i], _starSizes[i], starPaint);
    }
  }

  void _updateWeatherForLevel() {
    final settings = providerContainer.read(settingsProvider);
    _weatherSystem.isEnabled = settings['weatherEffectsEnabled'] ?? true;

    if (currentLevel >= 10) {
      _weatherSystem.updateWeather(WeatherType.fog);
    } else if (currentLevel >= 7) {
      _weatherSystem.updateWeather(WeatherType.wind);
    } else if (currentLevel >= 4) {
      _weatherSystem.updateWeather(WeatherType.snow);
    } else {
      _weatherSystem.updateWeather(WeatherType.none);
    }
  }
}

// ─── Level Up Flash ──────────────────────────────────────────────
class LevelUpFlash extends PositionComponent {
  final int level;
  double life = 0;
  static const double maxLife = 1.8;

  LevelUpFlash({required this.level})
      : super(position: Vector2(180, 280), anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    final t = life / maxLife;
    // Phase 1 (0→0.3): flash white overlay fade-in
    // Phase 2 (0.3→1.0): "LEVEL N" text rises and fades
    final double opacity;
    if (t < 0.15) {
      opacity = t / 0.15; // ramp up
    } else if (t < 0.35) {
      opacity = 1.0 - ((t - 0.15) / 0.20); // ramp down fast
    } else {
      opacity = 0.0;
    }

    if (opacity > 0) {
      final flashPaint = Paint()..color = Colors.white.withAlpha((opacity * 180).round());
      canvas.drawRect(const Rect.fromLTWH(-600, -800, 1200, 1600), flashPaint);
    }

    // Text fades in at t=0.25 and floats up
    if (t > 0.2) {
      final textT = ((t - 0.2) / 0.8).clamp(0.0, 1.0);
      final textOpacity = (textT < 0.7 ? textT / 0.7 : 1.0 - ((textT - 0.7) / 0.3)).clamp(0.0, 1.0);
      final yOffset = -textT * 60;
      final scale = 1.0 + (1.0 - textT) * 0.4;

      canvas.save();
      canvas.translate(0, yOffset);
      canvas.scale(scale);

      // Outer glow ring
      final glowPaint = Paint()
        ..color = const Color(0xFFFBBF24).withAlpha((textOpacity * 80).round())
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
      canvas.drawCircle(Offset.zero, 60, glowPaint);

      // LEVEL text
      _drawCenteredText(
        canvas,
        'LEVEL $level',
        Offset.zero - const Offset(0, 10),
        fontSize: 38,
        color: Colors.white.withAlpha((textOpacity * 255).round()),
        shadow: Colors.black.withAlpha((textOpacity * 160).round()),
        isMainTitle: true,
      );

      // Tier label
      _drawCenteredText(
        canvas,
        LevelManager.getTierName(level).toUpperCase(),
        const Offset(0, 30),
        fontSize: 16,
        color: const Color(0xFFFBBF24).withAlpha((textOpacity * 255).round()),
        shadow: Colors.black.withAlpha((textOpacity * 100).round()),
        isMainTitle: false,
      );
      
      canvas.restore();
    }
  }

  TextPainter? _titlePainter;
  TextPainter? _tierPainter;

  void _drawCenteredText(
    Canvas canvas,
    String text,
    Offset center, {
    required double fontSize,
    required Color color,
    required Color shadow,
    required bool isMainTitle,
  }) {
    final tp = isMainTitle ? (_titlePainter ??= TextPainter(textDirection: TextDirection.ltr)) 
                           : (_tierPainter ??= TextPainter(textDirection: TextDirection.ltr));
    
    tp.text = TextSpan(
      text: text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        color: color,
        letterSpacing: 2,
        shadows: [Shadow(color: shadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
    );
    tp.layout();
    tp.paint(canvas, center + Offset(-tp.width / 2, -tp.height / 2));
  }

  @override
  void update(double dt) {
    super.update(dt);
    life += dt;
    if (life >= maxLife) removeFromParent();
  }
}

// ─── Simple Floating Text Component ─────────────────────────────
class _FloatingTextComponent extends PositionComponent {
  final String text;
  final Color color;
  final double fontSize;
  double life = 0;
  static const double maxLife = 1.5;

  _FloatingTextComponent({
    required this.text,
    required this.color,
    required Vector2 pos,
    this.fontSize = 22,
  }) : super(position: pos, anchor: Anchor.center);

  TextPainter? _tp;

  @override
  void render(Canvas canvas) {
    final opacity = (1.0 - (life / maxLife)).clamp(0.0, 1.0);
    final scale = 1.0 + life * 0.2;

    _tp ??= TextPainter(textDirection: TextDirection.ltr);
    _tp!.text = TextSpan(
      text: text,
      style: TextStyle(
        color: color.withAlpha((opacity * 255).round()),
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: Colors.black.withAlpha((opacity * 0.5 * 255).round()),
            blurRadius: 4,
            offset: const Offset(1, 1),
          ),
        ],
      ),
    );
    
    _tp!.layout();
    
    canvas.save();
    canvas.translate(0, 0); // already centered by position
    canvas.scale(scale);
    _tp!.paint(canvas, Offset(-_tp!.width / 2, -_tp!.height / 2));
    canvas.restore();
  }

  @override
  void update(double dt) {
    super.update(dt);
    life += dt;
    position.y -= 50 * dt;
    if (life >= maxLife) {
      removeFromParent();
    }
  }
}
