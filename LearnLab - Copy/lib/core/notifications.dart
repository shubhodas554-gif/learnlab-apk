import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> initNotifications(FlutterLocalNotificationsPlugin plugin) async {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.local);
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings = InitializationSettings(android: android);
  await plugin.initialize(settings);
}

Future<void> scheduleDailyReminder(
  FlutterLocalNotificationsPlugin plugin, {
  required int hour,
  required int minute,
}) async {
  const details = NotificationDetails(
    android: AndroidNotificationDetails(
      'learnlab_daily',
      'Daily Learning',
      channelDescription: 'Reminds learners to practice daily',
      importance: Importance.max,
      priority: Priority.high,
    ),
  );

  await plugin.zonedSchedule(
    1,
    'Time to learn!',
    'Keep your streak alive.',
    _nextInstance(hour, minute),
    details,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}

tz.TZDateTime _nextInstance(int hour, int minute) {
  final now = tz.TZDateTime.now(tz.local);
  var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
  if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));
  return scheduled;
}