class PlayerStats {
  final int highScore;
  final int highestLevel;
  final int totalScore;
  final int gamesPlayed;
  final int perfectPlacements;
  final int totalCombo;
  final List<int> recentScores;
  
  // Economy & Skins
  final int coins;
  final List<String> unlockedSkins;
  final String activeSkin;
  
  // Themes
  final List<String> unlockedThemes;
  final String activeTheme;
  
  // Power-ups
  final int slowMoCount;
  final int expandCount;
  final int magnetCount;

  // Quests & Retention
  final List<Quest> dailyQuests;
  final DateTime lastQuestReset;
  
  // Privacy
  final bool privacyAccepted;

  // Badges
  final List<AchievementBadge> badges;

  const PlayerStats({
    this.highScore = 0,
    this.highestLevel = 1,
    this.totalScore = 0,
    this.gamesPlayed = 0,
    this.perfectPlacements = 0,
    this.totalCombo = 0,
    this.recentScores = const [],
    this.coins = 0,
    this.unlockedSkins = const ['default'],
    this.activeSkin = 'default',
    this.slowMoCount = 3,
    this.expandCount = 3,
    this.magnetCount = 3,
    this.dailyQuests = const [],
    required this.lastQuestReset,
    this.privacyAccepted = false,
    this.badges = const [],
    this.unlockedThemes = const ['default'],
    this.activeTheme = 'default',
  });

  double get averageScore {
    if (gamesPlayed == 0) return 0;
    return totalScore / gamesPlayed;
  }

  PlayerStats copyWith({
    int? highScore,
    int? highestLevel,
    int? totalScore,
    int? gamesPlayed,
    int? perfectPlacements,
    int? totalCombo,
    List<int>? recentScores,
    int? coins,
    List<String>? unlockedSkins,
    String? activeSkin,
    int? slowMoCount,
    int? expandCount,
    int? magnetCount,
    List<Quest>? dailyQuests,
    DateTime? lastQuestReset,
    bool? privacyAccepted,
    List<AchievementBadge>? badges,
    List<String>? unlockedThemes,
    String? activeTheme,
  }) {
    return PlayerStats(
      highScore: highScore ?? this.highScore,
      highestLevel: highestLevel ?? this.highestLevel,
      totalScore: totalScore ?? this.totalScore,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      perfectPlacements: perfectPlacements ?? this.perfectPlacements,
      totalCombo: totalCombo ?? this.totalCombo,
      recentScores: recentScores ?? this.recentScores,
      coins: coins ?? this.coins,
      unlockedSkins: unlockedSkins ?? this.unlockedSkins,
      activeSkin: activeSkin ?? this.activeSkin,
      slowMoCount: slowMoCount ?? this.slowMoCount,
      expandCount: expandCount ?? this.expandCount,
      magnetCount: magnetCount ?? this.magnetCount,
      dailyQuests: dailyQuests ?? this.dailyQuests,
      lastQuestReset: lastQuestReset ?? this.lastQuestReset,
      privacyAccepted: privacyAccepted ?? this.privacyAccepted,
      badges: badges ?? this.badges,
      unlockedThemes: unlockedThemes ?? this.unlockedThemes,
      activeTheme: activeTheme ?? this.activeTheme,
    );
  }

  Map<String, dynamic> toJson() => {
    'highScore': highScore,
    'highestLevel': highestLevel,
    'totalScore': totalScore,
    'gamesPlayed': gamesPlayed,
    'perfectPlacements': perfectPlacements,
    'totalCombo': totalCombo,
    'recentScores': recentScores,
    'coins': coins,
    'unlockedSkins': unlockedSkins,
    'activeSkin': activeSkin,
    'unlockedThemes': unlockedThemes,
    'activeTheme': activeTheme,
    'slowMoCount': slowMoCount,
    'expandCount': expandCount,
    'magnetCount': magnetCount,
    'dailyQuests': dailyQuests.map((q) => q.toJson()).toList(),
    'lastQuestReset': lastQuestReset.toIso8601String(),
    'privacyAccepted': privacyAccepted,
    'badges': badges.map((b) => b.toJson()).toList(),
  };

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      highScore: json['highScore'] ?? 0,
      highestLevel: json['highestLevel'] ?? 1,
      totalScore: json['totalScore'] ?? 0,
      gamesPlayed: json['gamesPlayed'] ?? 0,
      perfectPlacements: json['perfectPlacements'] ?? 0,
      totalCombo: json['totalCombo'] ?? 0,
      recentScores: List<int>.from(json['recentScores'] ?? []),
      coins: json['coins'] ?? 0,
      unlockedSkins: List<String>.from(json['unlockedSkins'] ?? ['default']),
      activeSkin: json['activeSkin'] ?? 'default',
      slowMoCount: json['slowMoCount'] ?? 3,
      expandCount: json['expandCount'] ?? 3,
      magnetCount: json['magnetCount'] ?? 3,
      dailyQuests: (json['dailyQuests'] as List?)?.map((q) => Quest.fromJson(q)).toList() ?? [],
      lastQuestReset: json['lastQuestReset'] != null ? DateTime.parse(json['lastQuestReset']) : DateTime.now().subtract(const Duration(days: 1)),
      privacyAccepted: json['privacyAccepted'] ?? false,
      badges: (json['badges'] as List?)?.map((b) => AchievementBadge.fromJson(b)).toList() ?? [],
      unlockedThemes: List<String>.from(json['unlockedThemes'] ?? ['default']),
      activeTheme: json['activeTheme'] ?? 'default',
    );
  }
}

class Quest {
  final String id;
  final String title;
  final int goal;
  final int progress;
  final int rewardCoins;
  final bool isClaimed;

  const Quest({
    required this.id,
    required this.title,
    required this.goal,
    this.progress = 0,
    required this.rewardCoins,
    this.isClaimed = false,
  });

  bool get isCompleted => progress >= goal;

  Quest copyWith({int? progress, bool? isClaimed}) {
    return Quest(
      id: id,
      title: title,
      goal: goal,
      progress: progress ?? this.progress,
      rewardCoins: rewardCoins,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'goal': goal,
    'progress': progress,
    'rewardCoins': rewardCoins,
    'isClaimed': isClaimed,
  };

  factory Quest.fromJson(Map<String, dynamic> json) => Quest(
    id: json['id'],
    title: json['title'],
    goal: json['goal'],
    progress: json['progress'],
    rewardCoins: json['rewardCoins'],
    isClaimed: json['isClaimed'] ?? false,
  );
}

enum PlacementQuality {
  perfect,
  good,
  miss,
}

class GameResult {
  final int score;
  final int level;
  final int blocksPlaced;
  final int perfectPlacements;
  final int maxCombo;
  final PlacementQuality lastPlacement;
  final DateTime timestamp;

  const GameResult({
    required this.score,
    required this.level,
    required this.blocksPlaced,
    required this.perfectPlacements,
    required this.maxCombo,
    required this.lastPlacement,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'score': score,
    'level': level,
    'blocksPlaced': blocksPlaced,
    'perfectPlacements': perfectPlacements,
    'maxCombo': maxCombo,
    'lastPlacement': lastPlacement.index,
    'timestamp': timestamp.toIso8601String(),
  };

  factory GameResult.fromJson(Map<String, dynamic> json) => GameResult(
    score: json['score'],
    level: json['level'],
    blocksPlaced: json['blocksPlaced'],
    perfectPlacements: json['perfectPlacements'],
    maxCombo: json['maxCombo'],
    lastPlacement: PlacementQuality.values[json['lastPlacement']],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

class AchievementBadge {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final bool isUnlocked;
  final int progress;
  final int goal;
  final DateTime? unlockDate;

  const AchievementBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    this.isUnlocked = false,
    this.progress = 0,
    required this.goal,
    this.unlockDate,
  });

  AchievementBadge copyWith({
    bool? isUnlocked,
    int? progress,
    DateTime? unlockDate,
  }) {
    return AchievementBadge(
      id: id,
      title: title,
      description: description,
      iconName: iconName,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      progress: progress ?? this.progress,
      goal: goal,
      unlockDate: unlockDate ?? this.unlockDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'iconName': iconName,
    'isUnlocked': isUnlocked,
    'progress': progress,
    'goal': goal,
    'unlockDate': unlockDate?.toIso8601String(),
  };

  factory AchievementBadge.fromJson(Map<String, dynamic> json) => AchievementBadge(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    iconName: json['iconName'],
    isUnlocked: json['isUnlocked'] ?? false,
    progress: json['progress'] ?? 0,
    goal: json['goal'] ?? 1,
    unlockDate: json['unlockDate'] != null ? DateTime.parse(json['unlockDate']) : null,
  );
}
