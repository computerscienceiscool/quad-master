import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/board.dart';
import '../models/task.dart';
import '../models/task_template.dart';

class StorageService {
  static const String _boardBoxName = 'board';
  static const String _tasksBoxName = 'tasks';
  static const String _settingsBoxName = 'settings';
  static const String _templatesBoxName = 'templates';
  
  static const int CURRENT_SCHEMA_VERSION = 2;

  late Box _boardBox;
  late Box _tasksBox;
  late Box _settingsBox;
  late Box _templatesBox;

  /// Initialize Hive boxes
  Future<void> init() async {
    _boardBox = await Hive.openBox(_boardBoxName);
    _tasksBox = await Hive.openBox(_tasksBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
    _templatesBox = await Hive.openBox(_templatesBoxName);
    
    // Run migrations if needed
    await _checkAndMigrate();
  }

  /// Check schema version and migrate if needed
  Future<void> _checkAndMigrate() async {
    final version = _settingsBox.get('schemaVersion', defaultValue: 1) as int;
    
    if (version < CURRENT_SCHEMA_VERSION) {
      await _migrateSchema(version, CURRENT_SCHEMA_VERSION);
    }
  }

  /// Migrate schema between versions
  Future<void> _migrateSchema(int from, int to) async {
    print('Migrating schema from v$from to v$to');
    
    // Step-by-step migrations
    if (from == 1 && to >= 2) {
      await _migrateV1toV2();
    }
    
    // Update schema version
    await _settingsBox.put('schemaVersion', to);
    print('Schema migration complete: v$to');
  }

  /// Migrate from v1 to v2 (add task history)
  Future<void> _migrateV1toV2() async {
    print('Migrating tasks to v2 (adding history tracking)');
    
    try {
      final data = _tasksBox.get('all');
      if (data == null) return;

      final List<dynamic> decoded = jsonDecode(data);
      final tasks = decoded.map((t) {
        // Add history fields if they don't exist
        if (!t.containsKey('completionHistory')) {
          t['completionHistory'] = [];
          // If task was completed, add that date to history
          if (t['completedAt'] != null) {
            t['completionHistory'] = [t['completedAt']];
          }
        }
        if (!t.containsKey('currentStreak')) {
          t['currentStreak'] = 0;
        }
        if (!t.containsKey('lastCompletedDate')) {
          t['lastCompletedDate'] = t['completedAt'];
        }
        return t;
      }).toList();

      await _tasksBox.put('all', jsonEncode(tasks));
      print('Task migration complete: ${tasks.length} tasks updated');
    } catch (e) {
      print('Error migrating tasks: $e');
      // Don't crash - keep old data
    }
  }

  // ============ Board Storage ============

  /// Save board to storage
  Future<void> saveBoard(Board board) async {
    await _boardBox.put('current', jsonEncode(board.toJson()));
  }

  /// Load board from storage
  Future<Board?> loadBoard() async {
    final data = _boardBox.get('current');
    if (data == null) return null;
    return Board.fromJson(jsonDecode(data));
  }

  /// Delete board
  Future<void> deleteBoard() async {
    await _boardBox.delete('current');
  }

  // ============ Tasks Storage ============

  /// Save all tasks to storage
  Future<void> saveTasks(List<Task> tasks) async {
    // Cleanup old history before saving
    for (var task in tasks) {
      task.cleanupOldHistory();
    }
    
    final data = tasks.map((t) => t.toJson()).toList();
    await _tasksBox.put('all', jsonEncode(data));
  }

  /// Load all tasks from storage
  Future<List<Task>> loadTasks() async {
    final data = _tasksBox.get('all');
    if (data == null) return [];

    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((t) => Task.fromJson(t)).toList();
  }

  /// Delete all tasks
  Future<void> deleteTasks() async {
    await _tasksBox.delete('all');
  }

  // ============ Templates Storage ============

  /// Save all templates to storage
  Future<void> saveTemplates(List<TaskTemplate> templates) async {
    final data = templates.map((t) => t.toJson()).toList();
    await _templatesBox.put('all', jsonEncode(data));
  }

  /// Load all templates from storage
  Future<List<TaskTemplate>> loadTemplates() async {
    final data = _templatesBox.get('all');
    if (data == null) return [];

    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((t) => TaskTemplate.fromJson(t)).toList();
  }

  /// Delete all templates
  Future<void> deleteTemplates() async {
    await _templatesBox.delete('all');
  }

  // ============ Settings Storage ============

  /// Save reminder time
  Future<void> saveReminderTime(TimeOfDay time) async {
    await _settingsBox.put('reminderTime', jsonEncode({
      'hour': time.hour,
      'minute': time.minute,
    }));
  }

  /// Load reminder time (default 5:00 PM)
  Future<TimeOfDay> loadReminderTime() async {
    final data = _settingsBox.get('reminderTime');
    if (data == null) return const TimeOfDay(hour: 17, minute: 0);
    
    final Map<String, dynamic> json = jsonDecode(data);
    return TimeOfDay(
      hour: json['hour'] as int,
      minute: json['minute'] as int,
    );
  }

  /// Save notification settings
  Future<void> saveNotificationSettings(Map<String, dynamic> settings) async {
    await _settingsBox.put('notificationSettings', jsonEncode(settings));
  }

  /// Load notification settings
  Future<Map<String, dynamic>> loadNotificationSettings() async {
    final data = _settingsBox.get('notificationSettings');
    if (data == null) {
      // Default settings
      return {
        'enableMorning': true,
        'enableMidDay': true,
        'enableEvening': true,
        'morningHour': 8,
        'morningMinute': 0,
        'midDayHour': 14,
        'midDayMinute': 0,
        'eveningHour': 17,
        'eveningMinute': 0,
      };
    }
    return Map<String, dynamic>.from(jsonDecode(data));
  }

  // ============ Clear All Data ============

  /// Clear all stored data
  Future<void> clearAll() async {
    await _boardBox.clear();
    await _tasksBox.clear();
    await _settingsBox.clear();
    await _templatesBox.clear();
  }

  /// Export all data (for backup)
  Future<Map<String, dynamic>> exportAllData() async {
    return {
      'board': _boardBox.get('current'),
      'tasks': _tasksBox.get('all'),
      'templates': _templatesBox.get('all'),
      'reminderTime': _settingsBox.get('reminderTime'),
      'notificationSettings': _settingsBox.get('notificationSettings'),
      'schemaVersion': _settingsBox.get('schemaVersion', defaultValue: CURRENT_SCHEMA_VERSION),
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  /// Import data (from backup)
  Future<void> importData(Map<String, dynamic> data) async {
    if (data['board'] != null) {
      await _boardBox.put('current', data['board']);
    }
    if (data['tasks'] != null) {
      await _tasksBox.put('all', data['tasks']);
    }
    if (data['templates'] != null) {
      await _templatesBox.put('all', data['templates']);
    }
    if (data['reminderTime'] != null) {
      await _settingsBox.put('reminderTime', data['reminderTime']);
    }
    if (data['notificationSettings'] != null) {
      await _settingsBox.put('notificationSettings', data['notificationSettings']);
    }
    
    // Check if migration needed after import
    await _checkAndMigrate();
  }
}
