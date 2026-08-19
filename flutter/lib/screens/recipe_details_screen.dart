import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe_detail.dart';
import '../services/offline_data.dart';
import '../services/recipe_service.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/larc_button.dart';
import '../widgets/larc_card.dart';
import 'nutrition_screen.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final int recipeId;
  final List<String> fallbackMissing;
  final int initialServings;

  const RecipeDetailsScreen({
    super.key,
    required this.recipeId,
    this.fallbackMissing = const [],
    this.initialServings = 4,
  });

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  final _service = RecipeService();
  late final RecipeDetail recipe;
  late final OfflineRecipe offlineRecipe;

  @override
  void initState() {
    super.initState();
    recipe = _service.getDetail(widget.recipeId);
    offlineRecipe = offlineRecipes.firstWhere((x) => x.id == widget.recipeId);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final steps = recipeCookingSteps(offlineRecipe, s.languageCode);
    final totalWeight = totalIngredientWeightG(offlineRecipe);
    final totalCalories = totalRecipeCalories(offlineRecipe);

    return Directionality(
      textDirection: s.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.isArabic ? 'تفاصيل الوصفة' : 'Recipe Details'),
          actions: [
            IconButton(
              onPressed: () => s.toggleFavorite(widget.recipeId),
              icon: Icon(
                s.isFavorite(widget.recipeId) ? Icons.favorite : Icons.favorite_border,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(recipe.title(s.languageCode), style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 6),
            Text(
              '${cuisineLabel(recipe.cuisine, s.languageCode)} • ${recipe.servings} ${s.isArabic ? "حصص" : "servings"} • ${recipe.prepMinutes + recipe.cookMinutes} ${s.isArabic ? "دقيقة" : "min"}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Text(
              recipeDescription(offlineRecipe, s.languageCode),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            LarcCard(
              child: Wrap(
                spacing: 18,
                runSpacing: 10,
                children: [
                  _stat(context, s.isArabic ? 'وزن المكونات' : 'Ingredient weight', '${totalWeight.round()} g'),
                  _stat(context, s.isArabic ? 'سعرات القدر' : 'Batch calories', '${totalCalories.round()} kcal'),
                  _stat(
                    context,
                    s.isArabic ? 'تقريباً لكل حصة' : 'Approx. per serving',
                    '${(totalCalories / recipe.servings).round()} kcal',
                  ),
                ],
              ),
            ),
            if (widget.fallbackMissing.isNotEmpty) ...[
              const SizedBox(height: 20),
              LarcCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.isArabic ? 'المكونات الأساسية الناقصة' : 'Missing Core Ingredients',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: widget.fallbackMissing.map((x) => Chip(label: Text(x))).toList(),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text(s.isArabic ? 'المكونات' : 'Ingredients', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ...recipe.ingredients.map(
              (i) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.circle, size: 8, color: AppColors.gold),
                title: Text(i.name(s.languageCode)),
                trailing: Text('${i.quantityG.round()} g'),
              ),
            ),
            const SizedBox(height: 24),
            Text(s.isArabic ? 'طريقة التحضير' : 'How to Cook', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ...steps.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(radius: 13, child: Text('${entry.key + 1}')),
                    const SizedBox(width: 10),
                    Expanded(child: Text(entry.value)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            LarcPrimaryButton(
              label: s.isArabic ? 'احسب وزن حصتي حسب السعرات' : 'Calculate Portion by Calories',
              icon: Icons.scale,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NutritionScreen(
                    recipeId: widget.recipeId,
                    recipeTitle: recipe.title(s.languageCode),
                    initialServings: widget.initialServings > 0 ? widget.initialServings : recipe.servings,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(BuildContext context, String label, String value) {
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 3),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
