import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits_app/l10n/app_localizations.dart';
import 'package:habits_app/main.dart';

void main() {
  const supported = [Locale('en'), Locale('nb')];

  test('Norwegian variants use nb, everything else English', () {
    expect(resolveAppLocale(const Locale('nb', 'NO'), supported),
        const Locale('nb'));
    expect(resolveAppLocale(const Locale('no'), supported), const Locale('nb'));
    expect(resolveAppLocale(const Locale('nn'), supported), const Locale('nb'));
    expect(resolveAppLocale(const Locale('sv'), supported), const Locale('en'));
    expect(resolveAppLocale(null, supported), const Locale('en'));
  });

  test('app supports English and Norwegian', () {
    expect(
      AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet(),
      {'en', 'nb'},
    );
  });

  test('Norwegian texts are translated', () {
    final nb = lookupAppLocalizations(const Locale('nb'));
    final en = lookupAppLocalizations(const Locale('en'));
    expect(nb.tabToday, 'I dag');
    expect(nb.todaySummary(2, 4), 'Fullført 2 av 4 vaner');
    expect(nb.importFailed, isNot(en.importFailed));
  });
}
