import 'package:flutter/material.dart';
import '../utils/color_utils.dart';

class Quadrant {
  final String id;
  String name;
  Color color;

  Quadrant({
    required this.id,
    required this.name,
    required this.color,
  });

  /// Get text color (black or white) based on background brightness
  Color get textColor => ColorUtils.getContrastingTextColor(color);

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color.toARGB32(),
      };

  /// Create from JSON
  factory Quadrant.fromJson(Map<String, dynamic> json) => Quadrant(
        id: json['id'],
        name: json['name'],
        color: Color(json['color']),
      );

  /// Create a copy with optional new values
  Quadrant copyWith({String? name, Color? color}) => Quadrant(
        id: id,
        name: name ?? this.name,
        color: color ?? this.color,
      );
}
