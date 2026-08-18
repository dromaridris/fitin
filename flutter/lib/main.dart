import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/app_state.dart';
import 'screens/app_shell.dart';
import 'screens/splash_screen.dart';
import 'screens/license_gate.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState();
  await state.loadFavorites();
  runApp(
    ChangeNotifierProvider.value(
      value: state,
      child: const FitinApp(),
    ),
  );
}

/// FITIN by LARC
/// London Aesthetics & Rejuvenation Centre — recipe & nutrition companion.
class FitinApp extends StatelessWidget {
  const FitinApp({super.key});

  // Text direction is applied per-screen via Directionality based on
  // AppState.isArabic (see each screen). Arabic = RTL; English and
  // Roman Urdu = LTR. This app does not use flutter_localizations,
  // so Material framework chrome (e.g. built-in tooltips) stays in
  // English; all app-authored copy is translated per screen.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FITIN by LARC',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: const LicenseGate(child: SplashScreen(child: AppShell())),
    );
  }
}
