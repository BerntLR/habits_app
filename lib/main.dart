import 'package:bullpeak_intro/bullpeak_intro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'bullpeak/app_accent.dart';
import 'bullpeak/theme.dart';
import 'l10n/app_locale.dart';
import 'l10n/app_localizations.dart';
import 'pages/habits_page.dart';
import 'pages/info_page.dart';
import 'pages/stats_page.dart';
import 'pages/today_page.dart';
import 'services/habit_service.dart';
import 'services/home_widget_service.dart';
import 'services/reminder_service.dart';

export 'l10n/app_locale.dart' show resolveAppLocale;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HabitsApp());
}

/// Keeps reminders and the home screen widget in step with the data.
void _connectSideEffects(HabitService service) {
  var lastRevision = -1;
  var lastTodayDone = -1;
  void sync() {
    if (!service.isInitialized) return;
    HomeWidgetService.instance.updateSoon(service);
    // Reminders depend on the habits and on whether today's are done.
    final now = DateTime.now();
    final todayDone = service
        .habitsForDate(now)
        .where((h) => service.isHabitDone(h.id, now))
        .map((h) => h.id.hashCode)
        .fold<int>(0, (a, b) => a ^ b);
    if (service.habitsRevision != lastRevision || todayDone != lastTodayDone) {
      lastRevision = service.habitsRevision;
      lastTodayDone = todayDone;
      ReminderService.instance.scheduleSoon(service);
    }
  }

  service.addListener(sync);
}

class HabitsApp extends StatelessWidget {
  const HabitsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final service = HabitService();
        _connectSideEffects(service);
        service.init();
        return service;
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Karos Habits',
        theme: BullPeakTheme.light(accent: AppAccent.color),
        darkTheme: BullPeakTheme.dark(accent: AppAccent.color),
        themeMode: ThemeMode.system,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        localeResolutionCallback: resolveAppLocale,
        home: const BullPeakIntro(next: HomeShell()),
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    TodayPage(),
    HabitsPage(),
    StatsPage(),
    InfoPage(),
  ];

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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // A new day may have started while the app was in the background.
      final service = context.read<HabitService>();
      HomeWidgetService.instance.updateSoon(service);
      ReminderService.instance.scheduleSoon(service);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.today_outlined),
            selectedIcon: const Icon(Icons.today),
            label: l.tabToday,
          ),
          NavigationDestination(
            icon: const Icon(Icons.list_alt_outlined),
            selectedIcon: const Icon(Icons.list_alt),
            label: l.tabHabits,
          ),
          NavigationDestination(
            icon: const Icon(Icons.insights_outlined),
            selectedIcon: const Icon(Icons.insights),
            label: l.tabStats,
          ),
          NavigationDestination(
            icon: const Icon(Icons.info_outline),
            selectedIcon: const Icon(Icons.info),
            label: l.tabInfo,
          ),
        ],
      ),
    );
  }
}
