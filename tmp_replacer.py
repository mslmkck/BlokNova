import re

def update_file():
    with open('c:/Users/muslu/blok/lib/game/tower_game.dart', 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Update ParticleBurst constructor
    content = content.replace('''  ParticleBurst({
    required this.color,
    this.count = 12,
    required Vector2 position,
  }) : super(position: position);''', '''  ParticleBurst({
    required this.color,
    this.count = 12,
    this.activeSkin = 'default',
    required Vector2 position,
  }) : super(position: position);''')

    content = content.replace('''  final int count;
  final List<_Particle> _particles = [];''', '''  final int count;
  final String activeSkin;
  final List<_Particle> _particles = [];''')

    # 2. Update ParticleBurst render
    content = content.replace('''  @override
  void render(Canvas canvas) {
    final opacity = (1.0 - (life / maxLife)).clamp(0.0, 1.0);
    final paint = Paint()..color = color.withAlpha((opacity * 255).round());
    for (final p in _particles) {
      canvas.drawCircle(Offset(p.x, p.y), p.size * opacity, paint);
    }
  }''', '''  @override
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
  }''')

    # 3. Update GameBlock constructor
    content = content.replace('''  double bounceTime = 0;
  bool isBouncing = false;

  GameBlock({
    required this.blockWidth,
    required this.blockHeight,
    required this.colorIndex,
    required this.level,
    required this.moveSpeed,
    super.position,
  }) : super(''', '''  double bounceTime = 0;
  bool isBouncing = false;
  String activeSkin;

  GameBlock({
    required this.blockWidth,
    required this.blockHeight,
    required this.colorIndex,
    required this.level,
    required this.moveSpeed,
    required this.activeSkin,
    super.position,
  }) : super(''')

    # 4. Update GameBlock render
    content = content.replace('''  @override
  void render(Canvas canvas) {
    final baseColor = AppColors.blockColors[colorIndex % AppColors.blockColors.length];

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withAlpha(60)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(3, 3), width: blockWidth, height: blockHeight),
        const Radius.circular(6),
      ),
      shadowPaint,
    );

    // Main body
    final paint = Paint()..color = baseColor;
    final rect = Rect.fromCenter(center: Offset.zero, width: blockWidth, height: blockHeight);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      paint,
    );

    // Top highlight
    final highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withAlpha(90),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(-blockWidth / 2, -blockHeight / 2, blockWidth, blockHeight / 2));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-blockWidth / 2 + 3, -blockHeight / 2 + 2, blockWidth - 6, blockHeight / 2 - 2),
        const Radius.circular(4),
      ),
      highlightPaint,
    );

    // Bottom edge (3D effect)
    final edgePaint = Paint()..color = baseColor.withAlpha(150);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-blockWidth / 2, blockHeight / 2 - 4, blockWidth, 4),
        const Radius.circular(2),
      ),
      edgePaint,
    );

    // Border glow for moving block
    if (state == BlockState.moving) {
      final glowPaint = Paint()
        ..color = baseColor.withAlpha(100)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        glowPaint,
      );
    }
  }''', '''  @override
  void render(Canvas canvas) {
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

    final rect = Rect.fromCenter(center: Offset.zero, width: blockWidth, height: blockHeight);
    
    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withAlpha(60)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.translate(3, 3),
        const Radius.circular(6),
      ),
      shadowPaint,
    );

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
      canvas.drawRect(Rect.fromLTWH(-blockWidth/2, 0, blockWidth, 4), scanline);

    } else if (activeSkin == 'ice') {
      final paint = Paint()..color = baseColor.withAlpha(180);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(0)), paint);
      
      final topFrost = Paint()
        ..color = Colors.white.withAlpha(200);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-blockWidth/2, -blockHeight/2, blockWidth, 6), const Radius.circular(0)), topFrost);
      
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
        ).createShader(Rect.fromLTWH(-blockWidth / 2, -blockHeight / 2, blockWidth, blockHeight / 2));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-blockWidth / 2 + 3, -blockHeight / 2 + 2, blockWidth - 6, blockHeight / 2 - 2),
          const Radius.circular(4),
        ),
        highlightPaint,
      );

      final edgePaint = Paint()..color = baseColor.withAlpha(150);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-blockWidth / 2, blockHeight / 2 - 4, blockWidth, 4),
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
  }''')

    # 5. Update FallingPiece class
    content = content.replace('''class FallingPiece extends PositionComponent {
  final double pieceWidth;
  final double pieceHeight;
  final Color color;
  double fallVelocity = 0;
  double rotation = 0;
  double rotSpeed;

  FallingPiece({
    required this.pieceWidth,
    required this.pieceHeight,
    required this.color,
    required this.rotSpeed,
    required Vector2 position,
  }) : super(position: position, anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.rotate(rotation);
    final paint = Paint()..color = color.withAlpha(180);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: pieceWidth, height: pieceHeight),
        const Radius.circular(4),
      ),
      paint,
    );
    canvas.restore();
  }

  @override
  void update(double dt) {
    super.update(dt);
    fallVelocity += 800 * dt;
    position.y += fallVelocity * dt;
    rotation += rotSpeed * dt;
    if (position.y > 1000) {
      removeFromParent();
    }
  }
}''', '''class FallingPiece extends PositionComponent {
  final double pieceWidth;
  final double pieceHeight;
  final Color color;
  double fallVelocity = -200; // Kickback bounce
  double rotation = 0;
  double rotSpeed;
  final String activeSkin;

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
    fallVelocity += 1100 * dt; // gravity
    position.y += fallVelocity * dt;
    position.x += (rotSpeed * 25) * dt; // lateral momentum
    rotation += rotSpeed * dt;
    if (position.y > 1000) {
      removeFromParent();
    }
  }
}''')

    # 6. Injection into _spawnNewBlock
    content = content.replace('''    currentBlock = GameBlock(
      blockWidth: spawnWidth,
      blockHeight: currentLevelConfig!.blockHeight,
      colorIndex: currentLevelConfig!.colorIndex,
      level: currentLevel,
      moveSpeed: currentLevelConfig!.moveSpeed,
      position: Vector2(gameWidth / 2, spawnY),
    );''', '''    currentBlock = GameBlock(
      blockWidth: spawnWidth,
      blockHeight: currentLevelConfig!.blockHeight,
      colorIndex: currentLevelConfig!.colorIndex,
      level: currentLevel,
      moveSpeed: currentLevelConfig!.moveSpeed,
      activeSkin: providerContainer.read(playerStatsProvider).activeSkin,
      position: Vector2(gameWidth / 2, spawnY),
    );''')

    # 7. Update ParticleBurst creations
    content = content.replace('''world.add(ParticleBurst(
            color: Colors.white,
            count: 30,
            position: block.position.clone(),
          ));''', '''world.add(ParticleBurst(
            color: Colors.white,
            count: 30,
            activeSkin: block.activeSkin,
            position: block.position.clone(),
          ));''')

    content = content.replace('''world.add(ParticleBurst(
        color: AppColors.success,
        count: 20,
        position: block.position.clone(),
      ));''', '''world.add(ParticleBurst(
        color: AppColors.success,
        count: 20,
        activeSkin: block.activeSkin,
        position: block.position.clone(),
      ));''')

    content = content.replace('''world.add(ParticleBurst(
          color: AppColors.warning,
          count: 8,
          position: Vector2(overhangX, block.position.y),
        ));''', '''world.add(ParticleBurst(
          color: AppColors.warning,
          count: 8,
          activeSkin: block.activeSkin,
          position: Vector2(overhangX, block.position.y),
        ));''')

    content = content.replace('''world.add(ParticleBurst(
          color: AppColors.error,
          count: 6,
          position: Vector2(overhangX, block.position.y),
        ));''', '''world.add(ParticleBurst(
          color: AppColors.error,
          count: 6,
          activeSkin: block.activeSkin,
          position: Vector2(overhangX, block.position.y),
        ));''')

    # 8. Update FallingPiece creations
    content = content.replace('''world.add(FallingPiece(
        pieceWidth: overhangWidth,
        pieceHeight: block.blockHeight,
        color: AppColors.blockColors[block.colorIndex % AppColors.blockColors.length],
        rotSpeed: (overhangOnRight ? 1 : -1) * (2 + _random.nextDouble() * 3),
        position: Vector2(overhangX, block.position.y),
      ));''', '''world.add(FallingPiece(
        pieceWidth: overhangWidth,
        pieceHeight: block.blockHeight,
        color: AppColors.blockColors[block.colorIndex % AppColors.blockColors.length],
        rotSpeed: (overhangOnRight ? 1 : -1) * (2 + _random.nextDouble() * 3),
        activeSkin: block.activeSkin,
        position: Vector2(overhangX, block.position.y),
      ));''')

    content = content.replace('''world.add(FallingPiece(
      pieceWidth: block.blockWidth,
      pieceHeight: block.blockHeight,
      color: AppColors.blockColors[block.colorIndex % AppColors.blockColors.length],
      rotSpeed: (_random.nextBool() ? 1 : -1) * (3 + _random.nextDouble() * 4),
      position: block.position.clone(),
    ));''', '''world.add(FallingPiece(
      pieceWidth: block.blockWidth,
      pieceHeight: block.blockHeight,
      color: AppColors.blockColors[block.colorIndex % AppColors.blockColors.length],
      rotSpeed: (_random.nextBool() ? 1 : -1) * (3 + _random.nextDouble() * 4),
      activeSkin: block.activeSkin,
      position: block.position.clone(),
    ));''')

    with open('c:/Users/muslu/blok/lib/game/tower_game.dart', 'w', encoding='utf-8') as f:
        f.write(content)
        
    print("Replacements complete")

update_file()
