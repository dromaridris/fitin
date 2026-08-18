import 'package:flutter_test/flutter_test.dart';
import 'package:smart_recipe_nutrition_app/services/offline_data.dart';
import 'package:smart_recipe_nutrition_app/services/recipe_service.dart';
import 'package:smart_recipe_nutrition_app/services/recommendation_service.dart';

void main() {
  test('offline recipe database has 120 valid unique recipes', () {
    expect(offlineRecipes.length, 120);

    final ids = offlineRecipes.map((r) => r.id).toSet();
    expect(ids.length, offlineRecipes.length);

    final ingredientIds = offlineIngredients.map((i) => i.id).toSet();
    expect(ingredientIds.length, offlineIngredients.length);

    for (final recipe in offlineRecipes) {
      expect(recipe.id, greaterThan(0));
      expect(recipe.nameEn.trim(), isNotEmpty);
      expect(recipe.nameAr.trim(), isNotEmpty);
      expect(recipe.nameRo.trim(), isNotEmpty);
      expect(recipe.servings, greaterThan(0));
      expect(recipe.ingredients, isNotEmpty);

      for (final item in recipe.ingredients) {
        expect(ingredientIds.contains(item.ingredientId), isTrue,
            reason: 'Recipe ${recipe.id} references missing ingredient');
        expect(item.quantityG, greaterThan(0));
      }
    }
  });

  test('offline cuisines remain balanced', () {
    final counts = <String, int>{};
    for (final recipe in offlineRecipes) {
      counts.update(recipe.cuisine, (v) => v + 1, ifAbsent: () => 1);
    }

    expect(counts['Pakistani'], 40);
    expect(counts['Syrian'], 40);
    expect(counts['European'], 40);
  });

  test('search works in English, Arabic and Roman Urdu', () {
    final service = RecipeService();

    expect(service.search(query: 'chicken'), isNotEmpty);
    expect(service.search(query: 'دجاج'), isNotEmpty);
    expect(service.search(query: 'murghi'), isNotEmpty);
  });

  test('ingredient aliases normalize across supported languages', () {
    expect(normalizeOfflineIngredient('potato'), 'potato');
    expect(normalizeOfflineIngredient('بطاطا'), 'potato');
    expect(normalizeOfflineIngredient('aloo'), 'potato');
  });

  test('recommendations return finite ranked results offline', () {
    final results = RecommendationService().find(['chicken', 'potato', 'onion']);
    expect(results, isNotEmpty);
    expect(results.length, lessThanOrEqualTo(20));
    expect(results.first.matchScore, inInclusiveRange(0, 100));
  });

  test('calculated nutrition is positive and finite for every recipe', () {
    for (final recipe in offlineRecipes) {
      double calories = 0;
      double protein = 0;
      double carbs = 0;
      double fat = 0;
      double fiber = 0;

      for (final item in recipe.ingredients) {
        final ingredient = ingredientById(item.ingredientId);
        final factor = item.quantityG / 100.0;
        calories += ingredient.calories * factor;
        protein += ingredient.protein * factor;
        carbs += ingredient.carbs * factor;
        fat += ingredient.fat * factor;
        fiber += ingredient.fiber * factor;
      }

      expect(calories.isFinite, isTrue);
      expect(protein.isFinite, isTrue);
      expect(carbs.isFinite, isTrue);
      expect(fat.isFinite, isTrue);
      expect(fiber.isFinite, isTrue);
      expect(calories, greaterThan(0), reason: 'Recipe ${recipe.id} has 0 kcal');
      expect(calories / recipe.servings, lessThan(2500),
          reason: 'Recipe ${recipe.id} kcal/serving is implausibly high');
    }
  });
}
