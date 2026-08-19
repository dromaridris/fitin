import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recommendation.dart';
import '../services/offline_data.dart';
import '../services/recommendation_service.dart';
import '../state/app_state.dart';
import '../widgets/larc_button.dart';
import '../widgets/larc_chip.dart';
import '../widgets/larc_input.dart';
import '../widgets/larc_progress.dart';
import 'recipe_details_screen.dart';

class WhatDoIHaveScreen extends StatefulWidget {
  const WhatDoIHaveScreen({super.key});

  @override
  State<WhatDoIHaveScreen> createState() => _WhatDoIHaveScreenState();
}

class _WhatDoIHaveScreenState extends State<WhatDoIHaveScreen> {
  final controller = TextEditingController();
  final service = RecommendationService();
  List<Recommendation>? results;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void find() {
    final s = context.read<AppState>();
    if (s.selectedCuisine == null || s.selectedIngredients.isEmpty) {
      setState(() => results = []);
      return;
    }
    setState(() {
      results = service.find(
        s.selectedIngredients,
        cuisine: s.selectedCuisine!,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();

    return Directionality(
      textDirection: s.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(title: Text(s.isArabic ? 'ماذا لدي؟' : 'What Do I Have?')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  s.isArabic ? '1. اختر المطبخ' : '1. Choose cuisine',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Pakistani', 'Syrian', 'European'].map((value) {
                  return LarcFilterChip(
                    label: cuisineLabel(value, s.languageCode),
                    selected: s.selectedCuisine == value,
                    onSelected: (_) async {
                      await s.setCuisine(value);
                      setState(() => results = null);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  s.isArabic ? '2. أضف المكونات الموجودة عندك' : '2. Add the ingredients you have',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: LarcTextField(
                      controller: controller,
                      textDirection: s.isArabic ? TextDirection.rtl : TextDirection.ltr,
                      onSubmitted: (_) {
                        s.addIngredient(controller.text);
                        controller.clear();
                      },
                      hintText: s.isArabic ? 'دجاج، بطاطا، بصل...' : 'chicken, potato, onion...',
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      s.addIngredient(controller.text);
                      controller.clear();
                    },
                    icon: const Icon(Icons.add_circle),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: s.selectedIngredients
                      .map((x) => LarcInputChip(label: x, onDeleted: () => s.removeIngredient(x)))
                      .toList(),
                ),
              ),
              const SizedBox(height: 12),
              LarcPrimaryButton(
                label: s.isArabic ? 'اعرض الوصفات المطابقة' : 'Find Matching Recipes',
                icon: Icons.search,
                onPressed: s.selectedCuisine == null || s.selectedIngredients.isEmpty ? null : find,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: results == null
                    ? Center(
                        child: Text(
                          s.selectedCuisine == null
                              ? (s.isArabic ? 'اختر المطبخ أولاً' : 'Choose cuisine first')
                              : (s.isArabic ? 'أدخل مكوناتك ثم اضغط اعرض الوصفات' : 'Add ingredients, then find recipes'),
                        ),
                      )
                    : results!.isEmpty
                        ? Center(
                            child: Text(
                              s.isArabic
                                  ? 'لا توجد وصفات في هذا المطبخ تطابق مكوّناً أساسياً من الموجود عندك.'
                                  : 'No recipes in this cuisine match a meaningful core ingredient you have.',
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            itemCount: results!.length,
                            itemBuilder: (_, i) {
                              final r = results![i];
                              return Card(
                                child: ListTile(
                                  leading: LarcProgressRing(
                                    value: r.matchScore / 100,
                                    label: '${r.matchScore.round()}%',
                                    size: 44,
                                  ),
                                  title: Text(r.title(s.languageCode)),
                                  subtitle: Text(
                                    '${r.missingCount} ${s.isArabic ? "مكوّن أساسي ناقص" : "core missing"} • ${cuisineLabel(r.cuisine, s.languageCode)}',
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RecipeDetailsScreen(
                                        recipeId: r.recipeId,
                                        fallbackMissing: r.missingIngredients,
                                        initialServings: r.servings,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
