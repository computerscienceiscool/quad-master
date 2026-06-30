import 'task.dart';

class TaskTemplate {
  final String id;
  final String name;
  final String quadrantId;
  final TaskFrequency frequency;
  final DateTime createdAt;

  TaskTemplate({
    required this.id,
    required this.name,
    required this.quadrantId,
    required this.frequency,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'quadrantId': quadrantId,
        'frequency': frequency.name,
        'createdAt': createdAt.toIso8601String(),
      };

  /// Create from JSON
  factory TaskTemplate.fromJson(Map<String, dynamic> json) => TaskTemplate(
        id: json['id'],
        name: json['name'],
        quadrantId: json['quadrantId'],
        frequency: TaskFrequency.values.byName(json['frequency']),
        createdAt: DateTime.parse(json['createdAt']),
      );

  /// Create a copy with optional new values
  TaskTemplate copyWith({
    String? name,
    String? quadrantId,
    TaskFrequency? frequency,
  }) =>
      TaskTemplate(
        id: id,
        name: name ?? this.name,
        quadrantId: quadrantId ?? this.quadrantId,
        frequency: frequency ?? this.frequency,
        createdAt: createdAt,
      );

  /// Convert template to a task
  Task toTask(String taskId) => Task(
        id: taskId,
        quadrantId: quadrantId,
        name: name,
        frequency: frequency,
      );
}
