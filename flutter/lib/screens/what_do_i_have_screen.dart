import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recommendation.dart';
import '../services/recommendation_service.dart';
import '../state/app_state.dart';
import '../widgets/larc_button.dart';
import '../widgets/larc_chip.dart';
import '../widgets/larc_input.dart';
import '../widgets/larc_progress.dart';
import 'recipe_details_screen.dart';

class WhatDoIHaveScreen extends StatefulWidget {
  const WhatDoIHaveScreen({super.key});
  @override State<WhatDoIHaveScreen> createState() => _WhatDoIHaveScreenState();
}

class _WhatDoIHaveScreenState extends State<WhatDoIHaveScreen> {
  final controller = TextEditingController();
  final service = RecommendationService();
  Future<List<Recommendation>>? future;

  void find() {
    final s = context.read<AppState>();
    if (s.selectedIngredients.isEmpty) return;
    setState(() => future = service.find(s.selectedIngredients));
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Directionality(
      textDirection: s.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.isArabic ? 'ماذا لدي؟' : 'What Do I Have?'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: LarcTextField(
                      controller: controller,
                      textDirection:
                          s.isArabic ? TextDirection.rtl : TextDirection.ltr,
                      onSubmitted: (_) {
                        s.addIngredient(controller.text);
                        controller.clear();
                      },
                      hintText: s.isArabic
                          ? 'دجاج، بطاطا...'
                          : 'chicken, potato...',
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
                  children: s.selectedIngredients.map(
                    (x) => LarcInputChip(
                      label: x,
                      onDeleted: () => s.removeIngredient(x),
                    ),
                  ).toList(),
                ),
              ),
              const SizedBox(height: 12),
              LarcPrimaryButton(
                label: s.isArabic ? 'اعرض الوصفات' : 'Find Recipes',
                icon: Icons.search,
                onPressed: find,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: future == null
                    ? Center(
                        child: Text(
                          s.isArabic
                              ? 'أدخل مكوناتك أولاً'
                              : 'Add your ingredients first',
                        ),
                      )
                    : FutureBuilder<List<Recommendation>>(
                        future: future,
                        builder: (_, snap) {
                          if (snap.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snap.hasError) {
                            return Center(
                              child: Text(
                                s.isArabic
                                    ? 'تعذر تحميل الاقتراحات'
                                    : 'Could not load recommendations',
                              ),
                            );
                          }
                          final list = snap.data ?? [];
                          if (list.isEmpty) {
                            return Center(
                              child: Text(
                                s.isArabic
                                    ? 'لا توجد وصفات مناسبة'
                                    : 'No suitable recipes',
                              ),
                            );
                          }
                          return ListView.builder(
                            itemCount: list.length,
                            itemBuilder: (_, i) {
                              final r = list[i];
                              return Card(
                                child: ListTile(
                                  leading: LarcProgressRing(
                                    value: r.matchScore / 100,
                                    label: '${r.matchScore.round()}%',
                                    size: 44,
                                  ),
                                  title: Text(r.title(s.languageCode)),
                                  subtitle: Text(
                                    '${r.missingCount} missing • ${r.cuisine}',
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RecipeDetailsScreen(
                                        recipeId: r.recipeId,
                                        fallbackMissing:
                                            r.missingIngredients,
                                        initialServings: r.servings,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
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
