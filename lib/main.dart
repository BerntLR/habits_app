import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/habit_service.dart';
import 'pages/bullpeak_intro_page.dart';
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
        initialRoute: '/',
        routes: {
          '/': (_) => const BullpeakIntroPage(),
          '/home': (_) => const HomeShell(),
        },
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
      elevation: 2,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    textTheme: base.textTheme.apply(
      bodyColor: darkText,
      displayColor: darkText,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: primary.withOpacity(0.08),
          width: 1,
        ),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: Colors.white,
      selectedColor: accent.withOpacity(0.15),
      labelStyle: const TextStyle(
        color: darkText,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: primary.withOpacity(0.1),
        ),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return accent;
        }
        return primary.withOpacity(0.4);
      }),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: krem,
      indicatorColor: accent.withOpacity(0.2),
      labelTextStyle: MaterialStateProperty.all(
        const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
      ),
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
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'I dag',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Vaner',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Statistikk',
          ),
        ],
      ),
    );
  }
}

