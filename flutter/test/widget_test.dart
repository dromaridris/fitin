import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_recipe_nutrition_app/main.dart';
import 'package:smart_recipe_nutrition_app/state/app_state.dart';

void main() {
  testWidgets('FITIN by LARC splash shows brand name', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await state.loadFavorites();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const FitinApp(),
      ),
    );

    // Splash screen (black background, LARC logo) is shown first.
    expect(find.text('FITIN by LARC'), findsOneWidget);
    expect(
      find.text('London Aesthetics & Rejuvenation Centre'),
      findsOneWidget,
    );

    // Splash auto-dismisses after ~1.1s and hands off to AppShell/Home.
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump();

    // App bar on Home also shows the brand name.
    expect(find.text('FITIN by LARC'), findsWidgets);
    // Primary feature CTA from the brand spec must be present.
    expect(find.text('Start Cooking'), findsOneWidget);
  });
}
