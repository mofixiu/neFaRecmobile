import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Target alerts for the timer: a scheduled local notification for when the
/// app is in the background, and haptics while it is open.
class AlertService {
  AlertService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;
  bool hapticsEnabled = true;

  static const _timerId = 7001;

  Future<void> init() async {
    if (_ready || kIsWeb) return;
    try {
      tzdata.initializeTimeZones();
      await _plugin.initialize(
        settings: const InitializationSettings(
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestSoundPermission: false,
            requestBadgePermission: false,
          ),
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );
      _ready = true;
    } catch (e) {
      debugPrint('alerts unavailable: $e');
    }
  }

  /// Asked the first time you start a timer, not at launch.
  Future<void> requestPermission() async {
    if (!_ready) return;
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, sound: true);
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleTarget(DateTime at, {required String title, required String body}) async {
    if (!_ready) return;
    await cancelTarget();
    if (!at.isAfter(DateTime.now())) return;
    try {
      await _plugin.zonedSchedule(
        id: _timerId,
        scheduledDate: tz.TZDateTime.from(at.toUtc(), tz.UTC),
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          iOS: DarwinNotificationDetails(
            presentAlert: false,
            presentSound: false,
            interruptionLevel: InterruptionLevel.timeSensitive,
          ),
          android: AndroidNotificationDetails(
            'timer',
            'Timer alerts',
            channelDescription: 'Tells you when a rest or hold reaches its target.',
            importance: Importance.high,
            priority: Priority.high,
            category: AndroidNotificationCategory.alarm,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('could not schedule timer alert: $e');
    }
  }

  Future<void> cancelTarget() async {
    if (!_ready) return;
    try {
      await _plugin.cancel(id: _timerId);
    } catch (_) {}
  }

  // Haptics. The light tap is for ordinary taps, the tick for selections,
  // heavy for commits; the target pattern is felt through a pocket.

  void tap() {
    if (hapticsEnabled) HapticFeedback.lightImpact();
  }

  void tick() {
    if (hapticsEnabled) HapticFeedback.selectionClick();
  }

  void commit() {
    if (hapticsEnabled) HapticFeedback.mediumImpact();
  }

  Future<void> targetReached() async {
    if (!hapticsEnabled) return;
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 140));
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 140));
    await HapticFeedback.mediumImpact();
  }
}
