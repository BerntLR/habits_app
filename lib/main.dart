import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'bullpeak/app_accent.dart';
import 'bullpeak/theme.dart';

import 'l10n/app_localizations.dart';
import 'services/habit_service.dart';
import 'pages/today_page.dart';
import 'pages/habits_page.dart';
import 'pages/stats_page.dart';
import 'pages/info_page.dart';

void main() {
  runApp(const HabitsApp());
}

class HabitsApp extends StatelessWidget {
  const HabitsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HabitService()..init(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Karo's Habits",
        theme: BullPeakTheme.light(accent: AppAccent.color),
        darkTheme: BullPeakTheme.dark(accent: AppAccent.color),
        themeMode: ThemeMode.system,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: const Locale('en'),
        supportedLocales: const [Locale('en')],
        home: const IntroFlowPage(),
      ),
    );
  }
}

class IntroFlowPage extends StatefulWidget {
  const IntroFlowPage({super.key});

  @override
  State<IntroFlowPage> createState() => _IntroFlowPageState();
}

class _IntroFlowPageState extends State<IntroFlowPage>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  late final String _randomComic;

  int _step = 0;

  final List<String> _comics = const [
    'assets/tegneserie_1.png',
    'assets/tegneserie_2.png',
    'assets/tegneserie_3.png',
  ];

  late final List<String> _sequence;

  @override
  void initState() {
    super.initState();

    _randomComic = _comics[Random().nextInt(_comics.length)];

    _sequence = [
      'assets/emblem.png', // emblem
      _randomComic, // ÉN tilfeldig stripe
    ];

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playSequence();
    });
  }

  Future<void> _playSequence() async {
    for (int i = 0; i < _sequence.length; i++) {
      setState(() => _step = i);

      await _fadeController.forward();
      await Future.delayed(const Duration(milliseconds: 1500));
      await _fadeController.reverse();
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeShell()),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Image.asset(
            _sequence[_step],
            width: MediaQuery.of(context).size.width * (_step == 0 ? 0.55 : 0.75),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}


class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    TodayPage(),
    HabitsPage(),
    StatsPage(),
    InfoPage(),
  ];


  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      body: _pages[_currentIndex],
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
          const NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info),
            label: "Info",
          ),
        ],

      ),
    );
  }
}
