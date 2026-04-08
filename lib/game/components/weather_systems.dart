import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum WeatherType { none, snow, wind, fog }

class WeatherSystem extends PositionComponent with HasGameReference {
  WeatherType type = WeatherType.none;
  final List<_WeatherParticle> _particles = [];
  final Random _rng = Random();
  bool isEnabled = true;

  void updateWeather(WeatherType newType) {
    if (type == newType) return;
    type = newType;
    _particles.clear();
    
    if (type == WeatherType.snow) {
      for (int i = 0; i < 100; i++) {
        _particles.add(_WeatherParticle(
          x: _rng.nextDouble() * 360,
          y: _rng.nextDouble() * 800 - 100,
          speed: 20 + _rng.nextDouble() * 40,
          size: 1 + _rng.nextDouble() * 2,
          drift: _rng.nextDouble() * 2 - 1,
        ));
      }
    } else if (type == WeatherType.wind) {
      for (int i = 0; i < 20; i++) {
        _particles.add(_WeatherParticle(
          x: _rng.nextDouble() * 360,
          y: _rng.nextDouble() * 800 - 100,
          speed: 400 + _rng.nextDouble() * 300,
          size: 40 + _rng.nextDouble() * 60, // length for wind lines
          drift: 0,
        ));
      }
    }
  }

  @override
  void update(double dt) {
    if (!isEnabled) return;
    super.update(dt);

    for (var p in _particles) {
      if (type == WeatherType.snow) {
        p.y += p.speed * dt;
        p.x += sin(p.y * 0.02) * p.drift * 20 * dt;
        if (p.y > 700) p.y = -10;
      } else if (type == WeatherType.wind) {
        p.x += p.speed * dt;
        if (p.x > 400) {
          p.x = -100;
          p.y = _rng.nextDouble() * 800 - 100;
        }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (!isEnabled || type == WeatherType.none) return;

    final paint = Paint()..color = Colors.white.withAlpha(type == WeatherType.snow ? 180 : 60);

    for (var p in _particles) {
      if (type == WeatherType.snow) {
        canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
      } else if (type == WeatherType.wind) {
        // Draw thin horizontal lines for wind
        final windPaint = Paint()
          ..color = Colors.white.withAlpha(40)
          ..strokeWidth = 1;
        canvas.drawLine(Offset(p.x, p.y), Offset(p.x + p.size, p.y), windPaint);
      }
    }
    
    if (type == WeatherType.fog) {
       final fogPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.white.withAlpha(80), Colors.transparent],
        ).createShader(const Rect.fromLTWH(0, 400, 360, 300));
       canvas.drawRect(const Rect.fromLTWH(0, 400, 360, 300), fogPaint);
    }
  }
}

class _WeatherParticle {
  double x, y, speed, size, drift;
  _WeatherParticle({required this.x, required this.y, required this.speed, required this.size, required this.drift});
}
