import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_recipe_nutrition_app/main.dart';
import 'package:smart_recipe_nutrition_app/screens/splash_screen.dart';
import 'package:smart_recipe_nutrition_app/state/app_state.dart';

void main() {
  testWidgets('unlicensed installation shows FITIN activation gate', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await state.loadFavorites();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const FitinApp(),
      ),
    );

    // LicenseGate performs an asynchronous local validation first.
    await tester.pumpAndSettle();

    expect(find.text('Activate FITIN'), findsOneWidget);
    expect(
      find.text('This installation must be licensed before FITIN can be used.'),
      findsOneWidget,
    );
    expect(find.text('License key'), findsOneWidget);
    expect(find.text('Activate'), findsOneWidget);
  });

  testWidgets('FITIN splash shows brand name and hands off to app', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(
          child: Scaffold(
            body: Text('FITIN app ready'),
          ),
        ),
      ),
    );

    expect(find.text('FITIN by LARC'), findsOneWidget);
    expect(
      find.text('London Aesthetics & Rejuvenation Centre'),
      findsOneWidget,
    );

    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump();

    expect(find.text('FITIN app ready'), findsOneWidget);
  });
}
