import 'dart:async';
import 'package:flutter/material.dart';

class HabitsIntroPage extends StatefulWidget {
  const HabitsIntroPage({super.key});

  @override
  State<HabitsIntroPage> createState() => _HabitsIntroPageState();
}

class _HabitsIntroPageState extends State<HabitsIntroPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();

    // Vis habits-intro i 2 sekunder, deretter inn i hovedappen
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8E1B5),
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: Image.asset(
            'assets/splash/habits_intro.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

