class NutritionProfileResult {
  final double bmi;
  final String bmiCategory;
  final double bmr;
  final double tdee;
  final double calorieTarget;
  final bool breastfeeding;

  NutritionProfileResult({
    required this.bmi,
    required this.bmiCategory,
    required this.bmr,
    required this.tdee,
    required this.calorieTarget,
    required this.breastfeeding,
  });

  factory NutritionProfileResult.fromJson(Map<String, dynamic> j) {
    return NutritionProfileResult(
      bmi: (j['bmi'] as num).toDouble(),
      bmiCategory: j['bmi_category'],
      bmr: (j['bmr_kcal'] as num).toDouble(),
      tdee: (j['tdee_kcal'] as num).toDouble(),
      calorieTarget:
          (j['estimated_daily_calorie_target'] as num).toDouble(),
      breastfeeding: j['breastfeeding'] ?? false,
    );
  }
}
