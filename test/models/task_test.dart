import 'package:flutter_test/flutter_test.dart';
import 'package:quad_master/models/task.dart';

void main() {
  group('Task', () {
    group('creation', () {
      test('creates with required fields', () {
        final task = Task(
          id: 'test-id',
          quadrantId: 'quad-1',
          name: 'Test Task',
          frequency: TaskFrequency.daily,
        );

        expect(task.id, 'test-id');
        expect(task.quadrantId, 'quad-1');
        expect(task.name, 'Test Task');
        expect(task.frequency, TaskFrequency.daily);
        expect(task.isCompleted, false);
        expect(task.completedAt, isNull);
        expect(task.completionHistory, isEmpty);
        expect(task.currentStreak, 0);
        expect(task.lastCompletedDate, isNull);
      });

      test('creates with optional fields', () {
        final completedAt = DateTime(2026, 1, 10);
        final history = [DateTime(2026, 1, 9), DateTime(2026, 1, 10)];

        final task = Task(
          id: 'test-id',
          quadrantId: 'quad-1',
          name: 'Test Task',
          frequency: TaskFrequency.daily,
          isCompleted: true,
          completedAt: completedAt,
          completionHistory: history,
          currentStreak: 2,
          lastCompletedDate: completedAt,
        );

        expect(task.isCompleted, true);
        expect(task.completedAt, completedAt);
        expect(task.completionHistory, history);
        expect(task.currentStreak, 2);
      });
    });

    group('shouldReset', () {
      test('returns false when not completed', () {
        final task = Task(
          id: 'test-id',
          quadrantId: 'quad-1',
          name: 'Test Task',
          frequency: TaskFrequency.daily,
        );

        expect(task.shouldReset(DateTime.now()), false);
      });

      test('daily task resets on different day', () {
        final task = Task(
          id: 'test-id',
          quadrantId: 'quad-1',
          name: 'Test Task',
          frequency: TaskFrequency.daily,
          isCompleted: true,
          completedAt: DateTime(2026, 1, 10, 15, 0),
        );

        // Same day - should not reset
        expect(task.shouldReset(DateTime(2026, 1, 10, 23, 59)), false);

        // Next day - should reset
        expect(task.shouldReset(DateTime(2026, 1, 11, 0, 1)), true);
      });

      test('weekly task resets on different week', () {
        // Jan 5, 2026 is Monday (week of Jan 4 Sunday)
        final task = Task(
          id: 'test-id',
          quadrantId: 'quad-1',
          name: 'Test Task',
          frequency: TaskFrequency.weekly,
          isCompleted: true,
          completedAt: DateTime(2026, 1, 5),
        );

        // Same week - Jan 10 is Saturday, same week as Jan 5
        expect(task.shouldReset(DateTime(2026, 1, 10)), false);

        // Next week - Jan 11 is Sunday (new week starts)
        expect(task.shouldReset(DateTime(2026, 1, 11)), true);
      });
    });

    group('complete', () {
      test('marks task completed with timestamp', () {
        final task = Task(
          id: 'test-id',
          quadrantId: 'quad-1',
          name: 'Test Task',
          frequency: TaskFrequency.daily,
        );

        task.complete();

        expect(task.isCompleted, true);
        expect(task.completedAt, isNotNull);
        expect(task.completionHistory, hasLength(1));
        expect(task.currentStreak, 1);
        expect(task.lastCompletedDate, isNotNull);
      });

      test('first completion sets streak to 1', () {
        final task = Task(
          id: 'test-id',
          quadrantId: 'quad-1',
          name: 'Test Task',
          frequency: TaskFrequency.daily,
        );

        task.complete();

        expect(task.currentStreak, 1);
      });
    });

    group('streak calculation', () {
      test('daily streak increments for consecutive days', () {
        final now = DateTime.now();
        final yesterday = DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 1));

        final task = Task(
          id: 'test-id',
          quadrantId: 'quad-1',
          name: 'Test Task',
          frequency: TaskFrequency.daily,
          completionHistory: [yesterday],
          currentStreak: 1,
          lastCompletedDate: yesterday,
        );

        task.complete();

        expect(task.currentStreak, 2);
      });

      test('daily streak resets after gap', () {
        final now = DateTime.now();
        final twoDaysAgo = DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 2));

        final task = Task(
          id: 'test-id',
          quadrantId: 'quad-1',
          name: 'Test Task',
          frequency: TaskFrequency.daily,
          completionHistory: [twoDaysAgo],
          currentStreak: 5,
          lastCompletedDate: twoDaysAgo,
        );

        task.complete();

        expect(task.currentStreak, 1);
      });

      test('same day re-completion allowed', () {
        // Task completed earlier today, completing again should still count
        final now = DateTime.now();
        final earlierToday = DateTime(now.year, now.month, now.day, 8, 0);

        final task = Task(
          id: 'test-id',
          quadrantId: 'quad-1',
          name: 'Test Task',
          frequency: TaskFrequency.daily,
          completionHistory: [earlierToday],
          currentStreak: 1,
          lastCompletedDate: earlierToday,
        );

        task.complete();

        // Same day completion increments streak
        expect(task.currentStreak, 2);
      });
    });

    group('uncomplete', () {
      test('marks task not completed', () {
        final task = Task(
          id: 'test-id',
          quadrantId: 'quad-1',
          name: 'Test Task',
          frequency: TaskFrequency.daily,
          isCompleted: true,
          completedAt: DateTime.now(),
          completionHistory: [DateTime.now()],
          currentStreak: 1,
        );

        task.uncomplete();

        expect(task.isCompleted, false);
        expect(task.completedAt, isNull);
      });

      test('removes last completion from history', () {
        final history = [
          DateTime(2026, 1, 9),
          DateTime(2026, 1, 10),
        ];

        final task = Task(
          id: 'test-id',
          quadrantId: 'quad-1',
          name: 'Test Task',
          frequency: TaskFrequency.daily,
          isCompleted: true,
          completedAt: history.last,
          completionHistory: List.from(history),
          currentStreak: 2,
        );

        task.uncomplete();

        expect(task.completionHistory, hasLength(1));
        expect(task.completionHistory.first, history.first);
      });

      test('recalculates streak after undo', () {
        final history = [
          DateTime(2026, 1, 9),
          DateTime(2026, 1, 10),
          DateTime(2026, 1, 11),
        ];

        final task = Task(
          id: 'test-id',
          quadrantId: 'quad-1',
          name: 'Test Task',
          frequency: TaskFrequency.daily,
          isCompleted: true,
          completedAt: history.last,
          completionHistory: List.from(history),
          currentStreak: 3,
        );

        task.uncomplete();

        expect(task.currentStreak, 2);
        expect(task.lastCompletedDate, history[1]);
      });

      test('streak becomes 0 when history empty', () {
        final task = Task(
          id: 'test-id',
          quadrantId: 'quad-1',
          name: 'Test Task',
          frequency: TaskFrequency.daily,
          isCompleted: true,
          completedAt: DateTime.now(),
          completionHistory: [DateTime.now()],
          currentStreak: 1,
        );

        task.uncomplete();

        expect(task.currentStreak, 0);
        expect(task.lastCompletedDate, isNull);
      });
    });

    group('reset', () {
      test('clears completion but keeps history', () {
        final history = [DateTime(2026, 1, 9), DateTime(2026, 1, 10)];

        final task = Task(
          id: 'test-id',
          quadrantId: 'quad-1',
          name: 'Test Task',
          frequency: TaskFrequency.daily,
          isCompleted: true,
          completedAt: history.last,
          completionHistory: List.from(history),
          currentStreak: 2,
        );

        task.reset();

        expect(task.isCompleted, false);
        expect(task.completedAt, isNull);
        expect(task.completionHistory, hasLength(2));
        expect(task.currentStreak, 2);
      });
    });

    group('getCompletionsInPeriod', () {
      test('counts completions in date range', () {
        final history = [
          DateTime(2026, 1, 5),
          DateTime(2026, 1, 10),
          DateTime(2026, 1, 15),
          DateTime(2026, 1, 20),
        ];

        final task = Task(
          id: 'test-id',
          quadrantId: 'quad-1',
          name: 'Test Task',
          frequency: TaskFrequency.daily,
          completionHistory: history,
        );

        final count = task.getCompletionsInPeriod(
          DateTime(2026, 1, 8),
          DateTime(2026, 1, 18),
        );

        expect(count, 2);
      });
    });

    group('JSON serialization', () {
      test('toJson includes all fields', () {
        final completedAt = DateTime(2026, 1, 10, 15, 30);
        final history = [DateTime(2026, 1, 9), DateTime(2026, 1, 10)];

        final task = Task(
          id: 'test-id',
          quadrantId: 'quad-1',
          name: 'Test Task',
          frequency: TaskFrequency.daily,
          isCompleted: true,
          completedAt: completedAt,
          completionHistory: history,
          currentStreak: 2,
          lastCompletedDate: completedAt,
        );

        final json = task.toJson();

        expect(json['id'], 'test-id');
        expect(json['quadrantId'], 'quad-1');
        expect(json['name'], 'Test Task');
        expect(json['frequency'], 'daily');
        expect(json['isCompleted'], true);
        expect(json['completedAt'], completedAt.toIso8601String());
        expect(json['completionHistory'], hasLength(2));
        expect(json['currentStreak'], 2);
      });

      test('fromJson creates equivalent task', () {
        final original = Task(
          id: 'test-id',
          quadrantId: 'quad-1',
          name: 'Test Task',
          frequency: TaskFrequency.weekly,
          isCompleted: true,
          completedAt: DateTime(2026, 1, 10),
          completionHistory: [DateTime(2026, 1, 3), DateTime(2026, 1, 10)],
          currentStreak: 2,
          lastCompletedDate: DateTime(2026, 1, 10),
        );

        final json = original.toJson();
        final restored = Task.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.quadrantId, original.quadrantId);
        expect(restored.name, original.name);
        expect(restored.frequency, original.frequency);
        expect(restored.isCompleted, original.isCompleted);
        expect(restored.currentStreak, original.currentStreak);
        expect(restored.completionHistory, hasLength(2));
      });

      test('fromJson handles null optional fields', () {
        final json = {
          'id': 'test-id',
          'quadrantId': 'quad-1',
          'name': 'Test Task',
          'frequency': 'daily',
        };

        final task = Task.fromJson(json);

        expect(task.isCompleted, false);
        expect(task.completedAt, isNull);
        expect(task.completionHistory, isEmpty);
        expect(task.currentStreak, 0);
      });
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        final original = Task(
          id: 'test-id',
          quadrantId: 'quad-1',
          name: 'Original Name',
          frequency: TaskFrequency.daily,
          currentStreak: 5,
        );

        final copy = original.copyWith(
          name: 'New Name',
          frequency: TaskFrequency.weekly,
        );

        expect(copy.id, original.id);
        expect(copy.quadrantId, original.quadrantId);
        expect(copy.name, 'New Name');
        expect(copy.frequency, TaskFrequency.weekly);
        expect(copy.currentStreak, 5);
      });

      test('creates independent copy of history', () {
        final history = [DateTime(2026, 1, 10)];
        final original = Task(
          id: 'test-id',
          quadrantId: 'quad-1',
          name: 'Test',
          frequency: TaskFrequency.daily,
          completionHistory: history,
        );

        final copy = original.copyWith();
        copy.completionHistory.add(DateTime(2026, 1, 11));

        expect(original.completionHistory, hasLength(1));
        expect(copy.completionHistory, hasLength(2));
      });
    });

    group('cleanupOldHistory', () {
      test('removes entries older than 90 days', () {
        final now = DateTime.now();
        final history = [
          now.subtract(const Duration(days: 100)),
          now.subtract(const Duration(days: 95)),
          now.subtract(const Duration(days: 50)),
          now.subtract(const Duration(days: 10)),
        ];

        final task = Task(
          id: 'test-id',
          quadrantId: 'quad-1',
          name: 'Test',
          frequency: TaskFrequency.daily,
          completionHistory: history,
        );

        task.cleanupOldHistory();

        expect(task.completionHistory, hasLength(2));
      });
    });
  });
}
