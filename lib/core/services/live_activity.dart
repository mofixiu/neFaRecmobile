import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The timer on the lock screen and in the Dynamic Island (iOS 16.2+).
/// It counts down and then into overtime on its own, so it only needs an
/// update when the timer is started, adjusted, paused or stopped.
class LiveActivityService {
  const LiveActivityService();

  static const _channel = MethodChannel('nefarec/live');

  Future<void> show({
    required String label,
    required String kind,
    required DateTime startedAt,
    required DateTime targetAt,
    required Duration target,
    Duration? pausedElapsed,
    String workout = 'neFaRec',
  }) async {
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod('show', {
        'label': label,
        'kind': kind,
        'workout': workout,
        'startedAt': startedAt.millisecondsSinceEpoch.toDouble(),
        'targetAt': targetAt.millisecondsSinceEpoch.toDouble(),
        'targetSeconds': target.inMilliseconds / 1000,
        'pausedElapsed': pausedElapsed == null ? null : pausedElapsed.inMilliseconds / 1000,
      });
    } catch (e) {
      // Live Activities can be off in Settings; the in-app timer still works.
      debugPrint('live activity unavailable: $e');
    }
  }

  Future<void> end() async {
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod('end');
    } catch (_) {}
  }
}
