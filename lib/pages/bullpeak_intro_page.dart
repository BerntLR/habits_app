import 'dart:async';
import 'package:flutter/material.dart';

class BullpeakIntroPage extends StatefulWidget {
  const BullpeakIntroPage({super.key});

  @override
  State<BullpeakIntroPage> createState() => _BullpeakIntroPageState();
}

class _BullpeakIntroPageState extends State<BullpeakIntroPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    // Vis emblemet i 2 sekunder før vi går til hovedskallet
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
            'assets/splash/bullpeak_emblem.png',
            width: 220,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
