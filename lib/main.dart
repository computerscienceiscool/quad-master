import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/quick_actions_service.dart';
import 'models/app_state.dart';
import 'screens/home_screen.dart';
import 'screens/setup_screen.dart';

/// Clears undo state when navigating between screens
class UndoClearingObserver extends NavigatorObserver {
  final AppState appState;

  UndoClearingObserver(this.appState);

  @override
  void didPush(Route route, Route? previousRoute) {
    appState.clearUndoState();
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    appState.clearUndoState();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize services
  final storageService = StorageService();
  await storageService.init();

  final notificationService = NotificationService();
  await notificationService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppState(storageService, notificationService),
        ),
      ],
      child: const QuadMasterApp(),
    ),
  );
}

class QuadMasterApp extends StatefulWidget {
  const QuadMasterApp({super.key});

  @override
  State<QuadMasterApp> createState() => _QuadMasterAppState();
}

class _QuadMasterAppState extends State<QuadMasterApp> {
  final QuickActionsService _quickActions = QuickActionsService();
  String? _initialQuickAction;

  @override
  void initState() {
    super.initState();
    
    // Initialize quick actions
    _quickActions.initialize((String action) {
      setState(() {
        _initialQuickAction = action;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return MaterialApp(
          title: 'Quad Master',
          debugShowCheckedModeBanner: false,
          navigatorObservers: [UndoClearingObserver(appState)],
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Roboto',
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.amber,
              brightness: Brightness.light,
            ),
          ),
          home: !appState.isInitialized
              ? const Center(child: CircularProgressIndicator())
              : appState.hasBoard
                  ? HomeScreen(initialAction: _initialQuickAction)
                  : const SetupScreen(),
        );
      },
    );
  }
}
