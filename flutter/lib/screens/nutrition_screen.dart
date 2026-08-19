import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/offline_data.dart';
import '../state/app_state.dart';
import '../widgets/larc_button.dart';
import '../widgets/larc_card.dart';

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
  late final TextEditingController cookedWeightController;
  late final TextEditingController calorieBudgetController;
  bool _addedToday = false;

  @override
  void initState() {
    super.initState();
    final recipe = offlineRecipes.firstWhere((x) => x.id == widget.recipeId);
    servings = widget.initialServings < 1 ? 1 : widget.initialServings;
    final factor = servings / recipe.servings;
    cookedWeightController = TextEditingController(
      text: (totalIngredientWeightG(recipe) * factor).round().toString(),
    );
    calorieBudgetController = TextEditingController();
  }

  @override
  void dispose() {
    cookedWeightController.dispose();
    calorieBudgetController.dispose();
    super.dispose();
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

    return {
      'nutrition': {
        'calories': _round1(calories),
        'protein_g': _round1(protein),
        'carbs_g': _round1(carbs),
        'fat_g': _round1(fat),
        'fiber_g': _round1(fiber),
      },
      'nutrition_per_serving': {
        'calories': _round1(calories / servings),
        'protein_g': _round1(protein / servings),
        'carbs_g': _round1(carbs / servings),
        'fat_g': _round1(fat / servings),
        'fiber_g': _round1(fiber / servings),
      },
      'ingredient_weight_g': _round1(items.fold<double>(0, (sum, x) => sum + (x['quantity_g'] as num).toDouble())),
      'ingredients': items,
    };
  }

  double _round1(double value) => double.parse(value.toStringAsFixed(1));

  void _changeServings(int value) {
    if (value < 1 || value > 100) return;
    final recipe = offlineRecipes.firstWhere((x) => x.id == widget.recipeId);
    setState(() {
      servings = value;
      _addedToday = false;
      final factor = servings / recipe.servings;
      cookedWeightController.text = (totalIngredientWeightG(recipe) * factor).round().toString();
    });
  }

  void _addPortionToToday(Map<String, dynamic> total, double portionCalories, double portionFraction) {
    final state = context.read<AppState>();
    state.addToTodayLog(
      FoodLogItem(
        name: widget.recipeTitle ?? 'Recipe #${widget.recipeId}',
        calories: portionCalories,
        proteinG: ((total['protein_g'] as num).toDouble() * portionFraction),
        carbsG: ((total['carbs_g'] as num).toDouble() * portionFraction),
        fatG: ((total['fat_g'] as num).toDouble() * portionFraction),
        fiberG: ((total['fiber_g'] as num).toDouble() * portionFraction),
      ),
    );
    setState(() => _addedToday = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(state.isArabic ? 'أُضيفت الحصة إلى سعرات اليوم' : 'Portion added to today')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final data = _calculate();
    final total = data['nutrition'] as Map<String, dynamic>;
    final perServing = data['nutrition_per_serving'] as Map<String, dynamic>;
    final ingredients = data['ingredients'] as List<dynamic>;
    final ingredientWeight = (data['ingredient_weight_g'] as num).toDouble();
    final totalCalories = (total['calories'] as num).toDouble();

    if (calorieBudgetController.text.isEmpty) {
      final defaultBudget = state.remainingCalories > 0 ? state.remainingCalories : state.calorieTarget;
      calorieBudgetController.text = defaultBudget.round().toString();
    }

    final cookedWeight = double.tryParse(cookedWeightController.text) ?? ingredientWeight;
    final allowedCalories = double.tryParse(calorieBudgetController.text) ?? 0;
    final portionFraction = totalCalories <= 0 ? 0.0 : (allowedCalories / totalCalories).clamp(0.0, 1.0).toDouble();
    final recommendedGrams = cookedWeight * portionFraction;
    final actualPortionCalories = totalCalories * portionFraction;

    return Directionality(
      textDirection: state.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(title: Text(state.isArabic ? 'السعرات ووزن الحصة' : 'Calories & Portion Weight')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(state.isArabic ? 'حجم الطبخة (حصص)' : 'Batch servings'),
                  ),
                  Row(
                    children: [
                      IconButton(onPressed: () => _changeServings(servings - 1), icon: const Icon(Icons.remove)),
                      Text('$servings'),
                      IconButton(onPressed: () => _changeServings(servings + 1), icon: const Icon(Icons.add)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(state.isArabic ? 'مجموع الطبخة' : 'Whole Batch', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _metric('Calories', '${total['calories']} kcal'),
                _metric(state.isArabic ? 'وزن المكونات' : 'Ingredient weight', '$ingredientWeight g'),
                _metric('Protein', '${total['protein_g']} g'),
                _metric('Carbs', '${total['carbs_g']} g'),
                _metric('Fat', '${total['fat_g']} g'),
                _metric('Fiber', '${total['fiber_g']} g'),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              state.isArabic
                  ? 'لكل حصة تقليدية: ${perServing['calories']} kcal'
                  : 'Traditional serving: ${perServing['calories']} kcal',
            ),
            const SizedBox(height: 24),
            LarcCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.isArabic ? 'احسب وزن حصتك حسب السعرات' : 'Calculate your portion by calories',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.isArabic
                        ? 'للدقة: زن الطبخة كاملة بعد انتهاء الطبخ وأدخل وزنها هنا. تغيّر الماء أثناء الطبخ يجعل الوزن النهائي أدق من مجموع المكونات.'
                        : 'For best accuracy, weigh the finished cooked batch and enter that weight here. Water gain/loss during cooking changes final weight.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: cookedWeightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: state.isArabic ? 'وزن الطبخة بعد الطبخ (غ)' : 'Finished cooked batch weight (g)',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: calorieBudgetController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: state.isArabic ? 'السعرات المسموحة لهذه الوجبة' : 'Calories allowed for this meal',
                      helperText: state.isArabic
                          ? 'المتبقي اليوم: ${state.remainingCalories.round()} kcal'
                          : 'Remaining today: ${state.remainingCalories.round()} kcal',
                    ),
                    onChanged: (_) => setState(() => _addedToday = false),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Text(
                          state.isArabic ? 'خذ تقريباً' : 'Serve approximately',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${recommendedGrams.round()} g',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text('≈ ${actualPortionCalories.round()} kcal'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  LarcPrimaryButton(
                    label: _addedToday
                        ? (state.isArabic ? 'أُضيفت الحصة ✓' : 'Portion added ✓')
                        : (state.isArabic ? 'أضف هذه الحصة إلى اليوم' : 'Add this portion to today'),
                    icon: Icons.add_circle_outline,
                    onPressed: _addedToday || actualPortionCalories <= 0
                        ? null
                        : () => _addPortionToToday(total, actualPortionCalories, portionFraction),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(state.isArabic ? 'كميات الوصفة' : 'Recipe Quantities', style: Theme.of(context).textTheme.titleLarge),
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
              return ListTile(title: Text(name), trailing: Text('${item['quantity_g']} g'));
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
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
