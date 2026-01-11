import 'package:quick_actions/quick_actions.dart';
import 'package:flutter/material.dart';

class QuickActionsService {
  final QuickActions _quickActions = const QuickActions();
  
  /// Initialize quick actions (call on app start)
  Future<void> initialize(Function(String) onActionTap) async {
    // Set up the quick actions
    await _quickActions.setShortcutItems([
      const ShortcutItem(
        type: 'action_add_task',
        localizedTitle: 'Add Task',
        icon: 'ic_add',
      ),
      const ShortcutItem(
        type: 'action_view_daily',
        localizedTitle: 'Daily Tasks',
        icon: 'ic_daily',
      ),
      const ShortcutItem(
        type: 'action_view_weekly',
        localizedTitle: 'Weekly Tasks',
        icon: 'ic_weekly',
      ),
      const ShortcutItem(
        type: 'action_view_summary',
        localizedTitle: 'Weekly Summary',
        icon: 'ic_chart',
      ),
    ]);

    // Handle quick action taps
    _quickActions.initialize((String shortcutType) {
      onActionTap(shortcutType);
    });
  }

  /// Clear all quick actions
  Future<void> clearShortcutItems() async {
    await _quickActions.clearShortcutItems();
  }
}
