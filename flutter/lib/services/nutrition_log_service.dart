import '../state/app_state.dart';

class DailyNutritionSummary {
  final double consumedCalories;
  final double targetCalories;
  final double remainingCalories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;
  final double progressPercent;

  DailyNutritionSummary({
    required this.consumedCalories,
    required this.targetCalories,
    required this.remainingCalories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.fiberG,
    required this.progressPercent,
  });
}

class NutritionLogService {
  DailyNutritionSummary summarize({
    required double calorieTarget,
    required List<FoodLogItem> items,
  }) {
    final cal = items.fold<double>(0, (s, e) => s + e.calories);
    final p = items.fold<double>(0, (s, e) => s + e.proteinG);
    final c = items.fold<double>(0, (s, e) => s + e.carbsG);
    final f = items.fold<double>(0, (s, e) => s + e.fatG);
    final fiber = items.fold<double>(0, (s, e) => s + e.fiberG);
    final target = calorieTarget < 0 ? 0.0 : calorieTarget;
    final remaining = (target - cal).clamp(0.0, double.infinity).toDouble();
    final percent = target <= 0
        ? 0.0
        : ((cal / target) * 100).clamp(0.0, 999.0).toDouble();
    return DailyNutritionSummary(
      consumedCalories: cal,
      targetCalories: target,
      remainingCalories: remaining,
      proteinG: p,
      carbsG: c,
      fatG: f,
      fiberG: fiber,
      progressPercent: percent,
    );
  }
}
