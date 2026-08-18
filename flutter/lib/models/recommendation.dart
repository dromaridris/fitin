class Recommendation {
  final int recipeId;
  final String nameEn, nameAr, nameRo, cuisine;
  final double matchScore;
  final int missingCount, servings, prepMinutes, cookMinutes;
  final List<String> missingIngredients;

  Recommendation({
    required this.recipeId,
    required this.nameEn,
    required this.nameAr,
    required this.nameRo,
    required this.cuisine,
    required this.matchScore,
    required this.missingCount,
    required this.servings,
    required this.prepMinutes,
    required this.cookMinutes,
    required this.missingIngredients,
  });

  factory Recommendation.fromJson(Map<String, dynamic> j) => Recommendation(
    recipeId: j['recipe_id'],
    nameEn: j['name_en'],
    nameAr: j['name_ar'],
    nameRo: j['name_ro'],
    cuisine: j['cuisine'],
    matchScore: (j['match_score'] as num).toDouble(),
    missingCount: j['missing_count'],
    servings: j['servings'],
    prepMinutes: j['prep_minutes'],
    cookMinutes: j['cook_minutes'],
    missingIngredients: List<String>.from(j['missing_ingredients'] ?? []),
  );

  String title(String code) {
    if (code == 'ar') return nameAr;
    if (code == 'ro') return nameRo;
    return nameEn;
  }
}
