import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import '../models/task.dart';

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final board = appState.board;

    if (board == null) {
      return const Scaffold(
        body: Center(child: Text('No board configured')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Templates'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          const Text(
            'Quick Add Templates',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create templates for tasks you add frequently',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),

          const SizedBox(height: 24),

          // Templates grouped by quadrant
          ...board.quadrants.map((quadrant) {
            final dailyTemplates = appState.getTemplatesForQuadrant(
              quadrant.id,
              TaskFrequency.daily,
            );
            final weeklyTemplates = appState.getTemplatesForQuadrant(
              quadrant.id,
              TaskFrequency.weekly,
            );

            if (dailyTemplates.isEmpty && weeklyTemplates.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quadrant header
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: quadrant.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      quadrant.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Daily templates
                if (dailyTemplates.isNotEmpty) ...[
                  const Text(
                    'Daily',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...dailyTemplates.map((template) => _buildTemplateItem(
                        context,
                        appState,
                        template.id,
                        template.name,
                        quadrant.color,
                      )),
                  const SizedBox(height: 12),
                ],

                // Weekly templates
                if (weeklyTemplates.isNotEmpty) ...[
                  const Text(
                    'Weekly',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...weeklyTemplates.map((template) => _buildTemplateItem(
                        context,
                        appState,
                        template.id,
                        template.name,
                        quadrant.color,
                      )),
                  const SizedBox(height: 12),
                ],

                const Divider(height: 32),
              ],
            );
          }),

          // Add new template button
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _showAddTemplateDialog(context, appState, board.quadrants[0].id),
            icon: const Icon(Icons.add),
            label: const Text('Create New Template'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateItem(
    BuildContext context,
    AppState appState,
    String templateId,
    String name,
    Color quadrantColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Container(
          width: 8,
          height: 40,
          decoration: BoxDecoration(
            color: quadrantColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _editTemplate(context, appState, templateId, name),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () => _deleteTemplate(context, appState, templateId, name),
              tooltip: 'Delete',
            ),
          ],
        ),
        onTap: () {
          // Quick add from template
          appState.addTaskFromTemplate(templateId);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added "$name" as a task'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  void _showAddTemplateDialog(
    BuildContext context,
    AppState appState,
    String defaultQuadrantId,
  ) {
    final controller = TextEditingController();
    String selectedQuadrantId = defaultQuadrantId;
    TaskFrequency selectedFrequency = TaskFrequency.daily;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Template'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Template name',
                  hintText: 'e.g., "Morning workout"',
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedQuadrantId,
                decoration: const InputDecoration(labelText: 'Quadrant'),
                items: appState.board!.quadrants
                    .map((q) => DropdownMenuItem(
                          value: q.id,
                          child: Text(q.name),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedQuadrantId = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskFrequency>(
                initialValue: selectedFrequency,
                decoration: const InputDecoration(labelText: 'Frequency'),
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
                    setState(() => selectedFrequency = value);
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
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  appState.addTemplate(
                    selectedQuadrantId,
                    controller.text.trim(),
                    selectedFrequency,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Template created')),
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _editTemplate(
    BuildContext context,
    AppState appState,
    String templateId,
    String currentName,
  ) {
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Template'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Template name',
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
                appState.updateTemplate(templateId, name: controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteTemplate(
    BuildContext context,
    AppState appState,
    String templateId,
    String name,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template?'),
        content: Text('Delete "$name"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              appState.deleteTemplate(templateId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Template deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
