import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class AppLanguageMenu extends StatelessWidget {
  const AppLanguageMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    return PopupMenuButton<AppLanguage>(
      onSelected: state.setLanguage,
      itemBuilder: (_) => const [
        PopupMenuItem(value: AppLanguage.english, child: Text('English')),
        PopupMenuItem(value: AppLanguage.arabic, child: Text('العربية')),
        PopupMenuItem(value: AppLanguage.romanUrdu, child: Text('Roman Urdu')),
      ],
    );
  }
}
