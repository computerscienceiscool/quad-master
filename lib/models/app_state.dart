import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import 'board.dart';
import 'quadrant.dart';
import 'task.dart';
import 'task_template.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class AppState extends ChangeNotifier {
  final StorageService _storage;
  final NotificationService _notifications;
  final _uuid = const Uuid();

  bool _isInitialized = false;
  Board? _board;
  List<Task> _tasks = [];
  List<TaskTemplate> _templates = [];
  TimeOfDay _reminderTime = const TimeOfDay(hour: 17, minute: 0);

  // Recently completed task for undo
  Task? _lastCompletedTask;
  
  // Timer handle for cancelling undo timeout
  String? _lastCompletedTaskId;

  AppState(this._storage, this._notifications) {
    _init();
  }

  // Getters
  bool get isInitialized => _isInitialized;
  bool get hasBoard => _board != null;
  Board? get board => _board;
  List<Task> get tasks => _tasks;
  List<TaskTemplate> get templates => _templates;
  TimeOfDay get reminderTime => _reminderTime;
  Task? get lastCompletedTask => _lastCompletedTask;

  /// Initialize state from storage
  Future<void> _init() async {
    _board = await _storage.loadBoard();
    _tasks = await _storage.loadTasks();
    _templates = await _storage.loadTemplates();
    _reminderTime = await _storage.loadReminderTime();

    // Reset tasks if needed
    _resetTasksIfNeeded();

    _isInitialized = true;
    notifyListeners();

    // Schedule notification
    _scheduleReminders();
  }

  /// Reset tasks based on daily/weekly schedule
  void _resetTasksIfNeeded() {
    final now = DateTime.now();
    bool changed = false;

    for (final task in _tasks) {
      if (task.shouldReset(now)) {
        task.reset();
        changed = true;
      }
    }

    if (changed) {
      _storage.saveTasks(_tasks);
    }
  }

  // ============ Board Management ============

  /// Create a new board
  Future<void> createBoard(String name, List<Quadrant> quadrants) async {
    _board = Board(
      id: _uuid.v4(),
      name: name,
      quadrants: quadrants,
    );
    await _storage.saveBoard(_board!);
    
    // Create default templates for each quadrant
    await _createDefaultTemplates();
    
    notifyListeners();
  }

  /// Create default templates for new board
  Future<void> _createDefaultTemplates() async {
    if (_board == null) return;
    
    final defaultTemplates = <TaskTemplate>[];
    
    for (final quadrant in _board!.quadrants) {
      // Add a few generic templates per quadrant
      defaultTemplates.addAll([
        TaskTemplate(
          id: _uuid.v4(),
          name: 'Quick task',
          quadrantId: quadrant.id,
          frequency: TaskFrequency.daily,
        ),
        TaskTemplate(
          id: _uuid.v4(),
          name: 'Weekly review',
          quadrantId: quadrant.id,
          frequency: TaskFrequency.weekly,
        ),
      ]);
    }
    
    _templates = defaultTemplates;
    await _storage.saveTemplates(_templates);
  }

  /// Update quadrant
  Future<void> updateQuadrant(String quadrantId,
      {String? name, Color? color}) async {
    if (_board == null) return;

    final index = _board!.quadrants.indexWhere((q) => q.id == quadrantId);
    if (index == -1) return;

    _board!.quadrants[index] = _board!.quadrants[index].copyWith(
      name: name,
      color: color,
    );

    await _storage.saveBoard(_board!);
    notifyListeners();
  }

  // ============ Task Management ============

  /// Get tasks for a specific quadrant
  List<Task> getTasksForQuadrant(String quadrantId, TaskFrequency frequency) {
    return _tasks
        .where((t) =>
            t.quadrantId == quadrantId &&
            t.frequency == frequency &&
            !t.isCompleted)
        .toList();
  }

  /// Get all uncompleted daily tasks
  List<Task> get uncompletedDailyTasks {
    return _tasks
        .where((t) => t.frequency == TaskFrequency.daily && !t.isCompleted)
        .toList();
  }

  /// Get all weekly tasks (completed or not, for the week view)
  List<Task> get weeklyTasks {
    return _tasks
        .where((t) => t.frequency == TaskFrequency.weekly && !t.isCompleted)
        .toList();
  }

  /// Get all tasks for a quadrant (both daily and weekly, uncompleted)
  List<Task> getAllTasksForQuadrant(String quadrantId) {
    return _tasks
        .where((t) => t.quadrantId == quadrantId && !t.isCompleted)
        .toList();
  }

  /// Add a new task
  Future<void> addTask(
      String quadrantId, String name, TaskFrequency frequency) async {
    final task = Task(
      id: _uuid.v4(),
      quadrantId: quadrantId,
      name: name,
      frequency: frequency,
    );

    _tasks.add(task);
    await _storage.saveTasks(_tasks);
    notifyListeners();
  }

  /// Add task from template
  Future<void> addTaskFromTemplate(String templateId) async {
    final index = _templates.indexWhere((t) => t.id == templateId);
    if (index == -1) return;

    final template = _templates[index];
    final task = template.toTask(_uuid.v4());

    _tasks.add(task);
    await _storage.saveTasks(_tasks);
    notifyListeners();
  }

  /// Complete a task
  Future<void> completeTask(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;

    // Haptic feedback for completion
    HapticFeedback.mediumImpact();

    _lastCompletedTask = _tasks[index].copyWith();
    _lastCompletedTaskId = taskId;
    _tasks[index].complete();
    
    // Check for streak milestone and celebrate
    final streak = _tasks[index].currentStreak;
    if (streak == 7 || streak == 14 || streak == 30 || streak == 50 || streak == 100) {
      HapticFeedback.heavyImpact();
      _notifications.showStreakNotification(_tasks[index].name, streak);
    }

    await _storage.saveTasks(_tasks);
    notifyListeners();

    // Update notifications
    _scheduleReminders();

    // Clear undo after 4 seconds
    final completedTaskId = taskId;
    Future.delayed(const Duration(seconds: 4), () {
      if (_lastCompletedTaskId == completedTaskId) {
        _lastCompletedTask = null;
        _lastCompletedTaskId = null;
        notifyListeners();
      }
    });
  }

  /// Undo last completion
  Future<void> undoComplete() async {
    if (_lastCompletedTask == null) return;

    final index = _tasks.indexWhere((t) => t.id == _lastCompletedTask!.id);
    if (index == -1) return;

    // Light haptic for undo
    HapticFeedback.lightImpact();

    _tasks[index].uncomplete();
    _lastCompletedTask = null;
    _lastCompletedTaskId = null;

    await _storage.saveTasks(_tasks);
    notifyListeners();
    
    // Update notifications
    _scheduleReminders();
  }

  /// Clear the undo state (call when navigating away)
  void clearUndoState() {
    _lastCompletedTask = null;
    _lastCompletedTaskId = null;
    notifyListeners();
  }

  /// Update a task
  Future<void> updateTask(String taskId, {String? name}) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;

    _tasks[index] = _tasks[index].copyWith(name: name);

    await _storage.saveTasks(_tasks);
    notifyListeners();
  }

  /// Delete a task
  Future<void> deleteTask(String taskId) async {
    // Light haptic for delete
    HapticFeedback.lightImpact();
    
    _tasks.removeWhere((t) => t.id == taskId);
    await _storage.saveTasks(_tasks);
    notifyListeners();
  }

  /// Get task statistics
  Map<String, dynamic>? getTaskStats(String taskId) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return null;

    final task = _tasks[index];

    // Get completions in last 30 days
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final recentCompletions = task.getCompletionsInPeriod(
      thirtyDaysAgo,
      DateTime.now(),
    );

    return {
      'currentStreak': task.currentStreak,
      'totalCompletions': task.completionHistory.length,
      'recentCompletions': recentCompletions,
      'lastCompleted': task.lastCompletedDate,
    };
  }

  // ============ Template Management ============

  /// Get templates for a specific quadrant
  List<TaskTemplate> getTemplatesForQuadrant(String quadrantId, TaskFrequency frequency) {
    return _templates
        .where((t) => t.quadrantId == quadrantId && t.frequency == frequency)
        .toList();
  }

  /// Add a new template
  Future<void> addTemplate(
      String quadrantId, String name, TaskFrequency frequency) async {
    final template = TaskTemplate(
      id: _uuid.v4(),
      name: name,
      quadrantId: quadrantId,
      frequency: frequency,
    );

    _templates.add(template);
    await _storage.saveTemplates(_templates);
    notifyListeners();
  }

  /// Save current task as template
  Future<void> saveTaskAsTemplate(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;

    final task = _tasks[index];

    final template = TaskTemplate(
      id: _uuid.v4(),
      name: task.name,
      quadrantId: task.quadrantId,
      frequency: task.frequency,
    );

    _templates.add(template);
    await _storage.saveTemplates(_templates);
    notifyListeners();
  }

  /// Update a template
  Future<void> updateTemplate(String templateId, {String? name}) async {
    final index = _templates.indexWhere((t) => t.id == templateId);
    if (index == -1) return;

    _templates[index] = _templates[index].copyWith(name: name);

    await _storage.saveTemplates(_templates);
    notifyListeners();
  }

  /// Delete a template
  Future<void> deleteTemplate(String templateId) async {
    _templates.removeWhere((t) => t.id == templateId);
    await _storage.saveTemplates(_templates);
    notifyListeners();
  }

  // ============ Reminders ============

  /// Update reminder time
  Future<void> setReminderTime(TimeOfDay time) async {
    _reminderTime = time;
    await _storage.saveReminderTime(time);
    _scheduleReminders();
    notifyListeners();
  }

  /// Schedule all reminders
  void _scheduleReminders() {
    final remainingCount = uncompletedDailyTasks.length;
    _notifications.scheduleAllReminders(
      remainingCount,
      _board?.quadrants ?? [],
      _tasks,
    );
  }

  // ============ Weekly Summary ============

  /// Get completion stats for a quadrant
  Map<String, dynamic> getQuadrantStats(String quadrantId) {
    final quadrantTasks =
        _tasks.where((t) => t.quadrantId == quadrantId).toList();

    final dailyTasks =
        quadrantTasks.where((t) => t.frequency == TaskFrequency.daily).toList();
    final weeklyTasks = quadrantTasks
        .where((t) => t.frequency == TaskFrequency.weekly)
        .toList();

    final dailyCompleted = dailyTasks.where((t) => t.isCompleted).length;
    final weeklyCompleted = weeklyTasks.where((t) => t.isCompleted).length;
    
    // Calculate average streak
    final streaks = quadrantTasks.map((t) => t.currentStreak).toList();
    final avgStreak = streaks.isEmpty ? 0 : 
        streaks.reduce((a, b) => a + b) / streaks.length;
    
    // Get best streak
    final bestStreak = streaks.isEmpty ? 0 : streaks.reduce((a, b) => a > b ? a : b);

    return {
      'dailyTotal': dailyTasks.length,
      'dailyCompleted': dailyCompleted,
      'weeklyTotal': weeklyTasks.length,
      'weeklyCompleted': weeklyCompleted,
      'averageStreak': avgStreak.round(),
      'bestStreak': bestStreak,
    };
  }

  // ============ Sharing ============

  /// Generate shareable text for a quadrant's tasks
  String getShareableText(String quadrantId, TaskFrequency frequency) {
    final quadrant = _board?.getQuadrant(quadrantId);
    if (quadrant == null) return '';

    final frequencyName =
        frequency == TaskFrequency.daily ? 'Daily' : 'Weekly';
    final taskList = _tasks
        .where((t) => t.quadrantId == quadrantId && t.frequency == frequency)
        .map((t) {
          final streak = t.currentStreak > 0 ? ' 🔥${t.currentStreak}' : '';
          return '☐ ${t.name}$streak';
        })
        .join('\n');

    return '${quadrant.name} - $frequencyName Tasks\n\n$taskList\n\n— Quad Master';
  }

  /// Generate shareable text for entire board
  String getShareableBoardText() {
    if (_board == null) return '';

    final buffer = StringBuffer();
    buffer.writeln('${_board!.name}');
    buffer.writeln('=' * 30);

    for (final quadrant in _board!.quadrants) {
      buffer.writeln('\n${quadrant.name}');
      buffer.writeln('-' * 20);

      final dailyTasks = _tasks
          .where((t) =>
              t.quadrantId == quadrant.id &&
              t.frequency == TaskFrequency.daily)
          .map((t) {
            final streak = t.currentStreak > 0 ? ' 🔥${t.currentStreak}' : '';
            return '  ☐ ${t.name}$streak';
          })
          .join('\n');

      final weeklyTasks = _tasks
          .where((t) =>
              t.quadrantId == quadrant.id &&
              t.frequency == TaskFrequency.weekly)
          .map((t) {
            final streak = t.currentStreak > 0 ? ' 🔥${t.currentStreak}' : '';
            return '  ☐ ${t.name}$streak';
          })
          .join('\n');

      if (dailyTasks.isNotEmpty) {
        buffer.writeln('Daily:');
        buffer.writeln(dailyTasks);
      }

      if (weeklyTasks.isNotEmpty) {
        buffer.writeln('Weekly:');
        buffer.writeln(weeklyTasks);
      }
    }

    buffer.writeln('\n— Quad Master');
    return buffer.toString();
  }
}
