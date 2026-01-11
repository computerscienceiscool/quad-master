import 'dart:math' as math;
import 'package:flutter/material.dart';

class ColorUtils {
  /// Calculate relative luminance of a color
  /// Based on WCAG 2.0 formula
  static double getLuminance(Color color) {
    final r = _linearize(color.red / 255);
    final g = _linearize(color.green / 255);
    final b = _linearize(color.blue / 255);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  static double _linearize(double value) {
    return value <= 0.03928
        ? value / 12.92
        : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
  }

  /// Get contrasting text color (black or white) for a background
  static Color getContrastingTextColor(Color background) {
    final luminance = getLuminance(background);
    // Use white text for dark backgrounds, black for light
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Check if a color is considered "light"
  static bool isLight(Color color) {
    return getLuminance(color) > 0.5;
  }

  /// Preset color palette for quadrants
  static final List<Color> quadrantColors = [
    const Color(0xFFFFEB3B), // Yellow
    const Color(0xFFF44336), // Red
    const Color(0xFF4CAF50), // Green
    const Color(0xFF2196F3), // Blue
    const Color(0xFF9C27B0), // Purple
    const Color(0xFFFF9800), // Orange
    const Color(0xFF00BCD4), // Cyan
    const Color(0xFFE91E63), // Pink
    const Color(0xFF607D8B), // Blue Grey
    const Color(0xFF795548), // Brown
    const Color(0xFF009688), // Teal
    const Color(0xFF3F51B5), // Indigo
  ];

  /// Default colors for the four quadrants
  static final List<Color> defaultQuadrantColors = [
    const Color(0xFFFFEB3B), // Top-left: Yellow
    const Color(0xFFF44336), // Top-right: Red
    const Color(0xFF4CAF50), // Bottom-left: Green
    const Color(0xFF2196F3), // Bottom-right: Blue
  ];
}
