import '../models/recipe_summary.dart';
import '../models/recipe_detail.dart';
import 'offline_data.dart';

class RecipeService {
  RecipeService([Object? _]);

  List<RecipeSummary> search({String query = '', String? cuisine}) {
    final raw = query.trim();
    final q = raw.toLowerCase();
    final normalizedIngredient = normalizeOfflineIngredient(raw);
    return offlineRecipes.where((r) {
      final cuisineOk = cuisine == null || cuisine.isEmpty || r.cuisine == cuisine;
      final queryOk = q.isEmpty ||
          r.nameEn.toLowerCase().contains(q) ||
          r.nameAr.contains(raw) ||
          r.nameRo.toLowerCase().contains(q) ||
          r.cuisine.toLowerCase().contains(q) ||
          r.ingredients.any((ri) {
            final i = ingredientById(ri.ingredientId);
            return i.nameEn.toLowerCase().contains(q) ||
                i.nameAr.contains(raw) ||
                i.nameRo.toLowerCase().contains(q) ||
                i.key == normalizedIngredient;
          });
      return cuisineOk && queryOk;
    }).map((r) => RecipeSummary(
      id: r.id,
      nameEn: r.nameEn,
      nameAr: r.nameAr,
      nameRo: r.nameRo,
      cuisine: r.cuisine,
      servings: r.servings,
      prepMinutes: r.prepMinutes,
      cookMinutes: r.cookMinutes,
    )).toList();
  }

  RecipeDetail getDetail(int recipeId) {
    final r = offlineRecipes.firstWhere((x) => x.id == recipeId);
    return RecipeDetail(
      id: r.id,
      nameEn: r.nameEn,
      nameAr: r.nameAr,
      nameRo: r.nameRo,
      cuisine: r.cuisine,
      descriptionEn: '',
      descriptionAr: '',
      servings: r.servings,
      prepMinutes: r.prepMinutes,
      cookMinutes: r.cookMinutes,
      ingredients: r.ingredients.map((ri) {
        final i = ingredientById(ri.ingredientId);
        return RecipeDetailIngredient(
          ingredientId: i.id,
          nameEn: i.nameEn,
          nameAr: i.nameAr,
          nameRo: i.nameRo,
          quantityG: ri.quantityG,
        );
      }).toList(),
    );
  }
}
