import 'package:flutter/material.dart';
import 'tokens.dart';

class BullPeakTheme {
  static ThemeData light({required Color accent}) {
    final cs = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.light,
      error: Tokens.error,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: cs,
      scaffoldBackgroundColor: Tokens.background,
    );
  }

  static ThemeData dark({required Color accent}) {
    final cs = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.dark,
      error: Tokens.error,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: cs,
      scaffoldBackgroundColor: Tokens.backgroundDark,
    );
  }
}
