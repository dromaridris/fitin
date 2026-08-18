import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Gold circular progress ring with a centered percentage/value label.
/// Used for match score and nutrition-goal progress.
class LarcProgressRing extends StatelessWidget {
  const LarcProgressRing({
    super.key,
    required this.value,
    required this.label,
    this.size = 64,
  });

  /// 0.0 - 1.0
  final double value;
  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: value.clamp(0, 1),
              strokeWidth: 5,
              backgroundColor: AppColors.surfaceElevated,
              valueColor: const AlwaysStoppedAnimation(AppColors.gold),
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Thin gold linear progress bar with a label row above it,
/// used for daily nutrition totals (calories, protein, etc.)
class LarcProgressBar extends StatelessWidget {
  const LarcProgressBar({
    super.key,
    required this.label,
    required this.value,
    this.valueLabel,
  });

  final String label;
  final double value;
  final String? valueLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            if (valueLabel != null)
              Text(valueLabel!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: value.clamp(0, 1),
            minHeight: 8,
            backgroundColor: AppColors.surfaceElevated,
            valueColor: const AlwaysStoppedAnimation(AppColors.gold),
          ),
        ),
      ],
    );
  }
}
