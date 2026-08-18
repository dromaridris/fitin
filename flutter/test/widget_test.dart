import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_recipe_nutrition_app/main.dart';
import 'package:smart_recipe_nutrition_app/state/app_state.dart';

void main() {
  testWidgets('unlicensed installation shows offline activation', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await state.loadFavorites();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const FitinApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Activate FITIN'), findsOneWidget);
    expect(find.text('DEVICE CODE'), findsOneWidget);
    expect(find.text('Copy Device Code'), findsOneWidget);
    expect(find.text('Activate Permanently'), findsOneWidget);
  });
}
