import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Standard elevated-look surface card used across the app
/// (recipe cards, nutrition cards, list rows).
class LarcCard extends StatelessWidget {
  const LarcCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Section header with a small gold "eyebrow" label above a title,
/// e.g. "WHAT DO I HAVE?" above "Turn what's in your kitchen into a meal".
class LarcSectionHeader extends StatelessWidget {
  const LarcSectionHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.trailing,
  });

  final String eyebrow;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(eyebrow, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 4),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
