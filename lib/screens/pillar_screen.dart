import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/app_state.dart';
import '../models/task.dart';
import '../widgets/task_item.dart';
import '../widgets/add_task_field.dart';
import '../widgets/undo_toast.dart';

class PillarScreen extends StatefulWidget {
  final String quadrantId;

  const PillarScreen({super.key, required this.quadrantId});

  @override
  State<PillarScreen> createState() => _PillarScreenState();
}

class _PillarScreenState extends State<PillarScreen> {
  TaskFrequency _currentView = TaskFrequency.daily;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final quadrant = appState.board?.getQuadrant(widget.quadrantId);

    if (quadrant == null) {
      return const Scaffold(
        body: Center(child: Text('Quadrant not found')),
      );
    }

    final tasks = appState.getTasksForQuadrant(widget.quadrantId, _currentView);
    final templates = appState.getTemplatesForQuadrant(widget.quadrantId, _currentView);
    final viewName = _currentView == TaskFrequency.daily ? 'Daily' : 'Weekly';
    final otherView = _currentView == TaskFrequency.daily ? 'Weekly' : 'Daily';

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Header
              Container(
                color: quadrant.color,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 8,
                  bottom: 16,
                  left: 16,
                  right: 16,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: quadrant.textColor),
                      onPressed: () {
                        appState.clearUndoState();
                        Navigator.pop(context);
                      },
                    ),
                    Expanded(
                      child: Text(
                        '${quadrant.name} $viewName Tasks',
                        style: TextStyle(
                          color: quadrant.textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: quadrant.textColor),
                      onSelected: (value) {
                        if (value == 'share') {
                          _shareList(appState);
                        } else if (value == 'templates') {
                          _showTemplates(context, appState, templates);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'templates',
                          child: Row(
                            children: [
                              Icon(Icons.library_books),
                              SizedBox(width: 8),
                              Text('Add from template'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'share',
                          child: Row(
                            children: [
                              Icon(Icons.share),
                              SizedBox(width: 8),
                              Text('Share list'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Task list
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 64,
                              color: quadrant.color.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No $viewName tasks yet',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (templates.isNotEmpty)
                              TextButton.icon(
                                onPressed: () => _showTemplates(context, appState, templates),
                                icon: const Icon(Icons.library_books),
                                label: const Text('Add from template'),
                              )
                            else
                              Text(
                                'Tap "add new" below to get started',
                                style: TextStyle(
                                  color: Colors.grey[500],
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
                          return TaskItem(
                            task: task,
                            quadrantColor: quadrant.color,
                            onComplete: () => appState.completeTask(task.id),
                            onEdit: () => _editTask(context, appState, task),
                            onDelete: () => appState.deleteTask(task.id),
                            onSaveAsTemplate: () => _saveAsTemplate(context, appState, task),
                          );
                        },
                      ),
              ),

              // Add task field
              AddTaskField(
                onAdd: (name) => appState.addTask(
                  widget.quadrantId,
                  name,
                  _currentView,
                ),
                onTemplateTap: templates.isNotEmpty 
                    ? () => _showTemplates(context, appState, templates)
                    : null,
              ),

              // Footer toggle
              GestureDetector(
                onTap: () => setState(() {
                  _currentView = _currentView == TaskFrequency.daily
                      ? TaskFrequency.weekly
                      : TaskFrequency.daily;
                }),
                child: Container(
                  color: Color.lerp(quadrant.color, Colors.black, 0.2),
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 12,
                    top: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$otherView ${quadrant.name}',
                        style: TextStyle(
                          color: quadrant.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.swap_horiz,
                        color: quadrant.textColor,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Undo toast
          if (appState.lastCompletedTask != null)
            Positioned(
              bottom: 100,
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

  void _showTemplates(
    BuildContext context,
    AppState appState,
    List templates,
  ) {
    if (templates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No templates yet. Create one from Settings > Templates'),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Add from Template',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            ...templates.map((template) => ListTile(
                  leading: const Icon(Icons.library_books),
                  title: Text(template.name),
                  onTap: () {
                    appState.addTaskFromTemplate(template.id);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added "${template.name}"'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _shareList(AppState appState) {
    final text = appState.getShareableText(widget.quadrantId, _currentView);
    Share.share(text);
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

  void _saveAsTemplate(BuildContext context, AppState appState, Task task) {
    appState.saveTaskAsTemplate(task.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${task.name}" saved as template'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
