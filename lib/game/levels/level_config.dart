import 'dart:convert';
import 'dart:math';

class LevelConfig {
  final int level;
  final double blockWidth;
  final double blockHeight;
  final double moveSpeed;
  final double gravity;
  final int colorIndex;

  const LevelConfig({
    required this.level,
    required this.blockWidth,
    required this.blockHeight,
    required this.moveSpeed,
    required this.gravity,
    required this.colorIndex,
  });

  Map<String, dynamic> toJson() => {
    'level': level,
    'blockWidth': blockWidth,
    'blockHeight': blockHeight,
    'moveSpeed': moveSpeed,
    'gravity': gravity,
    'colorIndex': colorIndex,
  };

  factory LevelConfig.fromJson(Map<String, dynamic> json) => LevelConfig(
    level: json['level'],
    blockWidth: json['blockWidth'],
    blockHeight: json['blockHeight'],
    moveSpeed: json['moveSpeed'],
    gravity: json['gravity'],
    colorIndex: json['colorIndex'],
  );

  static String encode(List<LevelConfig> levels) =>
    jsonEncode(levels.map((l) => l.toJson()).toList());

  static List<LevelConfig> decode(String source) =>
    (jsonDecode(source) as List)
      .map((item) => LevelConfig.fromJson(item))
      .toList();
}

class LevelManager {
  static LevelConfig _generateLevel(int level) {
    // Infinite Progression Formulas
    // Width starts at 160, drops to 30 over 50 levels (logarithmic decay)
    double baseWidth = 160.0 - (log(level) * 35.0);
    baseWidth = baseWidth.clamp(30.0, 200.0);

    // Speed starts at 150, increases gradually
    // Formula: 150 + (level * 10) + log(level)*50
    double baseSpeed = 150.0 + (level * 12.0) + (log(level) * 40.0);
    
    // Gravity scales to maintain physics feel
    double baseGravity = 800.0 + (level * 50.0);

    return LevelConfig(
      level: level,
      blockWidth: baseWidth,
      blockHeight: 28.0,
      moveSpeed: baseSpeed.clamp(100.0, 1000.0), // Cap at 1000 for playability
      gravity: baseGravity.clamp(300.0, 4000.0),
      colorIndex: (level - 1) % 8,
    );
  }

  static LevelConfig getLevel(int level) {
    return _generateLevel(level);
  }

  static int getTier(int level) {
    if (level <= 5) return 1;
    if (level <= 15) return 2;
    if (level <= 30) return 3;
    if (level <= 50) return 4;
    return 5;
  }

  static String getTierName(int level) {
    final tier = getTier(level);
    switch (tier) {
      case 1: return 'ÇAYLAK';
      case 2: return 'USTA';
      case 3: return 'KRAL';
      case 4: return 'EFSANE';
      case 5: return 'YÜCE';
      default: return 'GİZEMLİ';
    }
  }

  // Calculate how many blocks needed to pass a specific level
  static int getBlocksRequiredForLevel(int level) {
    // Scaled requirement
    if (level <= 5) return 8;
    if (level <= 15) return 12;
    return 15;
  }
}
