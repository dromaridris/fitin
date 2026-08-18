import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/offline_data.dart';
import '../state/app_state.dart';
import '../widgets/larc_button.dart';

class NutritionScreen extends StatefulWidget {
  final int recipeId;
  final String? recipeTitle;
  final int initialServings;

  const NutritionScreen({
    super.key,
    required this.recipeId,
    this.recipeTitle,
    required this.initialServings,
  });

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  late int servings;
  bool _addedToday = false;

  @override
  void initState() {
    super.initState();
    servings = widget.initialServings < 1 ? 1 : widget.initialServings;
  }

  Map<String, dynamic> _calculate() {
    final recipe = offlineRecipes.firstWhere((x) => x.id == widget.recipeId);
    final factor = servings / recipe.servings;

    double calories = 0;
    double protein = 0;
    double carbs = 0;
    double fat = 0;
    double fiber = 0;
    final items = <Map<String, dynamic>>[];

    for (final recipeIngredient in recipe.ingredients) {
      final ingredient = ingredientById(recipeIngredient.ingredientId);
      final quantity = recipeIngredient.quantityG * factor;
      final nutritionFactor = quantity / 100.0;

      calories += ingredient.calories * nutritionFactor;
      protein += ingredient.protein * nutritionFactor;
      carbs += ingredient.carbs * nutritionFactor;
      fat += ingredient.fat * nutritionFactor;
      fiber += ingredient.fiber * nutritionFactor;

      items.add({
        'name_en': ingredient.nameEn,
        'name_ar': ingredient.nameAr,
        'name_ro': ingredient.nameRo,
        'quantity_g': _round1(quantity),
      });
    }

    final total = {
      'calories': _round1(calories),
      'protein_g': _round1(protein),
      'carbs_g': _round1(carbs),
      'fat_g': _round1(fat),
      'fiber_g': _round1(fiber),
    };
    final perServing = {
      'calories': _round1(calories / servings),
      'protein_g': _round1(protein / servings),
      'carbs_g': _round1(carbs / servings),
      'fat_g': _round1(fat / servings),
      'fiber_g': _round1(fiber / servings),
    };

    return {
      'nutrition': total,
      'nutrition_per_serving': perServing,
      'ingredients': items,
    };
  }

  double _round1(double value) => double.parse(value.toStringAsFixed(1));

  void _changeServings(int value) {
    if (value < 1 || value > 100) return;
    setState(() {
      servings = value;
      _addedToday = false;
    });
  }

  void _addToToday(Map<String, dynamic> nutrition) {
    final state = context.read<AppState>();
    final calories = (nutrition['calories'] as num?)?.toDouble() ?? 0;
    final protein = (nutrition['protein_g'] as num?)?.toDouble() ?? 0;
    final carbs = (nutrition['carbs_g'] as num?)?.toDouble() ?? 0;
    final fat = (nutrition['fat_g'] as num?)?.toDouble() ?? 0;

    state.addToTodayLog(
      FoodLogItem(
        name: widget.recipeTitle ?? 'Recipe #${widget.recipeId}',
        calories: calories,
        proteinG: protein,
        carbsG: carbs,
        fatG: fat,
      ),
    );

    setState(() => _addedToday = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          state.isArabic
              ? 'أُضيف إلى سعرات اليوم'
              : "Added to today's calories",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final data = _calculate();
    final total = data['nutrition'] as Map<String, dynamic>;
    final perServing =
        data['nutrition_per_serving'] as Map<String, dynamic>;
    final ingredients = data['ingredients'] as List<dynamic>;

    return Directionality(
      textDirection: state.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(state.isArabic ? 'السعرات والكميات' : 'Nutrition'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(state.isArabic ? 'الحصص' : 'Servings'),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _changeServings(servings - 1),
                        icon: const Icon(Icons.remove),
                      ),
                      Text('$servings'),
                      IconButton(
                        onPressed: () => _changeServings(servings + 1),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              state.isArabic
                  ? 'الإجمالي لـ $servings حصص'
                  : 'Total for $servings serving(s)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _metric('Calories', '${total['calories']} kcal'),
                _metric('Protein', '${total['protein_g']} g'),
                _metric('Carbs', '${total['carbs_g']} g'),
                _metric('Fat', '${total['fat_g']} g'),
                _metric('Fiber', '${total['fiber_g']} g'),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              state.isArabic ? 'لكل حصة' : 'Per Serving',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${perServing['calories']} kcal • '
              '${perServing['protein_g']}g P • '
              '${perServing['carbs_g']}g C • '
              '${perServing['fat_g']}g F',
            ),
            const SizedBox(height: 20),
            LarcPrimaryButton(
              label: _addedToday
                  ? (state.isArabic ? 'أُضيف ✓' : 'Added ✓')
                  : (state.isArabic
                      ? 'أضف إلى سعرات اليوم'
                      : "Add to Today's Calories"),
              icon: Icons.add_circle_outline,
              onPressed: _addedToday ? null : () => _addToToday(total),
            ),
            const SizedBox(height: 20),
            Text(
              state.isArabic ? 'الكميات' : 'Scaled Quantities',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ...ingredients.map((raw) {
              final item = raw as Map<String, dynamic>;
              String name;
              if (state.languageCode == 'ar') {
                name = (item['name_ar'] ?? item['name_en'] ?? '').toString();
              } else if (state.languageCode == 'ro') {
                name = (item['name_ro'] ?? item['name_en'] ?? '').toString();
              } else {
                name = (item['name_en'] ?? '').toString();
              }
              return ListTile(
                title: Text(name),
                trailing: Text('${item['quantity_g']} g'),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _metric(String name, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(name),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
