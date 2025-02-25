import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

// Top-level function to handle background notifications
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // Handle notification tap in background
}

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'task_reminders',
    'Task Reminders',
    description: 'Notifications for task reminders',
    importance: Importance.max,
    enableVibration: true,
    playSound: true,
    showBadge: true,
  );

  Future<void> init() async {
    tz.initializeTimeZones();

    if (Platform.isAndroid) {
      final androidPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      // Request notification permissions
      await androidPlugin?.requestNotificationsPermission();
      
      // Create notification channel
      await androidPlugin?.createNotificationChannel(channel);
    }

    await _notifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      ),
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Notification tapped: ${details.payload}');
      },
    );

    // Test immediate notification
    await showImmediateNotification(
      title: "Notification Test",
      body: "This is a test notification. If you see this, notifications are working!",
    );
  }

  Future<void> showImmediateNotification({
    required String title,
    required String body,
  }) async {
    try {
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.max,
            priority: Priority.max,
            enableLights: true,
            enableVibration: true,
            playSound: true,
            icon: '@mipmap/ic_launcher',
            channelShowBadge: true,
          ),
        ),
      );
      debugPrint('Immediate notification sent successfully');
    } catch (e) {
      debugPrint('Error showing immediate notification: $e');
      rethrow;
    }
  }

  Future<void> scheduleTaskNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      if (Platform.isAndroid) {
        final androidPlugin =
            _notifications.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        // Check for notification permission
        final hasPermission =
            await androidPlugin?.areNotificationsEnabled() ?? false;
        if (!hasPermission) {
          final granted =
              await androidPlugin?.requestNotificationsPermission() ?? false;
          if (!granted) {
            throw PlatformException(
              code: 'notification_permission_denied',
              message: 'Notification permissions are required for reminders',
            );
          }
        }

        // Check for exact alarm permission
        final hasExactAlarmPermission =
            await androidPlugin?.canScheduleExactNotifications() ?? false;
        if (!hasExactAlarmPermission) {
          await androidPlugin?.requestExactAlarmsPermission();
        }
      }

      // First send an immediate test notification
      await showImmediateNotification(
        title: "Scheduling Task Reminder",
        body: "Your reminder will be set for: ${scheduledDate.toString()}",
      );

      // Calculate the scheduled time
      final now = tz.TZDateTime.now(tz.local);
      var scheduledTime = tz.TZDateTime.from(scheduledDate, tz.local);
      
      // If the time is in the past, schedule for 30 seconds from now (for testing)
      if (scheduledTime.isBefore(now)) {
        scheduledTime = now.add(const Duration(seconds: 30));
        debugPrint('Scheduled time was in the past, rescheduling for 30 seconds from now');
      }

      debugPrint('Current time: ${now.toString()}');
      debugPrint('Scheduling notification for: ${scheduledTime.toString()}');

      // Schedule the actual notification
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        _nextInstanceOfTenAM(
          scheduledDate.hour, scheduledDate.minute,10, "", ""),
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.max,
            priority: Priority.max,
            enableLights: true,
            enableVibration: true,
            playSound: true,
            icon: '@mipmap/ic_launcher',
            channelShowBadge: true,
            fullScreenIntent: true,
            category: AndroidNotificationCategory.alarm,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint('Notification scheduled successfully');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      rethrow;
    }
  }

  
  tz.TZDateTime _nextInstanceOfTenAM(
      int hour, int minutes, int remained, String repeat, String date) {

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    print('time now: $now');

    DateTime formatDate = DateFormat.yMd().parse(date);
    final tz.TZDateTime fd = tz.TZDateTime.from(formatDate,tz.local);
    print('fd: $fd');

    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, fd.year,
        fd.month, fd.day, hour, minutes);
    print('scheduledDate: $scheduledDate');

    scheduledDate = _afterRemained(remained, scheduledDate);
    print('after back from remained scheduledDate 1: $scheduledDate');

    if (scheduledDate.isBefore(now)) {
      if (repeat == 'Daily') {
        scheduledDate = tz.TZDateTime(
            tz.local, now.year, now.month, (formatDate.day) + 1, hour, minutes);
      } else if (repeat == 'Weekly') {
        scheduledDate = tz.TZDateTime(
            tz.local, now.year, now.month, (formatDate.day) + 7, hour, minutes);
      } else if (repeat == 'Monthly') {
        scheduledDate = tz.TZDateTime(tz.local, now.year,
            (formatDate.month) + 1, formatDate.day, hour, minutes);
      } else {
        scheduledDate = tz.TZDateTime(tz.local, now.year,
            (formatDate.month), formatDate.day, hour, minutes);
      }
      scheduledDate = _afterRemained(remained, scheduledDate);
    }
    print('next scheduledDate: $scheduledDate');
    return scheduledDate;
  }

  tz.TZDateTime _afterRemained(int remained, tz.TZDateTime scheduledDate) {
    scheduledDate = scheduledDate.subtract(Duration(minutes: remained));
    return scheduledDate;
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
}
