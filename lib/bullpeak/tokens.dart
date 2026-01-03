import 'package:flutter/material.dart';

class Tokens {
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF000000);
  static const Color error = Color(0xFFC4473D);
  static const Color success = Color(0xFF2E7D32);
}

class BPSpacing {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
}

class BPRadius {
  static const BorderRadius card = BorderRadius.all(Radius.circular(16));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
}

class BPShadows {
  static List<BoxShadow> soft(Color c) => [
        BoxShadow(
          color: c.withValues(alpha: 0.10),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ];
}
