import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/player_stats.dart';

class StorageService {
  static const String _statsKey = 'player_stats';
  static const String _settingsKey = 'game_settings';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<PlayerStats> loadStats() async {
    final String? data = _prefs.getString(_statsKey);
    if (data == null) return PlayerStats(lastQuestReset: DateTime.now());
    return PlayerStats.fromJson(jsonDecode(data));
  }

  Future<void> saveStats(PlayerStats stats) async {
    await _prefs.setString(_statsKey, jsonEncode(stats.toJson()));
  }

  Future<void> updateStatsAfterGame({
    required int score,
    required int level,
    required int perfectCount,
    required int maxCombo,
    required PlacementQuality lastPlacement,
  }) async {
    final currentStats = await loadStats();
    
    final newRecentScores = [...currentStats.recentScores, score];
    if (newRecentScores.length > 10) {
      newRecentScores.removeAt(0);
    }

    final updatedStats = currentStats.copyWith(
      highScore: score > currentStats.highScore ? score : null,
      highestLevel: level > currentStats.highestLevel ? level : null,
      totalScore: currentStats.totalScore + score,
      gamesPlayed: currentStats.gamesPlayed + 1,
      perfectPlacements: currentStats.perfectPlacements + perfectCount,
      totalCombo: currentStats.totalCombo + maxCombo,
      recentScores: newRecentScores,
    );

    await saveStats(updatedStats);
  }

  Future<Map<String, dynamic>> loadSettings() async {
    final String? data = _prefs.getString(_settingsKey);
    if (data == null) {
      return {
        'soundEnabled': true,
        'vibrationEnabled': true,
        'musicEnabled': true,
        'weatherEffectsEnabled': true,
      };
    }
    return jsonDecode(data);
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _prefs.setString(_settingsKey, jsonEncode(settings));
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  Future<void> resetStats() async {
    await _prefs.remove(_statsKey);
  }
}
