import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class HapticService {
  bool _enabled = true;

  bool get enabled => _enabled;

  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  Future<void> light() async {
    if (!_enabled) return;
    await HapticFeedback.lightImpact();
  }

  Future<void> medium() async {
    if (!_enabled) return;
    await HapticFeedback.mediumImpact();
  }

  Future<void> heavy() async {
    if (!_enabled) return;
    await HapticFeedback.heavyImpact();
  }

  Future<void> selection() async {
    if (!_enabled) return;
    await HapticFeedback.selectionClick();
  }

  Future<void> success() async {
    if (!_enabled) return;
    try {
      final bool hasVibrator = await Vibration.hasVibrator() == true;
      if (hasVibrator) {
        await Vibration.vibrate(pattern: [0, 50, 50, 50], intensities: [0, 128, 0, 255]);
      } else {
        await HapticFeedback.heavyImpact();
      }
    } catch (_) {
      await HapticFeedback.heavyImpact();
    }
  }

  Future<void> error() async {
    if (!_enabled) return;
    try {
      final bool hasVibrator = await Vibration.hasVibrator() == true;
      if (hasVibrator) {
        await Vibration.vibrate(pattern: [0, 100, 50, 100], intensities: [0, 255]);
      } else {
        await HapticFeedback.heavyImpact();
      }
    } catch (_) {
      await HapticFeedback.heavyImpact();
    }
  }

  Future<void> warning() async {
    if (!_enabled) return;
    try {
      final bool hasVibrator = await Vibration.hasVibrator() == true;
      if (hasVibrator) {
        await Vibration.vibrate(pattern: [0, 50], intensities: [0, 128]);
      } else {
        await HapticFeedback.mediumImpact();
      }
    } catch (_) {
      await HapticFeedback.mediumImpact();
    }
  }

  Future<void> perfect() async {
    if (!_enabled) return;
    try {
      final bool hasVibrator = await Vibration.hasVibrator() == true;
      if (hasVibrator) {
        await Vibration.vibrate(pattern: [0, 30, 30, 30, 30, 30], intensities: [0, 200, 0, 200]);
      } else {
        await HapticFeedback.lightImpact();
      }
    } catch (_) {
      await HapticFeedback.lightImpact();
    }
  }
}
