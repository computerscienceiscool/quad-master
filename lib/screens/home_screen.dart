import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import '../models/task.dart';
import '../widgets/quadrant_tile.dart';
import '../widgets/center_circle.dart';
import 'pillar_screen.dart';
import 'daily_screen.dart';
import 'weekly_screen.dart';
import 'settings_screen.dart';
import '../services/home_widget_service.dart';

class HomeScreen extends StatefulWidget {
  final String? initialAction; // For quick actions

  const HomeScreen({super.key, this.initialAction});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeWidgetService _widgetService = HomeWidgetService();

  @override
  void initState() {
    super.initState();
    _widgetService.initialize();
    
    // Handle initial quick action if any
    if (widget.initialAction != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleQuickAction(widget.initialAction!);
      });
    }

    // Update widget whenever tasks change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateHomeWidget();
    });
  }

  void _updateHomeWidget() {
    final appState = context.read<AppState>();
    final allTasks = appState.tasks;
    final dailyTasks = allTasks.where((t) => t.frequency == TaskFrequency.daily).toList();
    final completed = dailyTasks.where((t) => t.isCompleted).length;
    final total = dailyTasks.length;

    _widgetService.updateWidget(
      allTasks: allTasks,
      completedCount: completed,
      totalCount: total,
    );
  }

  void _handleQuickAction(String action) {
    switch (action) {
      case 'action_add_task':
        _showQuickAddDialog();
        break;
      case 'action_view_daily':
        _openDaily(context);
        break;
      case 'action_view_weekly':
        _openWeekly(context);
        break;
      case 'action_view_summary':
        _openSettings(context);
        break;
    }
  }

  void _showQuickAddDialog() {
    final appState = context.read<AppState>();
    final board = appState.board;
    if (board == null) return;

    String? selectedQuadrantId = board.quadrants.first.id;
    TaskFrequency selectedFrequency = TaskFrequency.daily;
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Quick Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Task name',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedQuadrantId,
                decoration: const InputDecoration(
                  labelText: 'Quadrant',
                  border: OutlineInputBorder(),
                ),
                items: board.quadrants
                    .map((q) => DropdownMenuItem(
                          value: q.id,
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: q.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(q.name),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setDialogState(() => selectedQuadrantId = value);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskFrequency>(
                value: selectedFrequency,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: TaskFrequency.daily,
                    child: Text('Daily'),
                  ),
                  DropdownMenuItem(
                    value: TaskFrequency.weekly,
                    child: Text('Weekly'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => selectedFrequency = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty && selectedQuadrantId != null) {
                  appState.addTask(
                    selectedQuadrantId!,
                    controller.text.trim(),
                    selectedFrequency,
                  );
                  Navigator.pop(context);
                  _updateHomeWidget();
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final board = appState.board;

    if (board == null) {
      return const Scaffold(
        body: Center(child: Text('No board configured')),
      );
    }

    // Calculate task counts for each quadrant
    final quadrantTaskCounts = board.quadrants.map((q) {
      return appState.getAllTasksForQuadrant(q.id).length;
    }).toList();

    // Calculate daily completion percentage for progress ring
    final dailyTasks = appState.tasks
        .where((t) => t.frequency == TaskFrequency.daily)
        .toList();
    final completedDaily = dailyTasks.where((t) => t.isCompleted).length;
    final totalDaily = dailyTasks.length;
    final completionPercentage = totalDaily > 0 ? completedDaily / totalDaily : 0.0;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Four quadrants in a 2x2 grid
            Column(
              children: [
                // Top row
                Expanded(
                  child: Row(
                    children: [
                      // Top-left quadrant
                      Expanded(
                        child: QuadrantTile(
                          quadrant: board.quadrants[0],
                          taskCount: quadrantTaskCounts[0],
                          onTap: () {
                            _openPillar(context, board.quadrants[0].id);
                          },
                        ),
                      ),
                      // Top-right quadrant
                      Expanded(
                        child: QuadrantTile(
                          quadrant: board.quadrants[1],
                          taskCount: quadrantTaskCounts[1],
                          onTap: () {
                            _openPillar(context, board.quadrants[1].id);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Bottom row
                Expanded(
                  child: Row(
                    children: [
                      // Bottom-left quadrant
                      Expanded(
                        child: QuadrantTile(
                          quadrant: board.quadrants[2],
                          taskCount: quadrantTaskCounts[2],
                          onTap: () {
                            _openPillar(context, board.quadrants[2].id);
                          },
                        ),
                      ),
                      // Bottom-right quadrant
                      Expanded(
                        child: QuadrantTile(
                          quadrant: board.quadrants[3],
                          taskCount: quadrantTaskCounts[3],
                          onTap: () {
                            _openPillar(context, board.quadrants[3].id);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Center circle overlay with progress ring
            Center(
              child: CenterCircle(
                onDailyTap: () => _openDaily(context),
                onWeeklyTap: () => _openWeekly(context),
                dailyCompletionPercentage: completionPercentage,
              ),
            ),

            // Menu button
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                onPressed: () => _openSettings(context),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.26),
                ),
              ),
            ),

            // FAB for quick add
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: _showQuickAddDialog,
                backgroundColor: Colors.amber,
                child: const Icon(Icons.add, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openPillar(BuildContext context, String quadrantId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PillarScreen(quadrantId: quadrantId),
      ),
    ).then((_) => _updateHomeWidget());
  }

  void _openDaily(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DailyScreen(),
      ),
    ).then((_) => _updateHomeWidget());
  }

  void _openWeekly(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WeeklyScreen(),
      ),
    ).then((_) => _updateHomeWidget());
  }

  void _openSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }
}
