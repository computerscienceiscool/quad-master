import 'package:home_widget/home_widget.dart';
import 'dart:convert';
import '../models/task.dart';

class HomeWidgetService {
  static const String widgetName = 'QuadMasterWidget';
  
  /// Update home screen widget with current task data
  Future<void> updateWidget({
    required List<Task> allTasks,
    required int completedCount,
    required int totalCount,
  }) async {
    try {
      // Get uncompleted daily tasks
      final dailyTasks = allTasks
          .where((t) => t.frequency == TaskFrequency.daily && !t.isCompleted)
          .take(5)
          .toList();

      // Prepare task list for widget
      final taskList = dailyTasks.map((task) => {
        'name': task.name,
        'streak': task.currentStreak,
      }).toList();

      // Save data to widget
      await HomeWidget.saveWidgetData<int>('completed_count', completedCount);
      await HomeWidget.saveWidgetData<int>('total_count', totalCount);
      await HomeWidget.saveWidgetData<String>('task_list', jsonEncode(taskList));
      await HomeWidget.saveWidgetData<int>('remaining_count', totalCount - completedCount);
      
      // Calculate completion percentage
      final percentage = totalCount > 0 ? (completedCount / totalCount * 100).round() : 0;
      await HomeWidget.saveWidgetData<int>('completion_percentage', percentage);

      // Update the widget
      await HomeWidget.updateWidget(
        name: widgetName,
        iOSName: widgetName,
        androidName: widgetName,
      );
    } catch (e) {
      print('Error updating home widget: $e');
    }
  }

  /// Initialize widget (call on app start)
  Future<void> initialize() async {
    try {
      // Register callback for widget interactions
      HomeWidget.setAppGroupId('group.com.quadmaster.app');
      
      // Handle widget taps (opens app)
      HomeWidget.widgetClicked.listen((uri) {
        if (uri != null) {
          _handleWidgetClick(uri);
        }
      });
    } catch (e) {
      print('Error initializing home widget: $e');
    }
  }

  void _handleWidgetClick(Uri uri) {
    // Handle different widget actions
    // e.g., uri.path could be '/daily', '/weekly', '/add_task'
    print('Widget clicked: ${uri.path}');
  }

  /// Request widget update permission (iOS 14+)
  Future<void> requestPermission() async {
    try {
      // Note: Actual permission handling depends on platform
      await HomeWidget.updateWidget(
        name: widgetName,
        iOSName: widgetName,
      );
    } catch (e) {
      print('Error requesting widget permission: $e');
    }
  }
}
