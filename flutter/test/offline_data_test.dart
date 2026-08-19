import 'package:flutter_test/flutter_test.dart';
import 'package:smart_recipe_nutrition_app/services/dietary_guidance_service.dart';
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
      expect(totalIngredientWeightG(recipe), greaterThan(0));
      expect(totalRecipeCalories(recipe), greaterThan(0));
      expect(recipeCookingSteps(recipe, 'en'), isNotEmpty);
      expect(recipeCookingSteps(recipe, 'ar'), isNotEmpty);
      expect(recipeCookingSteps(recipe, 'ro'), isNotEmpty);

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

  test('search respects cuisine and supported recipe languages', () {
    final service = RecipeService();
    final pakistani = service.search(query: 'chicken', cuisine: 'Pakistani');
    expect(pakistani, isNotEmpty);
    expect(pakistani.every((x) => x.cuisine == 'Pakistani'), isTrue);
    expect(service.search(query: 'دجاج', cuisine: 'Syrian'), isNotEmpty);
    expect(service.search(query: 'murghi', cuisine: 'Pakistani'), isNotEmpty);
  });

  test('ingredient aliases normalize across supported languages', () {
    expect(normalizeOfflineIngredient('potato'), 'potato');
    expect(normalizeOfflineIngredient('بطاطا'), 'potato');
    expect(normalizeOfflineIngredient('aloo'), 'potato');
  });

  test('what-do-I-have does not match pantry-only unrelated dishes', () {
    final service = RecommendationService();
    final results = service.find(['potato', 'onion'], cuisine: 'Pakistani');
    expect(results, isNotEmpty);
    expect(results.every((x) => x.cuisine == 'Pakistani'), isTrue);
    expect(results.any((x) => x.nameEn.toLowerCase().contains('chana masala')), isFalse);
    expect(results.any((x) => x.nameEn.toLowerCase().contains('rajma')), isFalse);
  });

  test('recommendations are finite and ranked within one cuisine', () {
    final results = RecommendationService().find(
      ['chicken', 'potato', 'onion'],
      cuisine: 'Pakistani',
    );
    expect(results, isNotEmpty);
    expect(results.length, lessThanOrEqualTo(20));
    expect(results.first.matchScore, inInclusiveRange(0, 100));
    expect(results.every((x) => x.cuisine == 'Pakistani'), isTrue);
  });

  test('WHO guidance calculations are internally consistent', () {
    final targets = DietaryGuidanceService().forCalories(2000);
    expect(targets.fiberMinG, 25);
    expect(targets.fruitVegMinG, 400);
    expect(targets.saltMaxG, 5);
    expect(targets.freeSugarMaxG, closeTo(50, 0.01));
    expect(targets.fatMaxG, closeTo(66.67, 0.1));
    expect(targets.proteinMinG, closeTo(50, 0.01));
  });

  test('calculated nutrition is positive and finite for every recipe', () {
    for (final recipe in offlineRecipes) {
      final nutrition = nutritionForRecipe(recipe);
      expect(nutrition.calories.isFinite, isTrue);
      expect(nutrition.protein.isFinite, isTrue);
      expect(nutrition.carbs.isFinite, isTrue);
      expect(nutrition.fat.isFinite, isTrue);
      expect(nutrition.fiber.isFinite, isTrue);
      expect(nutrition.calories, greaterThan(0));
      expect(nutrition.calories, lessThan(2500),
          reason: 'Recipe ${recipe.id} kcal/serving is implausibly high');
    }
  });
}
