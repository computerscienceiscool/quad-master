# Quad Master - Issue Tracker

## Bugs

### High Priority
017 ALL: Array index access without bounds check in home_screen.dart (lines 218, 228, 245, 255)
018 ALL: board.quadrants.first accessed without empty check in home_screen.dart (line 80)
019 ALL: Array index access without validation in templates_screen.dart (line 138)
020 ALL: Notification settings not saved - _saveNotificationSettings() is empty stub (settings_screen.dart:320-323)
021 ALL: Notification settings not loaded from storage - _loadNotificationSettings() hardcodes defaults (settings_screen.dart:26-40)
022 ALL: Stream subscription memory leak in home_widget_service.dart (line 55-59)
023 ALL: No validation that board has exactly 4 quadrants in createBoard() (app_state.dart:82)

### Medium Priority
004 ALL: Missing error handling for Hive storage operations
024 ALL: Blank catch block silently swallows migration errors (storage_service.dart:79)
025 ALL: Race condition - multiple notification scheduling calls without synchronization (app_state.dart:392)
026 ALL: TextEditingController not disposed in dialog builders (home_screen.dart, settings_screen.dart, templates_screen.dart)
027 ALL: Missing JSON parsing error handling in storage_service.dart (lines 95, 122, 144)
028 ALL: Force unwrap of lastCompletedTask could fail if state changes (pillar_screen.dart:221)

### Low Priority
029 ALL: Color.lerp null return force unwrapped (setup_screen.dart:177)
030 ALL: Potential division by zero in average streak calculation (app_state.dart:418)
031 ALL: Task completion timestamp precision issues near midnight (task.dart:54-63)

## Features

### High Priority
032 ALL: Implement notification settings persistence and loading

### Medium Priority
033 ALL: Implement home widget click handler (home_widget_service.dart:65-68)
034 ALL: Implement quick actions native code for iOS/Android

### Low Priority
035 ALL: Add silent failure logging for home widget updates (home_widget_service.dart:44-45)

## Improvements

### High Priority
007 ALL: Add widget tests for core UI components

### Medium Priority
009 ALL: Optimize summary stats calculation with memoization
036 ALL: Standardize error handling patterns across services

### Low Priority
037 ALL: Extract magic numbers to constants (streak milestones, cleanup days, widget limits)
038 ALL: Add structured logging throughout app for debugging
039 ALL: Improve task name validation (length limits, whitespace-only, special chars)
040 ALL: Prevent duplicate quadrant colors in setup screen

## Platform-Specific

### Windows
041 WINDOWS: Notifications not supported - only Android/iOS configured (notification_service.dart:25-38)

### Android
042 ANDROID: Native WidgetProvider not implemented for home widgets
043 ANDROID: Native shortcuts.xml not implemented for quick actions

### iOS
044 IOS: Native Widget extension not implemented (requires Swift)
045 IOS: Native Info.plist shortcuts config not implemented

### Web
046 WEB: HomeWidget package not supported - needs conditional disable/fallback

### Kindle Fire

### Linux
047 LINUX: Notifications not supported - only Android/iOS configured

---

## DONE

✓ 006 ALL: Add unit tests for Task model and AppState (2026-01-11)
✓ 010 ALL: Add navigation observer for automatic undo state clearing (2026-01-11)
✓ 002 ALL: Undo timer uses Future.delayed instead of cancellable Timer (2026-01-11)
✓ 003 ALL: No validation of quadrantId before adding task (2026-01-11)
✓ 001 ALL: Unsafe firstWhere() calls crash app if ID not found (2026-01-11)
✓ 005 ALL: Debug print() statements in production code (2026-01-11)
✓ 013 ALL: Fix deprecated Color.withOpacity - use withValues() (2026-01-11)
✓ 014 ALL: Fix deprecated TextFormField value - use initialValue (2026-01-11)
✓ 015 ALL: Fix deprecated Color.value - use toARGB32 (2026-01-11)
✓ 016 ALL: Fix deprecated color accessors red/green/blue (2026-01-11)
✓ 012 ALL: Fix CLAUDE.md file naming docs (2026-01-10)
✓ 008 ALL: Clarify emoji policy - allowed for streak badges, notifications, share text (2026-01-10)
✓ 011 ALL: Improve week calculation clarity in Task model (2026-01-10)

