# claude.md
This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
**Quad Master** is a Flutter productivity app that organizes tasks into four customizable quadrants with streak tracking, templates, and smart notifications. 

**Tagline:** "Four corners. Total control."

**Development Stage:** Alpha

**Platform Priority:** Windows > Kindle Fire > Android > iOS > Web > Desktop (macOS/Linux)

## Design & Code Preferences

### UI/UX Design
- Sleek, minimalist design
- No emojis in UI or code (exceptions: streak badges, notifications, share text)
- No icons unless explicitly agreed upon
- Clean, professional aesthetic

### Code Style
- **File naming:** lowercase_with_underscores (e.g., `app_state.dart`, `storage_service.dart`) per Dart convention
- **No ALL CAPS** for source code files (exception: project files like README.md, CLAUDE.md, TODO/)
- **No em dashes** or LLM-specific characters in code or comments

### Writing Style
- Clear, concise documentation
- Professional tone
- No unnecessary formatting or special characters

## TODO System

### Issue Tracking
All bugs and features are tracked in `TODO/TODO.md` with a 3-digit number (001-999):

**Format:** `###  PLATFORM: Title of issue`
- Example: `020 WINDOWS: Fix font in privacy policy`
- Priority assigned by Claude unless specified otherwise
- Organized by category: Bugs, Features, Improvements, Platform-Specific
- Priority levels: High, Medium, Low

### Detailed Documentation
For complex issues, create a separate markdown file in the `TODO/` folder:
- **Filename format:** `###-title-in-lowercase-with-dashes.md`
- Example: `020-fix-font-in-privacy-policy.md`
- **Reference in TODO.md:** `020 WINDOWS: Fix font in privacy policy (see 020-fix-font-in-privacy-policy.md)`

**What to include (case-by-case):**
- Problem description
- Steps to reproduce
- Proposed solution
- Code snippets/examples
- Screenshots or references
- Any other helpful context

### Completing Issues
- Move completed items from their category to the DONE section in TODO.md
- Add checkmark and completion date: `✓ 020 WINDOWS: Fix font in privacy policy (2026-01-10)`
- Leave detailed .md files in TODO folder for reference

## Build Commands
```bash
# Get dependencies
flutter pub get

# Run the app
flutter run

# Run on specific platform
flutter run -d windows
flutter run -d chrome
flutter run -d <device-id>

# Build for production
flutter build apk        # Android
flutter build ios        # iOS
flutter build web        # Web
flutter build windows    # Windows
flutter build macos      # macOS
flutter build linux      # Linux

# Run code generator (for Hive if adapters added)
flutter pub run build_runner build

# Clean build
flutter clean
flutter pub get
```

## Architecture

### State Management
- Uses **Provider** with a single `AppState` class (`lib/models/app_state.dart`)
- `AppState` extends `ChangeNotifier` and manages all app state
- Services (`StorageService`, `NotificationService`) are injected into `AppState`

### Data Persistence
- **Hive** for local storage with JSON serialization
- Four separate Hive boxes: `board`, `tasks`, `settings`, `templates`
- Schema versioning system with automatic migrations (current: v2)
- 90-day history cleanup to prevent storage bloat

### Key Models
- `Board` - Container for 4 quadrants
- `Quadrant` - Named section with color
- `Task` - Has frequency (daily/weekly), completion history, streak tracking
- `TaskTemplate` - Reusable task definitions

### Screen Flow
- `SetupScreen` - First-time board creation
- `HomeScreen` - 2x2 quadrant grid with progress ring
- `PillarScreen` - Single quadrant's tasks (daily/weekly tabs)
- `DailyScreen` / `WeeklyScreen` - Cross-quadrant task views
- `SummaryScreen` - Stats and streaks

### Services
- `StorageService` - Hive persistence with schema migrations
- `NotificationService` - 3 daily smart reminders (morning/midday/evening)
- `HomeWidgetService` - Home screen widgets (requires native code)
- `QuickActionsService` - App shortcuts (requires native code)

## Key Patterns

### Task Reset Logic
Tasks auto-reset based on frequency:
- Daily tasks reset at midnight (different day check)
- Weekly tasks reset on Sunday (same-week check using Sunday as week start)

### Streak Calculation
- Daily: consecutive days (allows same-day re-completion)
- Weekly: consecutive weeks
- Recalculated on undo from completion history

### Undo System
4-second undo window for task completion, stored in `_lastCompletedTask`

### Haptic Feedback
`HapticFeedback` calls on: task completion (medium), milestones (heavy), undo/delete (light)

## Dependencies

### Core Packages
- `provider` - State management
- `hive` / `hive_flutter` - Local storage
- `flutter_local_notifications` - Scheduled reminders
- `flutter_slidable` - Swipe actions on tasks
- `uuid` - ID generation

### Optional (require native implementation)
- `home_widget` - Home screen widgets
- `quick_actions` - App icon shortcuts

## Native Code Requirements

Home widgets and quick actions have Flutter service code but need platform-specific implementation:

### iOS
- Widget extension in Swift
- Info.plist shortcuts config

### Android
- WidgetProvider in Kotlin
- shortcuts.xml

**To disable these features:** Comment out the dependencies in `pubspec.yaml` and remove service imports.

## Testing

### Running Tests
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/models/task_test.dart
```

### Testing Strategy
- Unit tests for models and business logic
- Widget tests for UI components
- Integration tests for user flows
- Platform-specific testing required for Windows, Kindle, Android, iOS

## Common Issues & Troubleshooting

### Build Issues
- **Hive build errors:** Run `flutter pub run build_runner clean` then rebuild
- **Platform-specific builds:** Ensure platform tooling is installed (Visual Studio for Windows, Xcode for iOS/macOS)

### Storage Issues
- **Data migration failures:** Check schema version in `StorageService`
- **Storage bloat:** 90-day cleanup runs automatically; manual cleanup available in settings

### Notifications
- **Not firing:** Check platform permissions (iOS: requires user approval, Android: check notification channels)
- **Wrong timing:** Verify timezone handling in `NotificationService`

## Deployment

### Pre-release Checklist
- Run `flutter analyze` (no errors)
- Run all tests (`flutter test`)
- Test on all target platforms
- Verify notifications work on each platform
- Check app permissions are correctly configured
- Update version in `pubspec.yaml`

### Platform-Specific Deployment

#### Android
```bash
flutter build apk --release
flutter build appbundle --release  # For Play Store
```

#### iOS
```bash
flutter build ios --release
# Open in Xcode for signing and upload
```

#### Windows
```bash
flutter build windows --release
```

#### Web
```bash
flutter build web --release
```

## Project Structure
```
lib/
├── main.dart                    # App entry point
├── models/
│   ├── app_state.dart           # Main state management
│   ├── board.dart
│   ├── quadrant.dart
│   ├── task.dart
│   └── task_template.dart
├── services/
│   ├── storage_service.dart
│   ├── notification_service.dart
│   ├── home_widget_service.dart
│   └── quick_actions_service.dart
├── screens/
│   ├── setup_screen.dart
│   ├── home_screen.dart
│   ├── pillar_screen.dart
│   ├── daily_screen.dart
│   ├── weekly_screen.dart
│   └── summary_screen.dart
└── widgets/                     # Reusable UI components

TODO/
├── TODO.md                      # Issue tracking (bugs, features, improvements)
└── ###-issue-title.md           # Detailed documentation for complex issues
```

## Commit Guidelines
- **Staging:** Add files explicitly (e.g., `git add CLAUDE.md lib/main.dart`), not `git add .` or `git add -A`
- **Messages:** Short, imperative, capitalized (e.g., "Fix streak calculation bug")
- **Body:** Include bullet summaries per changed file when multiple files are modified
- **Timing:** Commit after completing issues or logical milestones; ensure app builds before committing
- **No co-author lines** - do not add Co-Authored-By footers

## Agent Instructions
- A message containing only `commit` means: stage and commit all current changes with a properly formatted message
- Use `git diff` to understand changes and generate an appropriate commit message
- Always verify the build passes before committing

## Local State & Generated Files
Do not commit (already in `.gitignore`):
- `.dart_tool/` - Dart tooling cache
- `build/` - Flutter build output
- `.flutter-plugins*` - Generated plugin files
- `*.iml` - IDE project files
- `.idea/` - IntelliJ/Android Studio settings
- `.claude/` - Claude Code local settings
- `TODO.d` - Temporary working file

## Notes
- See `TODO/TODO.md` for current bugs, features, and improvements
- Platform priority: Windows > Kindle Fire > Android > iOS > Web > Desktop
- All new code should follow the design and code preferences outlined above
