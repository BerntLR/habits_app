import 'package:flutter/material.dart';
import 'tokens.dart';

/// Karo standard: Material 3, seed color per app, background = surface and
/// the AppBar has the same color as the background.
class BullPeakTheme {
  static ThemeData light({required Color accent}) =>
      _build(accent, Brightness.light);

  static ThemeData dark({required Color accent}) =>
      _build(accent, Brightness.dark);

  static ThemeData _build(Color accent, Brightness brightness) {
    final cs = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: brightness,
      error: Tokens.error,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: cs,
      scaffoldBackgroundColor: cs.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
    );
  }
}
