import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quad Master Privacy Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last Updated: ${DateTime.now().year}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              'Overview',
              'Quad Master is committed to protecting your privacy. This app is designed with privacy as a core principle - all your data stays on your device.',
            ),

            _buildSection(
              'Data We Collect',
              'Quad Master collects and stores the following information locally on your device:\n\n'
              '• Task names and descriptions\n'
              '• Task completion status and history (last 90 days)\n'
              '• Quadrant names and colors\n'
              '• Task templates you create\n'
              '• App preferences and notification settings\n'
              '• Streak counts and completion dates\n\n'
              'All of this data is stored exclusively on your device using local storage (Hive database). We do not have access to this data.',
            ),

            _buildSection(
              'How We Use Your Data',
              'The data collected is used solely to:\n\n'
              '• Display your tasks and quadrants\n'
              '• Calculate and show streak information\n'
              '• Send you scheduled notifications\n'
              '• Update home screen widgets\n'
              '• Provide weekly progress summaries\n\n'
              'Your data never leaves your device unless you explicitly share it using the Share feature.',
            ),

            _buildSection(
              'Data Storage Location',
              'All data is stored locally on your device in an encrypted database. We do not operate any servers that collect, store, or process your personal data.\n\n'
              'Current limitations:\n'
              '• No cloud backup (your data is only on this device)\n'
              '• No sync between devices\n'
              '• Data is lost if you uninstall the app without backing up',
            ),

            _buildSection(
              'Widgets and Lock Screen',
              'If you choose to add Quad Master widgets to your home screen or lock screen:\n\n'
              '• Task names and counts will be visible on your home screen\n'
              '• Lock screen widgets (iOS 16+) may display task information without unlocking your device\n'
              '• You control widget visibility through your device settings\n'
              '• Widgets only display data already stored on your device\n\n'
              'Be mindful of what task names you create if you use widgets in public spaces.',
            ),

            _buildSection(
              'Notifications',
              'Quad Master uses local notifications scheduled on your device:\n\n'
              '• Notifications are generated locally (not sent from a server)\n'
              '• You can enable/disable notifications in app settings\n'
              '• You can customize notification times\n'
              '• Notification content includes task counts and motivational messages\n\n'
              'No data is transmitted when sending notifications.',
            ),

            _buildSection(
              'Data Sharing',
              'Quad Master does not share your data with third parties. The only ways your data can leave your device:\n\n'
              '1. When you use the "Share" feature to export tasks as text\n'
              '2. When displayed in widgets (controlled by you)\n'
              '3. If you manually backup your device through iTunes/iCloud/Android Backup\n\n'
              'We do not sell, rent, or trade your personal information.',
            ),

            _buildSection(
              'Third-Party Services',
              'Quad Master does not use third-party analytics, advertising, or tracking services. The app uses these platform services:\n\n'
              '• Flutter framework (for app functionality)\n'
              '• Device notification system (for reminders)\n'
              '• Device storage (for local data)\n'
              '• Widget system (if you enable widgets)\n\n'
              'These are standard platform features and do not transmit your data to external servers.',
            ),

            _buildSection(
              'Data Retention',
              'Your data remains on your device until:\n\n'
              '• You manually delete tasks or quadrants\n'
              '• Task completion history older than 90 days (automatically cleaned)\n'
              '• You uninstall the app (all data is deleted)\n'
              '• You clear app data through device settings\n\n'
              'There is no server-side data retention because we do not collect data on servers.',
            ),

            _buildSection(
              'Children\'s Privacy',
              'Quad Master does not knowingly collect personal information from children. The app:\n\n'
              '• Does not require user accounts\n'
              '• Does not collect personal information\n'
              '• Does not contain advertising\n'
              '• Stores data only locally on the device\n\n'
              'Parents/guardians are responsible for monitoring their children\'s app usage.',
            ),

            _buildSection(
              'Your Rights',
              'You have complete control over your data:\n\n'
              '• Access: All your data is visible in the app\n'
              '• Modify: You can edit any task, template, or setting\n'
              '• Delete: You can delete individual items or clear all data\n'
              '• Export: Use the Share feature to export your data\n'
              '• Portability: Export as text format\n\n'
              'Since data is stored only on your device, you have full control.',
            ),

            _buildSection(
              'Data Security',
              'We take security seriously:\n\n'
              '• Data is stored in encrypted local database (Hive)\n'
              '• No network transmission of personal data\n'
              '• No user accounts (no password risks)\n'
              '• App follows platform security guidelines\n\n'
              'Your device\'s security features (passcode, biometrics) protect your data.',
            ),

            _buildSection(
              'International Users',
              'Quad Master can be used anywhere in the world. Since all data is stored locally on your device:\n\n'
              '• No cross-border data transfers\n'
              '• Complies with GDPR (EU)\n'
              '• Complies with CCPA (California)\n'
              '• No data residency concerns\n\n'
              'Your data stays in your jurisdiction on your device.',
            ),

            _buildSection(
              'Changes to Privacy Policy',
              'We may update this Privacy Policy from time to time. Changes will be posted:\n\n'
              '• In the app (this screen)\n'
              '• In app store listings\n'
              '• With updated "Last Updated" date at the top\n\n'
              'Continued use of the app after changes constitutes acceptance of the updated policy.',
            ),

            _buildSection(
              'Future Features',
              'We are planning features that may affect privacy:\n\n'
              '• Cloud sync: Optional backup to iCloud/Google Drive (you control this)\n'
              '• Sharing templates: Ability to share task templates with other users\n'
              '• Collaborative boards: Share boards with family/team members\n\n'
              'These features will be opt-in and clearly disclosed before implementation.',
            ),

            _buildSection(
              'Contact Us',
              'If you have questions about this Privacy Policy or your data:\n\n'
              'Email: privacy@quadmaster.app\n'
              'Website: www.quadmaster.app/privacy\n\n'
              'We will respond to privacy inquiries within 30 days.',
            ),

            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your privacy is protected:\n\n'
                    '• All data stays on your device\n'
                    '• No servers or cloud storage\n'
                    '• No tracking or analytics\n'
                    '• No ads or third parties\n'
                    '• You control all sharing\n'
                    '• Full data transparency',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Center(
              child: Text(
                'Quad Master - "Four corners. Total control."\nYour data. Your device. Your privacy.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
