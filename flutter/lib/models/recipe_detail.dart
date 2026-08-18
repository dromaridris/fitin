class RecipeDetailIngredient {
  final int ingredientId;
  final String nameEn, nameAr, nameRo;
  final double quantityG;

  RecipeDetailIngredient({
    required this.ingredientId,
    required this.nameEn,
    required this.nameAr,
    required this.nameRo,
    required this.quantityG,
  });

  factory RecipeDetailIngredient.fromJson(Map<String, dynamic> j) =>
      RecipeDetailIngredient(
        ingredientId: j['ingredient_id'],
        nameEn: j['name_en'] ?? '',
        nameAr: j['name_ar'] ?? '',
        nameRo: j['name_ro'] ?? '',
        quantityG: (j['quantity_g'] as num).toDouble(),
      );

  String name(String code) {
    if (code == 'ar' && nameAr.isNotEmpty) return nameAr;
    if (code == 'ro' && nameRo.isNotEmpty) return nameRo;
    return nameEn;
  }
}

class RecipeDetail {
  final int id;
  final String nameEn, nameAr, nameRo, cuisine;
  final String descriptionEn, descriptionAr;
  final int servings, prepMinutes, cookMinutes;
  final List<RecipeDetailIngredient> ingredients;

  RecipeDetail({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.nameRo,
    required this.cuisine,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.servings,
    required this.prepMinutes,
    required this.cookMinutes,
    required this.ingredients,
  });

  factory RecipeDetail.fromJson(Map<String, dynamic> j) => RecipeDetail(
        id: j['id'],
        nameEn: j['name_en'] ?? '',
        nameAr: j['name_ar'] ?? '',
        nameRo: j['name_ro'] ?? '',
        cuisine: j['cuisine'] ?? '',
        descriptionEn: j['description_en'] ?? '',
        descriptionAr: j['description_ar'] ?? '',
        servings: j['servings'] ?? 1,
        prepMinutes: j['prep_minutes'] ?? 0,
        cookMinutes: j['cook_minutes'] ?? 0,
        ingredients: ((j['ingredients'] ?? []) as List)
            .map((e) => RecipeDetailIngredient.fromJson(e))
            .toList(),
      );

  String title(String code) {
    if (code == 'ar' && nameAr.isNotEmpty) return nameAr;
    if (code == 'ro' && nameRo.isNotEmpty) return nameRo;
    return nameEn;
  }

  String description(String code) {
    if (code == 'ar' && descriptionAr.isNotEmpty) return descriptionAr;
    return descriptionEn;
  }
}
