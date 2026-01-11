import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import '../models/quadrant.dart';
import '../models/task.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const int _morningReminderId = 1;
  static const int _midDayReminderId = 2;
  static const int _eveningReminderId = 3;

  Map<String, dynamic> _settings = {};

  /// Initialize notifications
  Future<void> init() async {
    // Initialize timezone
    tz_data.initializeTimeZones();

    // Android settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  /// Update notification settings
  void updateSettings(Map<String, dynamic> settings) {
    _settings = settings;
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final ios = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (android != null) {
      await android.requestNotificationsPermission();
    }

    if (ios != null) {
      await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    return true;
  }

  /// Schedule all reminders based on settings
  Future<void> scheduleAllReminders(
    int remainingDailyTasks,
    List<Quadrant> quadrants,
    List<Task> allTasks,
  ) async {
    // Cancel all existing notifications
    await _notifications.cancelAll();

    if (remainingDailyTasks == 0) return; // No reminders if all done

    // Get settings with defaults
    final enableMorning = _settings['enableMorning'] ?? true;
    final enableMidDay = _settings['enableMidDay'] ?? true;
    final enableEvening = _settings['enableEvening'] ?? true;

    // Schedule morning motivation
    if (enableMorning) {
      final morningHour = _settings['morningHour'] ?? 8;
      final morningMinute = _settings['morningMinute'] ?? 0;
      await _scheduleMorningMotivation(
        TimeOfDay(hour: morningHour, minute: morningMinute),
        remainingDailyTasks,
        quadrants,
        allTasks,
      );
    }

    // Schedule mid-day check-in
    if (enableMidDay) {
      final midDayHour = _settings['midDayHour'] ?? 14;
      final midDayMinute = _settings['midDayMinute'] ?? 0;
      await _scheduleMidDayCheckIn(
        TimeOfDay(hour: midDayHour, minute: midDayMinute),
        remainingDailyTasks,
      );
    }

    // Schedule evening reminder
    if (enableEvening) {
      final eveningHour = _settings['eveningHour'] ?? 17;
      final eveningMinute = _settings['eveningMinute'] ?? 0;
      await _scheduleEveningReminder(
        TimeOfDay(hour: eveningHour, minute: eveningMinute),
        remainingDailyTasks,
      );
    }
  }

  /// Schedule morning motivation notification
  Future<void> _scheduleMorningMotivation(
    TimeOfDay time,
    int remainingTasks,
    List<Quadrant> quadrants,
    List<Task> allTasks,
  ) async {
    // Find quadrant with most tasks
    String motivationalMessage = 'Good morning! You have $remainingTasks tasks today.';
    
    if (quadrants.isNotEmpty && allTasks.isNotEmpty) {
      // Group tasks by quadrant
      final tasksByQuadrant = <String, List<Task>>{};
      for (var task in allTasks) {
        if (!task.isCompleted && task.frequency == TaskFrequency.daily) {
          tasksByQuadrant.putIfAbsent(task.quadrantId, () => []).add(task);
        }
      }

      // Find quadrant with most tasks
      String? topQuadrantId;
      int maxTasks = 0;
      tasksByQuadrant.forEach((quadrantId, tasks) {
        if (tasks.length > maxTasks) {
          maxTasks = tasks.length;
          topQuadrantId = quadrantId;
        }
      });

      if (topQuadrantId != null) {
        final quadrant = quadrants.firstWhere((q) => q.id == topQuadrantId);
        motivationalMessage = 
            'Good morning! Focus on ${quadrant.name} today - $maxTasks tasks waiting. 💪';
      }
    }

    await _scheduleNotification(
      _morningReminderId,
      'Quad Master',
      motivationalMessage,
      time,
    );
  }

  /// Schedule mid-day check-in notification
  Future<void> _scheduleMidDayCheckIn(
    TimeOfDay time,
    int remainingTasks,
  ) async {
    String message;
    
    if (remainingTasks <= 2) {
      message = 'Almost there! Only $remainingTasks tasks left. You got this! 🎯';
    } else if (remainingTasks <= 5) {
      message = '$remainingTasks tasks remaining. Quick wins ahead! ⚡';
    } else {
      message = 'Mid-day check: $remainingTasks tasks to go. Keep pushing! 💪';
    }

    await _scheduleNotification(
      _midDayReminderId,
      'Quad Master',
      message,
      time,
    );
  }

  /// Schedule evening reminder notification
  Future<void> _scheduleEveningReminder(
    TimeOfDay time,
    int remainingTasks,
  ) async {
    final taskWord = remainingTasks == 1 ? 'task' : 'tasks';
    String message;
    
    if (remainingTasks == 1) {
      message = 'One more task! Finish strong! 🌟';
    } else if (remainingTasks <= 3) {
      message = 'Evening reminder: $remainingTasks $taskWord left. Almost done! 🌅';
    } else {
      message = 'You have $remainingTasks $taskWord remaining today 📋';
    }

    await _scheduleNotification(
      _eveningReminderId,
      'Quad Master',
      message,
      time,
    );
  }

  /// Generic notification scheduler
  Future<void> _scheduleNotification(
    int id,
    String title,
    String body,
    TimeOfDay time,
  ) async {
    // Calculate next occurrence
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    // Notification details
    const androidDetails = AndroidNotificationDetails(
      'quad_master_reminders',
      'Task Reminders',
      channelDescription: 'Daily task reminders and motivation',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule the notification
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );
  }

  /// Show streak celebration notification
  Future<void> showStreakNotification(String taskName, int streak) async {
    const androidDetails = AndroidNotificationDetails(
      'quad_master_celebrations',
      'Celebrations',
      channelDescription: 'Streak and achievement notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    String emoji = '🔥';
    if (streak >= 30) emoji = '🏆';
    else if (streak >= 14) emoji = '⭐';
    else if (streak >= 7) emoji = '💪';

    await _notifications.show(
      99, // Special ID for celebrations
      '$emoji $streak Day Streak!',
      '"$taskName" - You\'re on fire!',
      details,
    );
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// Show an immediate notification (for testing)
  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'quad_master_test',
      'Test Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      0,
      'Quad Master',
      'Test notification - everything is working! ✅',
      details,
    );
  }
}
