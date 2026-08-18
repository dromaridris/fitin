import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Selectable filter chip (cuisine filters, tags).
class LarcFilterChip extends StatelessWidget {
  const LarcFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: AppColors.gold,
      checkmarkColor: AppColors.textOnGold,
      labelStyle: TextStyle(
        color: selected ? AppColors.textOnGold : AppColors.textPrimary,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 13,
      ),
    );
  }
}

/// Deletable ingredient chip (used in "What Do I Have?").
class LarcInputChip extends StatelessWidget {
  const LarcInputChip({
    super.key,
    required this.label,
    required this.onDeleted,
  });

  final String label;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(label),
      onDeleted: onDeleted,
      deleteIconColor: AppColors.gold,
      backgroundColor: AppColors.surface,
      side: const BorderSide(color: AppColors.surfaceBorder),
    );
  }
}
