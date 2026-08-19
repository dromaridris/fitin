class DietaryGuidanceTargets {
  final double calorieTarget;
  final double carbsMinG;
  final double carbsMaxG;
  final double proteinMinG;
  final double proteinMaxG;
  final double fatMinG;
  final double fatMaxG;
  final double saturatedFatMaxG;
  final double transFatMaxG;
  final double freeSugarMaxG;
  final double fiberMinG;
  final double fruitVegMinG;
  final double saltMaxG;
  final double sodiumMaxMg;

  const DietaryGuidanceTargets({
    required this.calorieTarget,
    required this.carbsMinG,
    required this.carbsMaxG,
    required this.proteinMinG,
    required this.proteinMaxG,
    required this.fatMinG,
    required this.fatMaxG,
    required this.saturatedFatMaxG,
    required this.transFatMaxG,
    required this.freeSugarMaxG,
    required this.fiberMinG,
    required this.fruitVegMinG,
    required this.saltMaxG,
    required this.sodiumMaxMg,
  });
}

class DietaryGuidanceService {
  /// WHO healthy-diet ranges for generally healthy adults.
  /// These are population-level guidance, not therapeutic targets.
  DietaryGuidanceTargets forCalories(double calories) {
    final kcal = calories.clamp(800.0, 6000.0).toDouble();
    return DietaryGuidanceTargets(
      calorieTarget: kcal,
      carbsMinG: kcal * 0.45 / 4,
      carbsMaxG: kcal * 0.75 / 4,
      proteinMinG: kcal * 0.10 / 4,
      proteinMaxG: kcal * 0.15 / 4,
      fatMinG: kcal * 0.15 / 9,
      fatMaxG: kcal * 0.30 / 9,
      saturatedFatMaxG: kcal * 0.10 / 9,
      transFatMaxG: kcal * 0.01 / 9,
      freeSugarMaxG: kcal * 0.10 / 4,
      fiberMinG: 25,
      fruitVegMinG: 400,
      saltMaxG: 5,
      sodiumMaxMg: 2000,
    );
  }

  List<String> dailyAdvice({
    required String languageCode,
    required double calorieTarget,
    required double proteinG,
    required double carbsG,
    required double fatG,
    required double fiberG,
  }) {
    final t = forCalories(calorieTarget);
    final ar = languageCode == 'ar';
    final ro = languageCode == 'ro';
    final out = <String>[];

    if (fiberG < t.fiberMinG) {
      out.add(ar
          ? 'زد الخضار، الفواكه، الحبوب الكاملة والبقوليات للوصول إلى 25 غ ألياف يومياً على الأقل.'
          : ro
              ? 'Sabzi, phal, whole grains aur daal/pulses barhayein taa-ke kam az kam 25 g fiber rozana ho.'
              : 'Increase vegetables, fruit, whole grains and pulses to reach at least 25 g fibre/day.');
    }
    if (fatG > t.fatMaxG) {
      out.add(ar
          ? 'الدهون اليوم مرتفعة بالنسبة لهدفك؛ قلّل السمن/الزبدة والقلي وفضّل الدهون غير المشبعة.'
          : ro
              ? 'Aaj fat zyada hai; ghee/butter aur frying kam karein aur unsaturated oils ko tarjeeh dein.'
              : 'Today’s fat is high for your target; reduce ghee/butter and frying and favour unsaturated fats.');
    }
    if (proteinG < t.proteinMinG) {
      out.add(ar
          ? 'أضف مصدراً مناسباً للبروتين مثل البقوليات أو السمك أو الدجاج أو البيض حسب نظامك.'
          : ro
              ? 'Protein ke liye daal/pulses, machhli, chicken ya anda apni diet ke mutabiq shamil karein.'
              : 'Add an appropriate protein source such as pulses, fish, chicken or eggs.');
    }
    if (carbsG > t.carbsMaxG) {
      out.add(ar
          ? 'كمية الكربوهيدرات مرتفعة؛ خفّض الحبوب المكررة وفضّل الحبوب الكاملة والخضار والبقوليات.'
          : ro
              ? 'Carbs zyada hain; refined grains kam aur whole grains, sabzi aur pulses zyada karein.'
              : 'Carbohydrate intake is high; reduce refined grains and favour whole grains, vegetables and pulses.');
    }
    if (out.isEmpty) {
      out.add(ar
          ? 'توزيع المغذيات المسجل اليوم ضمن نطاق عام متوازن؛ حافظ على التنوع والأطعمة قليلة التصنيع.'
          : ro
              ? 'Aaj ka logged macro balance aam tor par theek hai; variety aur minimally processed foods ko tarjeeh dein.'
              : 'Your logged macro balance is broadly reasonable; keep variety and minimally processed foods as the base.');
    }
    return out;
  }
}
