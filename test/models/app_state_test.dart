import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quad_master/models/app_state.dart';
import 'package:quad_master/models/board.dart';
import 'package:quad_master/models/quadrant.dart';
import 'package:quad_master/models/task.dart';
import 'package:quad_master/models/task_template.dart';
import 'package:quad_master/services/storage_service.dart';
import 'package:quad_master/services/notification_service.dart';

/// Mock StorageService that stores data in memory
class MockStorageService implements StorageService {
  Board? _board;
  List<Task> _tasks = [];
  List<TaskTemplate> _templates = [];
  TimeOfDay _reminderTime = const TimeOfDay(hour: 17, minute: 0);
  Map<String, dynamic> _notificationSettings = {};

  @override
  Future<void> init() async {}

  @override
  Future<void> saveBoard(Board board) async => _board = board;

  @override
  Future<Board?> loadBoard() async => _board;

  @override
  Future<void> deleteBoard() async => _board = null;

  @override
  Future<void> saveTasks(List<Task> tasks) async => _tasks = List.from(tasks);

  @override
  Future<List<Task>> loadTasks() async => List.from(_tasks);

  @override
  Future<void> deleteTasks() async => _tasks = [];

  @override
  Future<void> saveTemplates(List<TaskTemplate> templates) async =>
      _templates = List.from(templates);

  @override
  Future<List<TaskTemplate>> loadTemplates() async => List.from(_templates);

  @override
  Future<void> deleteTemplates() async => _templates = [];

  @override
  Future<void> saveReminderTime(TimeOfDay time) async => _reminderTime = time;

  @override
  Future<TimeOfDay> loadReminderTime() async => _reminderTime;

  @override
  Future<void> saveNotificationSettings(Map<String, dynamic> settings) async =>
      _notificationSettings = settings;

  @override
  Future<Map<String, dynamic>> loadNotificationSettings() async =>
      _notificationSettings;

  @override
  Future<void> clearAll() async {
    _board = null;
    _tasks = [];
    _templates = [];
  }

  @override
  Future<Map<String, dynamic>> exportAllData() async => {};

  @override
  Future<void> importData(Map<String, dynamic> data) async {}
}

/// Mock NotificationService that does nothing
class MockNotificationService implements NotificationService {
  @override
  Future<void> init() async {}

  @override
  void updateSettings(Map<String, dynamic> settings) {}

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<void> scheduleAllReminders(
    int remainingDailyTasks,
    List<Quadrant> quadrants,
    List<Task> allTasks,
  ) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> showStreakNotification(String taskName, int streak) async {}

  @override
  Future<void> showTestNotification() async {}
}

List<Quadrant> createTestQuadrants() {
  return [
    Quadrant(id: 'q1', name: 'Work', color: Colors.red),
    Quadrant(id: 'q2', name: 'Health', color: Colors.green),
    Quadrant(id: 'q3', name: 'Personal', color: Colors.blue),
    Quadrant(id: 'q4', name: 'Learning', color: Colors.yellow),
  ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockStorageService mockStorage;
  late MockNotificationService mockNotifications;
  late AppState appState;

  setUp(() async {
    mockStorage = MockStorageService();
    mockNotifications = MockNotificationService();
    appState = AppState(mockStorage, mockNotifications);

    // Wait for initialization
    await Future.delayed(const Duration(milliseconds: 100));
  });

  group('AppState', () {
    group('initialization', () {
      test('starts with no board', () {
        expect(appState.hasBoard, false);
        expect(appState.board, isNull);
      });

      test('starts with empty tasks', () {
        expect(appState.tasks, isEmpty);
      });

      test('becomes initialized', () {
        expect(appState.isInitialized, true);
      });
    });

    group('board management', () {
      test('createBoard creates board with quadrants', () async {
        final quadrants = createTestQuadrants();

        await appState.createBoard('My Board', quadrants);

        expect(appState.hasBoard, true);
        expect(appState.board!.name, 'My Board');
        expect(appState.board!.quadrants, hasLength(4));
        expect(appState.board!.quadrants[0].name, 'Work');
      });

      test('createBoard creates default templates', () async {
        final quadrants = createTestQuadrants();

        await appState.createBoard('My Board', quadrants);

        // Default templates: 2 per quadrant (Quick task + Weekly review)
        expect(appState.templates, hasLength(8));
      });
    });

    group('task management', () {
      setUp(() async {
        await appState.createBoard('Test', createTestQuadrants());
      });

      test('addTask creates task in quadrant', () async {
        final quadrantId = appState.board!.quadrants[0].id;

        await appState.addTask(quadrantId, 'My Task', TaskFrequency.daily);

        expect(appState.tasks, hasLength(1));
        expect(appState.tasks.first.name, 'My Task');
        expect(appState.tasks.first.quadrantId, quadrantId);
        expect(appState.tasks.first.frequency, TaskFrequency.daily);
      });

      test('addTask with invalid quadrantId does nothing', () async {
        await appState.addTask('invalid-id', 'My Task', TaskFrequency.daily);

        expect(appState.tasks, isEmpty);
      });

      test('completeTask marks task completed', () async {
        final quadrantId = appState.board!.quadrants[0].id;
        await appState.addTask(quadrantId, 'Task', TaskFrequency.daily);

        final taskId = appState.tasks.first.id;
        await appState.completeTask(taskId);

        expect(appState.tasks.first.isCompleted, true);
      });

      test('completeTask stores last completed for undo', () async {
        final quadrantId = appState.board!.quadrants[0].id;
        await appState.addTask(quadrantId, 'Task', TaskFrequency.daily);

        final taskId = appState.tasks.first.id;
        await appState.completeTask(taskId);

        expect(appState.lastCompletedTask, isNotNull);
      });

      test('undoComplete restores task', () async {
        final quadrantId = appState.board!.quadrants[0].id;
        await appState.addTask(quadrantId, 'Task', TaskFrequency.daily);

        final taskId = appState.tasks.first.id;
        await appState.completeTask(taskId);
        await appState.undoComplete();

        expect(appState.tasks.first.isCompleted, false);
        expect(appState.lastCompletedTask, isNull);
      });

      test('deleteTask removes task', () async {
        final quadrantId = appState.board!.quadrants[0].id;
        await appState.addTask(quadrantId, 'Task', TaskFrequency.daily);

        final taskId = appState.tasks.first.id;
        await appState.deleteTask(taskId);

        expect(appState.tasks, isEmpty);
      });

      test('updateTask changes task name', () async {
        final quadrantId = appState.board!.quadrants[0].id;
        await appState.addTask(quadrantId, 'Old Name', TaskFrequency.daily);

        final taskId = appState.tasks.first.id;
        await appState.updateTask(taskId, name: 'New Name');

        expect(appState.tasks.first.name, 'New Name');
      });
    });

    group('task filtering', () {
      setUp(() async {
        await appState.createBoard('Test', createTestQuadrants());

        final q1 = appState.board!.quadrants[0].id;
        final q2 = appState.board!.quadrants[1].id;

        await appState.addTask(q1, 'Daily 1', TaskFrequency.daily);
        await appState.addTask(q1, 'Weekly 1', TaskFrequency.weekly);
        await appState.addTask(q2, 'Daily 2', TaskFrequency.daily);
      });

      test('uncompletedDailyTasks returns only uncompleted daily tasks', () {
        final dailyTasks = appState.uncompletedDailyTasks;

        expect(dailyTasks, hasLength(2));
        expect(dailyTasks.every((t) => t.frequency == TaskFrequency.daily), true);
      });

      test('weeklyTasks returns only uncompleted weekly tasks', () {
        final weeklyTasks = appState.weeklyTasks;

        expect(weeklyTasks, hasLength(1));
        expect(weeklyTasks.first.frequency, TaskFrequency.weekly);
      });

      test('getTasksForQuadrant returns tasks for quadrant and frequency', () {
        final q1 = appState.board!.quadrants[0].id;
        final tasks = appState.getTasksForQuadrant(q1, TaskFrequency.daily);

        expect(tasks, hasLength(1));
        expect(tasks.first.name, 'Daily 1');
      });
    });

    group('template management', () {
      setUp(() async {
        await appState.createBoard('Test', createTestQuadrants());
        // Clear default templates for cleaner tests
        for (final t in List.from(appState.templates)) {
          await appState.deleteTemplate(t.id);
        }
      });

      test('addTemplate creates template', () async {
        final quadrantId = appState.board!.quadrants[0].id;

        await appState.addTemplate(quadrantId, 'My Template', TaskFrequency.daily);

        expect(appState.templates, hasLength(1));
        expect(appState.templates.first.name, 'My Template');
      });

      test('addTaskFromTemplate creates task from template', () async {
        final quadrantId = appState.board!.quadrants[0].id;
        await appState.addTemplate(quadrantId, 'Template', TaskFrequency.daily);

        final templateId = appState.templates.first.id;
        await appState.addTaskFromTemplate(templateId);

        expect(appState.tasks, hasLength(1));
        expect(appState.tasks.first.name, 'Template');
      });

      test('saveTaskAsTemplate creates template from task', () async {
        final quadrantId = appState.board!.quadrants[0].id;
        await appState.addTask(quadrantId, 'My Task', TaskFrequency.weekly);

        final taskId = appState.tasks.first.id;
        await appState.saveTaskAsTemplate(taskId);

        expect(appState.templates, hasLength(1));
        expect(appState.templates.first.name, 'My Task');
        expect(appState.templates.first.frequency, TaskFrequency.weekly);
      });

      test('deleteTemplate removes template', () async {
        final quadrantId = appState.board!.quadrants[0].id;
        await appState.addTemplate(quadrantId, 'Template', TaskFrequency.daily);

        final templateId = appState.templates.first.id;
        await appState.deleteTemplate(templateId);

        expect(appState.templates, isEmpty);
      });
    });

    group('undo state', () {
      test('clearUndoState clears last completed', () async {
        await appState.createBoard('Test', createTestQuadrants());

        final quadrantId = appState.board!.quadrants[0].id;
        await appState.addTask(quadrantId, 'Task', TaskFrequency.daily);
        await appState.completeTask(appState.tasks.first.id);

        expect(appState.lastCompletedTask, isNotNull);

        appState.clearUndoState();

        expect(appState.lastCompletedTask, isNull);
      });
    });

    group('quadrant stats', () {
      test('getQuadrantStats returns correct counts', () async {
        await appState.createBoard('Test', createTestQuadrants());

        final q1 = appState.board!.quadrants[0].id;
        await appState.addTask(q1, 'Daily 1', TaskFrequency.daily);
        await appState.addTask(q1, 'Daily 2', TaskFrequency.daily);
        await appState.addTask(q1, 'Weekly 1', TaskFrequency.weekly);

        // Complete one daily task
        await appState.completeTask(appState.tasks[0].id);

        final stats = appState.getQuadrantStats(q1);

        expect(stats['dailyTotal'], 2);
        expect(stats['dailyCompleted'], 1);
        expect(stats['weeklyTotal'], 1);
        expect(stats['weeklyCompleted'], 0);
      });
    });
  });
}
