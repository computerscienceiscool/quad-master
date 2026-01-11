import 'quadrant.dart';

class Board {
  final String id;
  String name;
  final List<Quadrant> quadrants;

  Board({
    required this.id,
    required this.name,
    required this.quadrants,
  });

  /// Get quadrant by ID
  Quadrant? getQuadrant(String id) {
    try {
      return quadrants.firstWhere((q) => q.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get quadrant by index (0-3)
  Quadrant getQuadrantByIndex(int index) => quadrants[index];

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'quadrants': quadrants.map((q) => q.toJson()).toList(),
      };

  /// Create from JSON
  factory Board.fromJson(Map<String, dynamic> json) => Board(
        id: json['id'],
        name: json['name'],
        quadrants:
            (json['quadrants'] as List).map((q) => Quadrant.fromJson(q)).toList(),
      );

  /// Create a copy with optional new values
  Board copyWith({String? name, List<Quadrant>? quadrants}) => Board(
        id: id,
        name: name ?? this.name,
        quadrants: quadrants ?? this.quadrants,
      );
}
