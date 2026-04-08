import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class DynamicSkyBackground extends PositionComponent {
  final Random _rng = Random(42);
  final List<_Star> _stars = [];
  final List<_Cloud> _clouds = [];

  double _time = 0;
  int currentLevel = 1;

  DynamicSkyBackground() {
    for (int i = 0; i < 80; i++) {
      _stars.add(_Star(
        x: _rng.nextDouble() * 360,
        y: _rng.nextDouble() * 1200 - 600,
        size: 0.5 + _rng.nextDouble() * 2.0,
        twinkleSpeed: 1 + _rng.nextDouble() * 3,
        twinkleOffset: _rng.nextDouble() * pi * 2,
      ));
    }
    for (int i = 0; i < 6; i++) {
      _clouds.add(_Cloud(
        x: _rng.nextDouble() * 360,
        y: _rng.nextDouble() * 600 - 400,
        speed: 5 + _rng.nextDouble() * 10,
        scale: 0.8 + _rng.nextDouble() * 0.7,
      ));
    }
  }

  void updateLevel(int level) {
    currentLevel = level;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;

    for (var cloud in _clouds) {
      cloud.x += cloud.speed * dt;
      if (cloud.x > 360 + 100) {
        cloud.x = -150;
        cloud.y = _rng.nextDouble() * 600 - 400;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    Color topColor;
    Color bottomColor;
    Color cloudColor;
    double starOpacityMultiplier = 0.0;

    switch (currentLevel) {
      case 1: // Dawn (Light Blue / Sunrise)
        topColor = const Color(0xFF4A90E2);
        bottomColor = const Color(0xFFFFDAB9);
        cloudColor = Colors.white.withAlpha(200);
        starOpacityMultiplier = 0.0;
        break;
      case 2: // Mid Day (Bright Blue)
        topColor = const Color(0xFF1E90FF);
        bottomColor = const Color(0xFF87CEFA);
        cloudColor = Colors.white;
        starOpacityMultiplier = 0.0;
        break;
      case 3: // Afternoon (Deep Blue / Yellow)
        topColor = const Color(0xFF005C97);
        bottomColor = const Color(0xFF363795);
        cloudColor = Colors.white70;
        starOpacityMultiplier = 0.1;
        break;
      case 4: // Sunset (Orange / Pink)
        topColor = const Color(0xFF8E2DE2);
        bottomColor = const Color(0xFF4A00E0);
        cloudColor = const Color(0xFFFFB6C1).withAlpha(200);
        starOpacityMultiplier = 0.3;
        break;
      case 5: // Twilight (Dark Purple / Redish)
        topColor = const Color(0xFF2B0A3D);
        bottomColor = const Color(0xFFE94057);
        cloudColor = const Color(0xFF4A00E0).withAlpha(150);
        starOpacityMultiplier = 0.5;
        break;
      case 6: // Night (Navy)
        topColor = const Color(0xFF1A1A40);
        bottomColor = const Color(0xFF0D0D1A);
        cloudColor = const Color(0xFF2B0A3D).withAlpha(100);
        starOpacityMultiplier = 0.8;
        break;
      case 7: // Interstellar (Purple Nebula)
        topColor = const Color(0xFF0F0C29);
        bottomColor = const Color(0xFF302B63);
        cloudColor = const Color(0xFF24243E).withAlpha(120);
        starOpacityMultiplier = 1.0;
        break;
      case 8: // Blood Moon / Crimson (Deep Red/Black)
        topColor = const Color(0xFF2C0707);
        bottomColor = const Color(0xFF8B0000);
        cloudColor = const Color(0xFF1A0000).withAlpha(180);
        starOpacityMultiplier = 1.0;
        break;
      case 9: // Golden / Mythic
      default:
        topColor = const Color(0xFFB8860B);
        bottomColor = const Color(0xFFD2B48C);
        cloudColor = const Color(0xFFFFF8DC).withAlpha(200);
        starOpacityMultiplier = 0.2;
        break;
    }

    final rect = Rect.fromLTWH(0, -600, 360, 1500);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [topColor, bottomColor],
      ).createShader(rect);

    canvas.drawRect(rect, paint);

    // Draw stars
    if (starOpacityMultiplier > 0) {
      for (final star in _stars) {
        final brightness = (0.3 + 0.7 * ((sin(_time * star.twinkleSpeed + star.twinkleOffset) + 1) / 2)).clamp(0.0, 1.0);
        final starPaint = Paint()..color = Colors.white.withAlpha((brightness * 200 * starOpacityMultiplier).round());
        canvas.drawCircle(Offset(star.x, star.y), star.size, starPaint);
      }
    }

    // Draw clouds
    for (final cloud in _clouds) {
      _drawCloud(canvas, cloud, cloudColor);
    }
  }

  void _drawCloud(Canvas canvas, _Cloud cloud, Color color) {
    canvas.save();
    canvas.translate(cloud.x, cloud.y);
    canvas.scale(cloud.scale);

    final paint = Paint()
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8); // Soften clouds
      
    // Draw horizontal pill-shaped clouds rather than giant overlapping circles
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-50, 0, 100, 20), const Radius.circular(10)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-25, -10, 70, 20), const Radius.circular(10)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-10, -20, 40, 15), const Radius.circular(8)), paint);

    canvas.restore();
  }
}

class _Star {
  final double x, y, size, twinkleSpeed, twinkleOffset;
  _Star({required this.x, required this.y, required this.size, required this.twinkleSpeed, required this.twinkleOffset});
}

class _Cloud {
  double x, y, speed, scale;
  _Cloud({required this.x, required this.y, required this.speed, required this.scale});
}
