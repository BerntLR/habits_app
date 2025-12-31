import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'services/habit_service.dart';
import 'pages/today_page.dart';
import 'pages/habits_page.dart';
import 'pages/stats_page.dart';

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
        theme: _buildKaroTheme(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
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
    'assets/splash/tegneserie_1.png',
    'assets/splash/tegneserie_2.png',
    'assets/splash/tegneserie_3.png',
  ];

  late final List<String> _sequence;

  @override
  void initState() {
    super.initState();

    _randomComic = _comics[Random().nextInt(_comics.length)];

    _sequence = [

      'assets/splash/emblem_mobil.png', // emblem
      _randomComic,                        // ÉN tilfeldig stripe
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
      await Future.delayed(
        Duration(milliseconds: i == 2 ? 3500 : 1500),
      );
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
      backgroundColor: const Color(0xFFF8E1B5),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Image.asset(
            _sequence[_step],
            width: MediaQuery.of(context).size.width * 0.9,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

ThemeData _buildKaroTheme() {
  const krem = Color(0xFFF8E1B5);
  const primary = Color(0xFF254E70);
  const accent = Color(0xFFF58B3B);
  const error = Color(0xFFC4473D);
  const darkText = Color(0xFF3A2B22);

  final base = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
  );

  return base.copyWith(
    scaffoldBackgroundColor: krem,
    primaryColor: primary,
    colorScheme: base.colorScheme.copyWith(
      primary: primary,
      secondary: accent,
      surface: Colors.white,
      background: krem,
      error: error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      centerTitle: true,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: darkText,
      displayColor: darkText,
    ),
  );
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
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: l.tabToday,
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: l.tabHabits,
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: l.tabStats,
          ),
        ],
      ),
    );
  }
}

