import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import '../models/task.dart';
import '../widgets/task_item.dart';
import '../widgets/undo_toast.dart';

class WeeklyScreen extends StatelessWidget {
  const WeeklyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final tasks = appState.weeklyTasks;
    final board = appState.board;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Header
              Container(
                color: Colors.white,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 8,
                  bottom: 16,
                  left: 16,
                  right: 16,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        appState.clearUndoState();
                        Navigator.pop(context);
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'Weekly Tasks',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),

              // Divider
              Container(height: 1, color: Colors.grey[300]),

              // Task list
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_available,
                              size: 64,
                              color: Colors.blue[300],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'All weekly tasks done!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'You\'ve completed everything for this week.',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          final quadrant = board?.getQuadrant(task.quadrantId);

                          return TaskItem(
                            task: task,
                            quadrantColor: quadrant?.color ?? Colors.grey,
                            showQuadrantLabel: true,
                            quadrantName: quadrant?.name,
                            onComplete: () => appState.completeTask(task.id),
                            onEdit: () => _editTask(context, appState, task),
                            onDelete: () => appState.deleteTask(task.id),
                          );
                        },
                      ),
              ),

              // Bottom padding
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),

          // Undo toast
          if (appState.lastCompletedTask != null)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              left: 16,
              right: 16,
              child: UndoToast(
                taskName: appState.lastCompletedTask!.name,
                onUndo: () => appState.undoComplete(),
              ),
            ),
        ],
      ),
    );
  }

  void _editTask(BuildContext context, AppState appState, Task task) {
    final controller = TextEditingController(text: task.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Task name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                appState.updateTask(task.id, name: controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
