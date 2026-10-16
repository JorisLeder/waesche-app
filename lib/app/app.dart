import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/debug/feasibility_screen.dart';
import '../features/debug/history_screen.dart';
import '../features/home/home_screen.dart';
import '../features/household/household_screen.dart';
import '../features/persons/persons_screen.dart';
import '../features/scan/scan_screen.dart';
import '../features/setup/setup_screen.dart';
import '../features/wardrobe/wardrobe_screen.dart';
import 'providers.dart';

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
    GoRoute(path: '/setup', builder: (_, _) => const SetupScreen()),
    GoRoute(path: '/scan', builder: (_, _) => const ScanScreen()),
    GoRoute(path: '/wardrobe', builder: (_, _) => const WardrobeScreen()),
    GoRoute(path: '/persons', builder: (_, _) => const PersonsScreen()),
    GoRoute(path: '/household', builder: (_, _) => const HouseholdScreen()),
    GoRoute(path: '/test', builder: (_, _) => const FeasibilityScreen()),
    GoRoute(path: '/history', builder: (_, _) => const HistoryScreen()),
  ],
);

class WaescheApp extends ConsumerStatefulWidget {
  const WaescheApp({super.key});

  @override
  ConsumerState<WaescheApp> createState() => _WaescheAppState();
}

class _WaescheAppState extends ConsumerState<WaescheApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Speicherbudget: Im Hintergrund wird das Modell sofort freigegeben.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      ref.read(gemmaServiceProvider).unload();
    }
  }

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF00897B);
    return MaterialApp.router(
      title: 'WäscheWer',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: ThemeData(colorSchemeSeed: seed, useMaterial3: true),
      darkTheme: ThemeData(colorSchemeSeed: seed, brightness: Brightness.dark, useMaterial3: true),
    );
  }
}
