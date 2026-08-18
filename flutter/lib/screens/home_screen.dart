import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe_summary.dart';
import '../services/recipe_service.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/app_language_menu.dart';
import '../widgets/larc_button.dart';
import '../widgets/larc_card.dart';
import '../widgets/larc_logo.dart';
import 'nutrition_dashboard_screen.dart';
import 'recipe_details_screen.dart';
import 'search_screen.dart';
import 'what_do_i_have_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RecipeService _recipeService = RecipeService();
  late final List<RecipeSummary> _recommended;

  @override
  void initState() {
    super.initState();
    _recommended = _recipeService.search();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isArabic = state.isArabic;

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
                    isArabic
                        ? 'أخبرنا بمكوناتك، وسنجهز لك وصفة مناسبة'
                        : "Tell us what's in your kitchen —\nwe'll turn it into a meal.",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  LarcPrimaryButton(
                    label: isArabic ? 'ابدأ الطبخ' : 'Start Cooking',
                    icon: Icons.local_fire_department,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WhatDoIHaveScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LarcSecondaryButton(
              label: isArabic ? 'ابحث عن وصفات' : 'Search Recipes',
              icon: Icons.search,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              ),
            ),
            const SizedBox(height: 32),
            LarcSectionHeader(
              eyebrow: isArabic ? 'مقترحة' : 'RECOMMENDED',
              title: isArabic ? 'وصفات مقترحة' : 'Recommended Recipes',
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 132,
              child: _recommended.isEmpty
                  ? Center(
                      child: Text(
                        isArabic ? 'لا توجد وصفات بعد' : 'No recipes yet',
                      ),
                    )
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _recommended.length > 6
                          ? 6
                          : _recommended.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, index) {
                        final recipe = _recommended[index];
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
                                  '${recipe.cuisine} • ${recipe.prepMinutes + recipe.cookMinutes} min',
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
                MaterialPageRoute(
                  builder: (_) => const NutritionDashboardScreen(),
                ),
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
                              ? 'السعرات، البروتين، الكربوهيدرات، الدهون'
                              : 'Calories, protein, carbs, fat & fiber',
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isArabic
                              ? 'اضغط لعرض ملفك الغذائي (BMI · BMR · TDEE)'
                              : 'Tap to view your profile (BMI · BMR · TDEE)',
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
