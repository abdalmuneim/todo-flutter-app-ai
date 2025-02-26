import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

// Top-level function to handle background notifications
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint('Notification tapped: ${notificationResponse.payload}');
  final data = jsonDecode(notificationResponse.payload ?? '');
  // NotificationService()
  //     .showImmediateNotification(title: data['title'], body: data['body']);
}

class NotificationService {
  static final NotificationService instance = NotificationService._();
  factory NotificationService() => instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  Map<Permission, PermissionStatus> _statuses = {};

  bool _isInitNotification = false;

  final AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'task_reminders',
    'Task Reminders',
    description: 'Notifications for task reminders',
    importance: Importance.max,
    enableVibration: true,
    playSound: true,
    showBadge: true,
  );

  Future<void> init() async {
    if (_isInitNotification) return;
    // init time zone
    tz.initializeTimeZones();
    String? defaultZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(defaultZone));

    if (Platform.isAndroid) {
      final androidPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      // Request notification permissions
      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.requestExactAlarmsPermission();

      // Create notification channel
      await androidPlugin?.createNotificationChannel(_channel);
    }

    _statuses = await [
      Permission.notification,
      Permission.scheduleExactAlarm,
    ].request();

    await _notifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      ),
      // onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      // onDidReceiveNotificationResponse: (details) {
      //   debugPrint('Notification tapped: ${details.payload}');
      //   final data = jsonDecode(details.payload ?? '');
      //   // showImmediateNotification(title: data['title'], body: data['body']);
      // },
    );
    _isInitNotification = true;
  }

  NotificationDetails _notificationDetails() {
    return NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails());
  }

  Future<void> _showNotification({
    int? id,
    required String title,
    required String body,
  }) async {
    try {
      await _notifications.show(
        id ?? 0,
        title,
        body,
        _notificationDetails(),
      );
      debugPrint('Immediate notification sent successfully');
    } catch (e) {
      debugPrint('Error showing immediate notification: $e');
      rethrow;
    }
  }

  Future<void> scheduleTaskNotification({
    int? id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      if (_statuses[Permission.notification]?.isDenied ?? false) {
        final status = await Permission.notification.request();
        if (status.isDenied) {
          throw PlatformException(
            code: 'notification_permission_denied',
            message: 'Notification permissions are required for reminders',
          );
        }
      }
      if (_statuses[Permission.scheduleExactAlarm]?.isDenied ?? false) {
        final status = await Permission.scheduleExactAlarm.request();
        if (status.isDenied) {
          throw PlatformException(
            code: 'schedule_exact_alarm_permission_denied',
            message:
                'Schedule exact alarm permissions are required for reminders',
          );
        }
      }

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

      // Calculate the scheduled time
      final now = tz.TZDateTime.now(tz.local);
      var scheduledTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        scheduledDate.hour,
        scheduledDate.minute,
      );

      // If the time is in the past, schedule for 30 seconds from now (for testing)
      if (scheduledTime.isBefore(now)) {
        scheduledTime = now.add(const Duration(seconds: 10));
        debugPrint(
            'Scheduled time was in the past, rescheduling for 30 seconds from now');
      } else {
        scheduledTime = scheduledTime.subtract(Duration(minutes: 5));
      }
      debugPrint('Current time: ${now.toString()}');
      debugPrint('Scheduling notification for: ${scheduledTime.toString()}');

      // Schedule the actual notification
      await _notifications.zonedSchedule(
        id ?? 1,
        title,
        body,
        scheduledTime,
        payload: jsonEncode({"title": title, "body": body, "id": id}),
        _notificationDetails(),
        // android specific: Allow notification while device is in low-power mode
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        // ios specific: use exact time specified (vs relative time)
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        //  make notification reapte DAILY at same  time
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );

      debugPrint('Notification scheduled successfully');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      rethrow;
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotification(int id) async {
    await _notifications.cancelAll();
  }
}
