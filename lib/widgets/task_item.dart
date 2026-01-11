import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../models/task.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final Color quadrantColor;
  final bool showQuadrantLabel;
  final String? quadrantName;
  final VoidCallback onComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onSaveAsTemplate;

  const TaskItem({
    super.key,
    required this.task,
    required this.quadrantColor,
    this.showQuadrantLabel = false,
    this.quadrantName,
    required this.onComplete,
    required this.onEdit,
    required this.onDelete,
    this.onSaveAsTemplate,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(task.id),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onComplete(),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            icon: Icons.check,
            label: 'Complete',
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          if (onSaveAsTemplate != null)
            SlidableAction(
              onPressed: (_) => onSaveAsTemplate!(),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.library_add,
              label: 'Template',
              borderRadius: BorderRadius.circular(8),
            ),
          SlidableAction(
            onPressed: (_) => _confirmDelete(context),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),
      child: GestureDetector(
        onLongPress: () => _showOptions(context),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              // Checkbox
              GestureDetector(
                onTap: onComplete,
                child: Container(
                  width: 44, // Increased from 32 for better touch target
                  height: 44,
                  alignment: Alignment.center,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: quadrantColor,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),

              // Task content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.name,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        // Streak indicator
                        if (task.currentStreak > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getStreakColor(task.currentStreak).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getStreakColor(task.currentStreak),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _getStreakEmoji(task.currentStreak),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${task.currentStreak}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _getStreakColor(task.currentStreak),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    if (showQuadrantLabel && quadrantName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                color: quadrantColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Text(
                              quadrantName!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStreakColor(int streak) {
    if (streak >= 30) return Colors.purple;
    if (streak >= 14) return Colors.orange;
    if (streak >= 7) return Colors.green;
    return Colors.blue;
  }

  String _getStreakEmoji(int streak) {
    if (streak >= 30) return '🏆';
    if (streak >= 14) return '⭐';
    if (streak >= 7) return '💪';
    return '🔥';
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            if (onSaveAsTemplate != null)
              ListTile(
                leading: const Icon(Icons.library_add),
                title: const Text('Save as Template'),
                onTap: () {
                  Navigator.pop(context);
                  onSaveAsTemplate!();
                },
              ),
            if (task.currentStreak > 0)
              ListTile(
                leading: Icon(
                  Icons.info_outline,
                  color: _getStreakColor(task.currentStreak),
                ),
                title: Text(
                  '${task.currentStreak} ${task.frequency == TaskFrequency.daily ? "day" : "week"} streak!',
                ),
                subtitle: task.completionHistory.isNotEmpty
                    ? Text(
                        'Total completions: ${task.completionHistory.length}',
                        style: TextStyle(color: Colors.grey[600]),
                      )
                    : null,
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${task.name}"?'),
            if (task.currentStreak > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You have a ${task.currentStreak} ${task.frequency == TaskFrequency.daily ? "day" : "week"} streak!',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
