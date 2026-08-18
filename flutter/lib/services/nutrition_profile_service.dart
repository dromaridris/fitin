import '../models/nutrition_profile.dart';

class NutritionProfileService {
  NutritionProfileResult calculate({
    required int age,
    required String sex,
    required double heightCm,
    required double weightKg,
    required String activityLevel,
    bool breastfeeding = false,
  }) {
    if (age <= 0 || heightCm <= 0 || weightKg <= 0) {
      throw ArgumentError('Invalid profile values');
    }
    final m = heightCm / 100.0;
    final bmi = double.parse((weightKg / (m * m)).toStringAsFixed(1));
    final category = bmi < 18.5
        ? 'underweight'
        : bmi < 25
            ? 'healthy_range'
            : bmi < 30
                ? 'overweight'
                : 'obesity_range';
    final bmr = (10 * weightKg + 6.25 * heightCm - 5 * age +
            (sex.toLowerCase() == 'male' ? 5 : -161))
        .roundToDouble();
    const factors = {
      'sedentary': 1.20,
      'low': 1.375,
      'moderate': 1.55,
      'high': 1.725,
    };
    final tdee = (bmr * (factors[activityLevel] ?? 1.20)).roundToDouble();
    return NutritionProfileResult(
      bmi: bmi,
      bmiCategory: category,
      bmr: bmr,
      tdee: tdee,
      calorieTarget: tdee,
      breastfeeding: breastfeeding,
    );
  }
}
