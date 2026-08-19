import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe_summary.dart';
import '../services/offline_data.dart';
import '../services/recipe_service.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/app_language_menu.dart';
import '../widgets/larc_button.dart';
import '../widgets/larc_card.dart';
import '../widgets/larc_chip.dart';
import '../widgets/larc_logo.dart';
import 'nutrition_dashboard_screen.dart';
import 'recipe_details_screen.dart';
import 'search_screen.dart';
import 'what_do_i_have_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isArabic = state.isArabic;
    final recipeService = RecipeService();
    final selectedCuisine = state.selectedCuisine;
    final List<RecipeSummary> recommended = selectedCuisine == null
        ? const []
        : recipeService.search(cuisine: selectedCuisine).take(6).toList();

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 56,
          leading: const Padding(
            padding: EdgeInsets.all(8),
            child: LarcLogo(size: 32),
          ),
          title: const Text('FITIN by LARC'),
          actions: const [AppLanguageMenu()],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            LarcCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? 'ابدأ باختيار المطبخ' : 'CHOOSE YOUR CUISINE FIRST',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isArabic
                        ? 'حتى لا نخلط وصفات باكستانية وشامية وأوروبية في نفس الاقتراحات.'
                        : 'This keeps Pakistani, Syrian and European suggestions separate and relevant.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Pakistani', 'Syrian', 'European'].map((value) {
                      return LarcFilterChip(
                        label: cuisineLabel(value, state.languageCode),
                        selected: selectedCuisine == value,
                        onSelected: (_) => state.setCuisine(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isArabic ? 'ماذا لدي؟' : 'WHAT DO I HAVE?',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    selectedCuisine == null
                        ? (isArabic ? 'اختر المطبخ أولاً ثم أخبرنا بمكوناتك.' : 'Choose a cuisine first, then tell us what you have.')
                        : (isArabic
                            ? 'أخبرنا بمكوناتك، وسنقترح وصفات ${cuisineLabel(selectedCuisine, state.languageCode)} مطابقة.'
                            : 'Tell us what you have and we will suggest matching ${cuisineLabel(selectedCuisine, state.languageCode)} recipes.'),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  LarcPrimaryButton(
                    label: isArabic ? 'ابدأ الطبخ' : 'Start Cooking',
                    icon: Icons.local_fire_department,
                    onPressed: selectedCuisine == null
                        ? null
                        : () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const WhatDoIHaveScreen()),
                            ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LarcSecondaryButton(
              label: isArabic ? 'ابحث في المطبخ المختار' : 'Search Selected Cuisine',
              icon: Icons.search,
              onPressed: selectedCuisine == null
                  ? null
                  : () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SearchScreen()),
                      ),
            ),
            const SizedBox(height: 32),
            LarcSectionHeader(
              eyebrow: isArabic ? 'مقترحة' : 'RECOMMENDED',
              title: selectedCuisine == null
                  ? (isArabic ? 'اختر المطبخ لرؤية الوصفات' : 'Choose cuisine to see recipes')
                  : (isArabic
                      ? 'وصفات ${cuisineLabel(selectedCuisine, state.languageCode)}'
                      : '${cuisineLabel(selectedCuisine, state.languageCode)} Recipes'),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 132,
              child: selectedCuisine == null
                  ? Center(child: Text(isArabic ? 'اختر المطبخ أعلاه' : 'Select a cuisine above'))
                  : recommended.isEmpty
                      ? Center(child: Text(isArabic ? 'لا توجد وصفات بعد' : 'No recipes yet'))
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: recommended.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (_, index) {
                            final recipe = recommended[index];
                            return SizedBox(
                              width: 180,
                              child: LarcCard(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RecipeDetailsScreen(
                                      recipeId: recipe.id,
                                      initialServings: recipe.servings,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      recipe.title(state.languageCode),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    Text(
                                      '${recipe.prepMinutes + recipe.cookMinutes} min',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
            const SizedBox(height: 32),
            LarcSectionHeader(
              eyebrow: isArabic ? 'اليوم' : 'TODAY',
              title: isArabic ? 'التغذية اليوم' : 'Nutrition Today',
            ),
            const SizedBox(height: 14),
            LarcCard(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NutritionDashboardScreen()),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insights, color: AppColors.gold, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic
                              ? 'السعرات، البروتين، الكربوهيدرات، الدهون والألياف'
                              : 'Calories, protein, carbs, fat & fibre',
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isArabic
                              ? 'مع إرشادات غذائية عامة مبنية على توصيات WHO.'
                              : 'With general healthy-diet guidance based on WHO recommendations.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textMuted),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
