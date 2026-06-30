import 'package:flutter/material.dart';

import '../models/quadrant.dart';

class QuadrantTile extends StatelessWidget {
  final Quadrant quadrant;
  final VoidCallback onTap;
  final int taskCount;

  const QuadrantTile({
    super.key,
    required this.quadrant,
    required this.onTap,
    this.taskCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: quadrant.color,
        child: Stack(
          children: [
            // Quadrant name (centered)
            Center(
              child: Text(
                quadrant.name,
                style: TextStyle(
                  color: quadrant.textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            // Task count badge (top-right)
            if (taskCount > 0)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '$taskCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
