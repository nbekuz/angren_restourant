import 'dart:async';

import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class OrderAlertService {
  OrderAlertService._();

  static Timer? _pulseTimer;

  static Future<void> startIncomingAlert() async {
    await WakelockPlus.enable();
    await _pulse();
    _pulseTimer?.cancel();
    _pulseTimer = Timer.periodic(const Duration(seconds: 2), (_) => _pulse());
  }

  static Future<void> stopIncomingAlert() async {
    _pulseTimer?.cancel();
    _pulseTimer = null;
    await WakelockPlus.disable();
    try {
      await Vibration.cancel();
    } catch (_) {
      // Some platforms do not expose vibration cancellation.
    }
  }

  static Future<void> _pulse() async {
    HapticFeedback.heavyImpact();
    unawaited(SystemSound.play(SystemSoundType.alert));

    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.vibrate(pattern: [0, 450, 160, 450, 160, 650]);
      }
    } catch (_) {
      HapticFeedback.vibrate();
    }
  }
}
