import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Solid gold call-to-action button. Use for the single primary
/// action on a screen (e.g. "Start Cooking", "Find Recipes").
class LarcPrimaryButton extends StatelessWidget {
  const LarcPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final button = FilledButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
      label: Text(label),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Outlined gold button for secondary actions (e.g. "Search Recipes").
class LarcSecondaryButton extends StatelessWidget {
  const LarcSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon, color: AppColors.gold) : const SizedBox.shrink(),
      label: Text(label),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
