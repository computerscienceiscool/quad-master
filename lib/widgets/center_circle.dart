import 'package:flutter/material.dart';

class CenterCircle extends StatelessWidget {
  final VoidCallback onDailyTap;
  final VoidCallback onWeeklyTap;
  final double dailyCompletionPercentage; // 0.0 to 1.0

  const CenterCircle({
    super.key,
    required this.onDailyTap,
    required this.onWeeklyTap,
    this.dailyCompletionPercentage = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.35;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Progress ring (outer)
        SizedBox(
          width: size + 16,
          height: size + 16,
          child: CircularProgressIndicator(
            value: dailyCompletionPercentage,
            strokeWidth: 6,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation(
              _getProgressColor(dailyCompletionPercentage),
            ),
          ),
        ),

        // Inner circle with Daily/Weekly split
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: Column(
              children: [
                // Top half - Daily (black)
                Expanded(
                  child: GestureDetector(
                    onTap: onDailyTap,
                    child: Container(
                      color: Colors.black,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Daily',
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (dailyCompletionPercentage > 0)
                              Text(
                                '${(dailyCompletionPercentage * 100).round()}%',
                                style: TextStyle(
                                  color: Colors.amber.withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom half - Weekly (white)
                Expanded(
                  child: GestureDetector(
                    onTap: onWeeklyTap,
                    child: Container(
                      color: Colors.white,
                      child: const Center(
                        child: Text(
                          'Weekly',
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 0.8) return Colors.green;
    if (percentage >= 0.5) return Colors.amber;
    if (percentage >= 0.2) return Colors.orange;
    return Colors.red;
  }
}
