import 'package:flutter/material.dart';

/// Karo standard: Karo + Rico in the middle of the screen, behind the content.
class Watermark extends StatelessWidget {
  const Watermark({super.key});

  @override
  Widget build(BuildContext context) {
    final asset = Theme.of(context).brightness == Brightness.dark
        ? 'assets/watermark_dark.png'
        : 'assets/watermark_light.png';

    return IgnorePointer(
      child: Center(
        child: Opacity(
          opacity: 0.06,
          child: Image.asset(
            asset,
            width: MediaQuery.of(context).size.width * 0.75,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
