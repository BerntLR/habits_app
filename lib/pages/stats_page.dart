import 'package:flutter/material.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Statistikk'),
          centerTitle: true,
        ),
        body: Center(
          child: const Text(
            'Statistikk kommer senere.\nFokus nå er daglig bruk og vaner.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
