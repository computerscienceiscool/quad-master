enum TaskFrequency { daily, weekly }

class Task {
  final String id;
  final String quadrantId;
  String name;
  TaskFrequency frequency;
  bool isCompleted;
  DateTime? completedAt;
  
  // History tracking (new in v2)
  List<DateTime> completionHistory;
  int currentStreak;
  DateTime? lastCompletedDate;

  Task({
    required this.id,
    required this.quadrantId,
    required this.name,
    required this.frequency,
    this.isCompleted = false,
    this.completedAt,
    List<DateTime>? completionHistory,
    this.currentStreak = 0,
    this.lastCompletedDate,
  }) : completionHistory = completionHistory ?? [];

  /// Check if task should be reset based on current time
  bool shouldReset(DateTime now) {
    if (!isCompleted || completedAt == null) return false;

    if (frequency == TaskFrequency.daily) {
      // Reset if completed on a different day
      return !_isSameDay(completedAt!, now);
    } else {
      // Reset if completed in a different week (week starts Sunday)
      return !_isSameWeek(completedAt!, now);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isSameWeek(DateTime a, DateTime b) {
    // Dart weekday: Mon=1, Tue=2, ... Sat=6, Sun=7
    // weekday % 7 gives: Mon=1, ... Sat=6, Sun=0 (days since Sunday)
    final sundayA = a.subtract(Duration(days: a.weekday % 7));
    final sundayB = b.subtract(Duration(days: b.weekday % 7));
    return _isSameDay(sundayA, sundayB);
  }

  /// Mark task as completed
  void complete() {
    isCompleted = true;
    final now = DateTime.now();
    completedAt = now;
    
    // Add to history
    completionHistory.add(now);
    
    // Update streak
    _updateStreak(now);
  }

  /// Update streak calculation
  void _updateStreak(DateTime completionDate) {
    if (lastCompletedDate == null) {
      // First completion
      currentStreak = 1;
      lastCompletedDate = completionDate;
      return;
    }

    if (frequency == TaskFrequency.daily) {
      // Check if completed yesterday or today
      final yesterday = completionDate.subtract(const Duration(days: 1));
      if (_isSameDay(lastCompletedDate!, yesterday) || 
          _isSameDay(lastCompletedDate!, completionDate)) {
        currentStreak++;
      } else {
        // Streak broken
        currentStreak = 1;
      }
    } else {
      // Weekly: check if completed last week or this week
      final lastWeek = completionDate.subtract(const Duration(days: 7));
      if (_isSameWeek(lastCompletedDate!, lastWeek) || 
          _isSameWeek(lastCompletedDate!, completionDate)) {
        currentStreak++;
      } else {
        // Streak broken
        currentStreak = 1;
      }
    }
    
    lastCompletedDate = completionDate;
  }

  /// Mark task as not completed (undo)
  void uncomplete() {
    isCompleted = false;
    completedAt = null;
    
    // Remove last completion from history
    if (completionHistory.isNotEmpty) {
      completionHistory.removeLast();
    }
    
    // Recalculate streak
    _recalculateStreak();
  }

  /// Recalculate streak from history
  void _recalculateStreak() {
    if (completionHistory.isEmpty) {
      currentStreak = 0;
      lastCompletedDate = null;
      return;
    }

    // Sort history
    completionHistory.sort();
    
    // Start from most recent
    currentStreak = 1;
    lastCompletedDate = completionHistory.last;
    
    for (int i = completionHistory.length - 2; i >= 0; i--) {
      final current = completionHistory[i + 1];
      final previous = completionHistory[i];
      
      if (frequency == TaskFrequency.daily) {
        final yesterday = current.subtract(const Duration(days: 1));
        if (_isSameDay(previous, yesterday)) {
          currentStreak++;
        } else {
          break; // Streak broken
        }
      } else {
        final lastWeek = current.subtract(const Duration(days: 7));
        if (_isSameWeek(previous, lastWeek)) {
          currentStreak++;
        } else {
          break; // Streak broken
        }
      }
    }
  }

  /// Reset task for new period
  void reset() {
    isCompleted = false;
    completedAt = null;
    // Keep history and streak
  }

  /// Get completion count for a specific period
  int getCompletionsInPeriod(DateTime start, DateTime end) {
    return completionHistory
        .where((date) => date.isAfter(start) && date.isBefore(end))
        .length;
  }

  /// Get recent history (last 90 days to prevent storage bloat)
  List<DateTime> get recentHistory {
    final cutoff = DateTime.now().subtract(const Duration(days: 90));
    return completionHistory.where((d) => d.isAfter(cutoff)).toList();
  }

  /// Cleanup old history (keep only 90 days)
  void cleanupOldHistory() {
    completionHistory = recentHistory;
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'quadrantId': quadrantId,
        'name': name,
        'frequency': frequency.name,
        'isCompleted': isCompleted,
        'completedAt': completedAt?.toIso8601String(),
        'completionHistory': completionHistory.map((d) => d.toIso8601String()).toList(),
        'currentStreak': currentStreak,
        'lastCompletedDate': lastCompletedDate?.toIso8601String(),
      };

  /// Create from JSON
  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        quadrantId: json['quadrantId'],
        name: json['name'],
        frequency: TaskFrequency.values.byName(json['frequency']),
        isCompleted: json['isCompleted'] ?? false,
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null,
        completionHistory: json['completionHistory'] != null
            ? (json['completionHistory'] as List)
                .map((d) => DateTime.parse(d))
                .toList()
            : [],
        currentStreak: json['currentStreak'] ?? 0,
        lastCompletedDate: json['lastCompletedDate'] != null
            ? DateTime.parse(json['lastCompletedDate'])
            : null,
      );

  /// Create a copy with optional new values
  Task copyWith({
    String? name,
    TaskFrequency? frequency,
    bool? isCompleted,
    DateTime? completedAt,
    List<DateTime>? completionHistory,
    int? currentStreak,
    DateTime? lastCompletedDate,
  }) =>
      Task(
        id: id,
        quadrantId: quadrantId,
        name: name ?? this.name,
        frequency: frequency ?? this.frequency,
        isCompleted: isCompleted ?? this.isCompleted,
        completedAt: completedAt ?? this.completedAt,
        completionHistory: completionHistory ?? List.from(this.completionHistory),
        currentStreak: currentStreak ?? this.currentStreak,
        lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      );
}
