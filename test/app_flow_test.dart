import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits_app/l10n/app_localizations.dart';
import 'package:habits_app/main.dart';
import 'package:habits_app/services/habit_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Full app shell (without the intro) in the given language.
Future<HabitService> pumpApp(WidgetTester tester, Locale locale) async {
  SharedPreferences.setMockInitialValues({});
  final service = HabitService();
  await service.init();
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: service,
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HomeShell(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return service;
}

Future<void> addHabit(WidgetTester tester, String name) async {
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField).first, name);
  await tester.tap(find.text('Lagre'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Norwegian: add, check off, archive, restore and delete',
      (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final service = await pumpApp(tester, const Locale('nb'));

    // Bottom navigation is Norwegian.
    expect(find.text('I dag'), findsWidgets);
    expect(find.text('Vaner'), findsOneWidget);
    expect(find.text('Statistikk'), findsOneWidget);

    // Add a habit on the Habits tab.
    await tester.tap(find.text('Vaner'));
    await tester.pumpAndSettle();
    await addHabit(tester, 'Lese');
    expect(service.habits.single.name, 'Lese');
    expect(find.text('Lagret: Lese'), findsOneWidget);

    // Check it off on Today.
    await tester.tap(find.text('I dag').last);
    await tester.pumpAndSettle();
    expect(find.text('Fullført 0 av 1 vaner'), findsOneWidget);
    await tester.tap(find.text('Lese'));
    await tester.pumpAndSettle();
    expect(find.text('Fullført 1 av 1 vaner'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);

    // Archive from the edit sheet, then restore from the archive.
    await tester.tap(find.text('Vaner'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lese'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Arkiver').first);
    await tester.pumpAndSettle();
    expect(find.text('Arkiver vane'), findsOneWidget);
    await tester.tap(find.text('Arkiver').last);
    await tester.pumpAndSettle();
    expect(service.habits.single.isArchived, isTrue);

    await tester.tap(find.byIcon(Icons.archive_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Arkiverte vaner'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.unarchive_outlined));
    await tester.pumpAndSettle();
    expect(service.habits.single.isArchived, isFalse);
    Navigator.of(tester.element(find.text('Arkiverte vaner'))).pop();
    await tester.pumpAndSettle();

    // Delete from the edit sheet really deletes (not archives).
    await tester.tap(find.text('Lese'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Slett').first);
    await tester.pumpAndSettle();
    expect(find.text('Slett vane'), findsOneWidget);
    await tester.tap(find.text('Slett').last);
    await tester.pumpAndSettle();
    expect(service.habits, isEmpty);
  });

  testWidgets('English is used for other languages', (tester) async {
    await pumpApp(tester, const Locale('en'));
    expect(find.text('Today'), findsWidgets);
    expect(find.text('Habits'), findsOneWidget);
    expect(find.text('No habits today'), findsOneWidget);
  });
}
