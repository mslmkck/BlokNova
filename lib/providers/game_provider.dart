import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/player_stats.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../services/haptic_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

final hapticServiceProvider = Provider<HapticService>((ref) {
  return HapticService();
});

final playerStatsProvider = StateNotifierProvider<PlayerStatsNotifier, PlayerStats>((ref) {
  return PlayerStatsNotifier(ref.watch(storageServiceProvider));
});

class PlayerStatsNotifier extends StateNotifier<PlayerStats> {
  final StorageService _storage;

  PlayerStatsNotifier(this._storage) : super(PlayerStats(lastQuestReset: DateTime.now().subtract(const Duration(days: 1)))) {
    _loadStats();
  }

  Future<void> _loadStats() async {
    state = await _storage.loadStats();
    _initBadgesIfEmpty();
    await checkAndResetQuests();
  }

  void _initBadgesIfEmpty() {
    if (state.badges.isNotEmpty) return;

    final initialBadges = [
      AchievementBadge(id: 'score_100', title: 'Çırak Mimar', description: '100 skora ulaş', iconName: 'architecture', goal: 100),
      AchievementBadge(id: 'score_500', title: 'Usta İnşaatçı', description: '500 skora ulaş', iconName: 'construction', goal: 500),
      AchievementBadge(id: 'level_10', title: 'Yüksekten Bakış', description: 'Seviye 10\'a ulaş', iconName: 'height', goal: 10),
      AchievementBadge(id: 'combo_10', title: 'Odaklanmış', description: '10 kombo yap', iconName: 'center_focus_strong', goal: 10),
      AchievementBadge(id: 'games_50', title: 'Kıdemli Oyuncu', description: '50 oyun oyna', iconName: 'military_tech', goal: 50),
      AchievementBadge(id: 'perfect_100', title: 'Kusursuz', description: 'Toplam 100 mükemmel yerleştirme yap', iconName: 'stars', goal: 100),
    ];

    state = state.copyWith(badges: initialBadges);
  }

  Future<void> checkAndResetQuests() async {
    final now = DateTime.now();
    final lastReset = state.lastQuestReset;
    
    // Check if it's a new day
    if (now.day != lastReset.day || now.month != lastReset.month || now.year != lastReset.year) {
      final newQuests = [
        const Quest(id: 'perfects', title: '20 Tane Mükemmel Yap', goal: 20, rewardCoins: 100),
        const Quest(id: 'level15', title: 'Seviye 15\'e Ulaş', goal: 15, rewardCoins: 150),
        const Quest(id: 'games', title: '3 Oyun Oyna', goal: 3, rewardCoins: 50),
      ];
      
      state = state.copyWith(
        dailyQuests: newQuests,
        lastQuestReset: now,
      );
      await _storage.saveStats(state);
    }
  }

  Future<void> updateQuestProgress(String id, int amount, {bool isSet = false}) async {
    final quests = List<Quest>.from(state.dailyQuests);
    final index = quests.indexWhere((q) => q.id == id);
    
    if (index != -1 && !quests[index].isClaimed) {
      final oldQuest = quests[index];
      final newProgress = isSet ? amount : oldQuest.progress + amount;
      quests[index] = oldQuest.copyWith(progress: newProgress.clamp(0, oldQuest.goal));
      
      state = state.copyWith(dailyQuests: quests);
      await _storage.saveStats(state);
    }
  }

  Future<void> addCoins(int amount) async {
    state = state.copyWith(coins: state.coins + amount);
    await _storage.saveStats(state);
  }

  Future<bool> claimQuestReward(String id) async {
    final quests = List<Quest>.from(state.dailyQuests);
    final index = quests.indexWhere((q) => q.id == id);
    
    if (index != -1 && quests[index].isCompleted && !quests[index].isClaimed) {
      final quest = quests[index];
      quests[index] = quest.copyWith(isClaimed: true);
      
      state = state.copyWith(
        dailyQuests: quests,
        coins: state.coins + quest.rewardCoins,
      );
      await _storage.saveStats(state);
      return true;
    }
    return false;
  }

  Future<void> acceptPrivacy() async {
    state = state.copyWith(privacyAccepted: true);
    await _storage.saveStats(state);
  }

  Future<void> updateAfterGame({
    required int score,
    required int level,
    required int perfectCount,
    required int maxCombo,
    required PlacementQuality lastPlacement,
  }) async {
    final newRecentScores = [...state.recentScores, score];
    if (newRecentScores.length > 10) {
      newRecentScores.removeAt(0);
    }

    // Balanced Economy: Reduced from /10 to /25 for score, and perfect bonus reduced
    final earnedCoins = (score / 25).round() + (perfectCount * 1);

    state = state.copyWith(
      highScore: score > state.highScore ? score : null,
      highestLevel: level > state.highestLevel ? level : null,
      totalScore: state.totalScore + score,
      gamesPlayed: state.gamesPlayed + 1,
      perfectPlacements: state.perfectPlacements + perfectCount,
      totalCombo: state.totalCombo + maxCombo,
      recentScores: newRecentScores,
      coins: state.coins + earnedCoins,
    );

    _updateBadgesProgress(score, level, maxCombo);

    await updateQuestProgress('perfects', perfectCount);
    await updateQuestProgress('level15', level, isSet: true);
    await updateQuestProgress('games', 1);

    await _storage.saveStats(state);
    return;
  }

  void _updateBadgesProgress(int score, int level, int maxCombo) {
    final updatedBadges = state.badges.map((badge) {
      if (badge.isUnlocked) return badge;

      int newProgress = badge.progress;
      switch (badge.id) {
        case 'score_100':
        case 'score_500':
          if (score > newProgress) newProgress = score;
          break;
        case 'level_10':
          if (level > newProgress) newProgress = level;
          break;
        case 'combo_10':
          if (maxCombo > newProgress) newProgress = maxCombo;
          break;
        case 'games_50':
          newProgress = state.gamesPlayed;
          break;
        case 'perfect_100':
          newProgress = state.perfectPlacements;
          break;
      }

      bool unlocked = newProgress >= badge.goal;
      return badge.copyWith(
        progress: newProgress,
        isUnlocked: unlocked,
        unlockDate: unlocked ? DateTime.now() : null,
      );
    }).toList();

    state = state.copyWith(badges: updatedBadges);
  }

  int getLastEarnedCoins(int score, int perfectCount) {
    return (score / 10).round() + (perfectCount * 2);
  }

  Future<bool> buySkin(String skinId, int price) async {
    if (state.coins < price) return false;
    if (state.unlockedSkins.contains(skinId)) return false;

    state = state.copyWith(
      coins: state.coins - price,
      unlockedSkins: [...state.unlockedSkins, skinId],
    );
    await _storage.saveStats(state);
    return true;
  }
  Future<void> equipSkin(String skinId) async {
    if (!state.unlockedSkins.contains(skinId)) return;
    state = state.copyWith(activeSkin: skinId);
    await _storage.saveStats(state);
  }

  Future<bool> buyTheme(String themeId, int price) async {
    if (state.coins < price) return false;
    if (state.unlockedThemes.contains(themeId)) return false;

    state = state.copyWith(
      coins: state.coins - price,
      unlockedThemes: [...state.unlockedThemes, themeId],
    );
    await _storage.saveStats(state);
    return true;
  }

  Future<void> equipTheme(String themeId) async {
    if (!state.unlockedThemes.contains(themeId)) return;
    state = state.copyWith(activeTheme: themeId);
    await _storage.saveStats(state);
  }

  Future<bool> buyPowerUp(String type, int price) async {
    if (state.coins < price) return false;
    
    PlayerStats newState = state.copyWith(coins: state.coins - price);
    
    if (type == 'slowMo') {
      newState = newState.copyWith(slowMoCount: state.slowMoCount + 1);
    } else if (type == 'expand') {
      newState = newState.copyWith(expandCount: state.expandCount + 1);
    } else if (type == 'magnet') {
      newState = newState.copyWith(magnetCount: state.magnetCount + 1);
    }
    
    state = newState;
    await _storage.saveStats(state);
    return true;
  }

  Future<bool> usePowerUp(String type) async {
    PlayerStats? newState;
    
    if (type == 'slowMo' && state.slowMoCount > 0) {
      newState = state.copyWith(slowMoCount: state.slowMoCount - 1);
    } else if (type == 'expand' && state.expandCount > 0) {
      newState = state.copyWith(expandCount: state.expandCount - 1);
    } else if (type == 'magnet' && state.magnetCount > 0) {
      newState = state.copyWith(magnetCount: state.magnetCount - 1);
    }
    
    if (newState != null) {
      state = newState;
      await _storage.saveStats(state);
      return true;
    }
    return false;
  }

  Future<void> reset() async {
    await _storage.resetStats();
    state = PlayerStats(lastQuestReset: DateTime.now());
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, Map<String, bool>>((ref) {
  return SettingsNotifier(ref.watch(storageServiceProvider));
});

class SettingsNotifier extends StateNotifier<Map<String, bool>> {
  final StorageService _storage;

  SettingsNotifier(this._storage) : super({
    'soundEnabled': true,
    'vibrationEnabled': true,
    'musicEnabled': true,
    'weatherEffectsEnabled': true,
    'privacyAccepted': false,
  }) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _storage.loadSettings();
    state = settings.map((key, value) => MapEntry(key, value as bool));
  }

  Future<void> setSoundEnabled(bool enabled) async {
    state = {...state, 'soundEnabled': enabled};
    await _storage.saveSettings(state);
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    state = {...state, 'vibrationEnabled': enabled};
    await _storage.saveSettings(state);
  }

  Future<void> setMusicEnabled(bool enabled) async {
    state = {...state, 'musicEnabled': enabled};
    await _storage.saveSettings(state);
  }

  Future<void> setWeatherEffectsEnabled(bool enabled) async {
    state = {...state, 'weatherEffectsEnabled': enabled};
    await _storage.saveSettings(state);
  }

  Future<void> setPrivacyAccepted(bool accepted) async {
    state = {...state, 'privacyAccepted': accepted};
    await _storage.saveSettings(state);
  }

  bool get isPrivacyAccepted => state['privacyAccepted'] ?? false;
}
