import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

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
        title: const Text('Weekly Summary'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          const Text(
            'This Week\'s Progress',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getWeekRange(),
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),

          const SizedBox(height: 24),

          // Stats for each quadrant
          ...board.quadrants.map((quadrant) {
            final stats = appState.getQuadrantStats(quadrant.id);

            return _buildQuadrantCard(
              name: quadrant.name,
              color: quadrant.color,
              textColor: quadrant.textColor,
              dailyCompleted: stats['dailyCompleted'],
              dailyTotal: stats['dailyTotal'],
              weeklyCompleted: stats['weeklyCompleted'],
              weeklyTotal: stats['weeklyTotal'],
              averageStreak: stats['averageStreak'],
              bestStreak: stats['bestStreak'],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuadrantCard({
    required String name,
    required Color color,
    required Color textColor,
    required int dailyCompleted,
    required int dailyTotal,
    required int weeklyCompleted,
    required int weeklyTotal,
    required int averageStreak,
    required int bestStreak,
  }) {
    // Calculate percentages (avoid division by zero)
    final dailyPercent = dailyTotal > 0 ? dailyCompleted / dailyTotal : 0.0;
    final weeklyPercent =
        weeklyTotal > 0 ? weeklyCompleted / weeklyTotal : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (bestStreak > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Text(
                          _getStreakEmoji(bestStreak),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Best Streak: $bestStreak days',
                          style: TextStyle(
                            color: textColor.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Stats
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Daily stats
                _buildProgressRow(
                  label: 'Daily Tasks',
                  completed: dailyCompleted,
                  total: dailyTotal,
                  percent: dailyPercent,
                  color: color,
                ),

                const SizedBox(height: 16),

                // Weekly stats
                _buildProgressRow(
                  label: 'Weekly Tasks',
                  completed: weeklyCompleted,
                  total: weeklyTotal,
                  percent: weeklyPercent,
                  color: color,
                ),

                // Streak info
                if (averageStreak > 0) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '🔥',
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Average Streak: $averageStreak ${averageStreak == 1 ? "day" : "days"}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow({
    required String label,
    required int completed,
    required int total,
    required double percent,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              '$completed / $total',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  String _getStreakEmoji(int streak) {
    if (streak >= 30) return '🏆';
    if (streak >= 14) return '⭐';
    if (streak >= 7) return '💪';
    return '🔥';
  }

  String _getWeekRange() {
    final now = DateTime.now();
    // Get Sunday of this week
    final sunday = now.subtract(Duration(days: now.weekday % 7));
    final saturday = sunday.add(const Duration(days: 6));

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    return '${months[sunday.month - 1]} ${sunday.day} - ${months[saturday.month - 1]} ${saturday.day}';
  }
}
