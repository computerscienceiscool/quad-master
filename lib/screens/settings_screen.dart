import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/app_state.dart';
import 'summary_screen.dart';
import 'templates_screen.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic> _notificationSettings = {};

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final appState = context.read<AppState>();
    // Load from storage in real implementation
    setState(() {
      _notificationSettings = {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // Weekly Summary
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Weekly Summary'),
            subtitle: const Text('View your progress and streaks'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SummaryScreen()),
            ),
          ),

          // Templates
          ListTile(
            leading: const Icon(Icons.library_books),
            title: const Text('Task Templates'),
            subtitle: Text('${appState.templates.length} templates'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TemplatesScreen()),
            ),
          ),

          const Divider(),

          // Notifications Header
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Notifications',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),

          // Morning Reminder
          SwitchListTile(
            value: _notificationSettings['enableMorning'] ?? true,
            onChanged: (value) {
              setState(() => _notificationSettings['enableMorning'] = value);
              _saveNotificationSettings();
            },
            title: const Text('Morning Motivation'),
            subtitle: Text(
              'Daily at ${_formatTime(_notificationSettings['morningHour'] ?? 8, _notificationSettings['morningMinute'] ?? 0)}',
            ),
            secondary: const Icon(Icons.wb_sunny),
          ),

          // Mid-day Check-in
          SwitchListTile(
            value: _notificationSettings['enableMidDay'] ?? true,
            onChanged: (value) {
              setState(() => _notificationSettings['enableMidDay'] = value);
              _saveNotificationSettings();
            },
            title: const Text('Mid-Day Check-In'),
            subtitle: Text(
              'Daily at ${_formatTime(_notificationSettings['midDayHour'] ?? 14, _notificationSettings['midDayMinute'] ?? 0)}',
            ),
            secondary: const Icon(Icons.access_time),
          ),

          // Evening Reminder
          SwitchListTile(
            value: _notificationSettings['enableEvening'] ?? true,
            onChanged: (value) {
              setState(() => _notificationSettings['enableEvening'] = value);
              _saveNotificationSettings();
            },
            title: const Text('Evening Reminder'),
            subtitle: Text(
              'Daily at ${_formatTime(_notificationSettings['eveningHour'] ?? 17, _notificationSettings['eveningMinute'] ?? 0)}',
            ),
            secondary: const Icon(Icons.nightlight),
          ),

          // Notification times
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Customize Times'),
            subtitle: const Text('Set when you want to be reminded'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showTimeCustomization(context),
          ),

          const Divider(),

          // Share Board
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share Entire Board'),
            subtitle: const Text('Export all tasks as text'),
            onTap: () {
              final text = appState.getShareableBoardText();
              Share.share(text);
            },
          ),

          const Divider(),

          // Edit Quadrants
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Quadrants',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),

          ...?appState.board?.quadrants.map((quadrant) => ListTile(
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: quadrant.color,
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(quadrant.name),
                trailing: const Icon(Icons.edit),
                onTap: () => _editQuadrant(
                    context, appState, quadrant.id, quadrant.name),
              )),

          const Divider(),

          // App Info
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Quad Master'),
            subtitle: Text(
              'Version 1.0.0\n"Four corners. Total control."\n\nNow with task history & smart reminders!',
            ),
            isThreeLine: true,
          ),

          // Privacy Policy
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            subtitle: const Text('How we protect your data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }

  void _showTimeCustomization(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Customize Reminder Times'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Morning'),
              subtitle: Text(_formatTime(
                _notificationSettings['morningHour'] ?? 8,
                _notificationSettings['morningMinute'] ?? 0,
              )),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: _notificationSettings['morningHour'] ?? 8,
                    minute: _notificationSettings['morningMinute'] ?? 0,
                  ),
                );
                if (time != null) {
                  setState(() {
                    _notificationSettings['morningHour'] = time.hour;
                    _notificationSettings['morningMinute'] = time.minute;
                  });
                  _saveNotificationSettings();
                  Navigator.pop(context);
                  _showTimeCustomization(context);
                }
              },
            ),
            ListTile(
              title: const Text('Mid-Day'),
              subtitle: Text(_formatTime(
                _notificationSettings['midDayHour'] ?? 14,
                _notificationSettings['midDayMinute'] ?? 0,
              )),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: _notificationSettings['midDayHour'] ?? 14,
                    minute: _notificationSettings['midDayMinute'] ?? 0,
                  ),
                );
                if (time != null) {
                  setState(() {
                    _notificationSettings['midDayHour'] = time.hour;
                    _notificationSettings['midDayMinute'] = time.minute;
                  });
                  _saveNotificationSettings();
                  Navigator.pop(context);
                  _showTimeCustomization(context);
                }
              },
            ),
            ListTile(
              title: const Text('Evening'),
              subtitle: Text(_formatTime(
                _notificationSettings['eveningHour'] ?? 17,
                _notificationSettings['eveningMinute'] ?? 0,
              )),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: _notificationSettings['eveningHour'] ?? 17,
                    minute: _notificationSettings['eveningMinute'] ?? 0,
                  ),
                );
                if (time != null) {
                  setState(() {
                    _notificationSettings['eveningHour'] = time.hour;
                    _notificationSettings['eveningMinute'] = time.minute;
                  });
                  _saveNotificationSettings();
                  Navigator.pop(context);
                  _showTimeCustomization(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveNotificationSettings() async {
    // Save to storage and update notifications
    // Implementation would use storage service
  }

  void _editQuadrant(
    BuildContext context,
    AppState appState,
    String quadrantId,
    String currentName,
  ) {
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Quadrant Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Quadrant name',
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                appState.updateQuadrant(quadrantId,
                    name: controller.text.trim());
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
