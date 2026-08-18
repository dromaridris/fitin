import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../state/app_state.dart';
import '../widgets/larc_button.dart';

/// Serving calculator + nutrition breakdown for a single recipe.
///
/// IMPORTANT FIX: the previous version of this screen posted a
/// `{servings: N}` body to `POST /nutrition/recipe/{id}`, but that
/// endpoint ignores its body entirely and always returns nutrition
/// for the recipe's fixed default serving count — so the +/- serving
/// controls did nothing. This version calls the correct endpoint,
/// `POST /nutrition/recipe/{id}/scale`, which actually scales both
/// the ingredient quantities and the nutrition totals.
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
  late Future<Map<String, dynamic>> future;
  bool _addedToday = false;

  @override
  void initState() {
    super.initState();
    servings = widget.initialServings < 1 ? 1 : widget.initialServings;
    future = calculate();
  }

  Future<Map<String, dynamic>> calculate() async {
    final r = await http.post(
      Uri.parse(
        '${AppConfig.apiBaseUrl}/nutrition/recipe/${widget.recipeId}/scale',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'servings': servings}),
    );
    if (r.statusCode >= 400) throw Exception('Nutrition scaling failed');
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  void change(int value) {
    if (value < 1 || value > 100) return;
    setState(() {
      servings = value;
      _addedToday = false;
      future = calculate();
    });
  }

  void addToToday(Map<String, dynamic> nutrition) {
    final state = context.read<AppState>();
    state.addToTodayLog(
      FoodLogItem(
        name: widget.recipeTitle ?? 'Recipe #${widget.recipeId}',
        calories: (nutrition['calories'] as num? ?? 0).toDouble(),
        proteinG: (nutrition['protein_g'] as num? ?? 0).toDouble(),
        carbsG: (nutrition['carbs_g'] as num? ?? 0).toDouble(),
        fatG: (nutrition['fat_g'] as num? ?? 0).toDouble(),
      ),
    );
    setState(() => _addedToday = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.read<AppState>().isArabic
              ? 'أُضيف إلى سعرات اليوم'
              : "Added to today's calories",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Directionality(
      textDirection: s.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.isArabic ? 'السعرات والكميات' : 'Nutrition'),
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: future,
          builder: (_, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError || !snap.hasData) {
              return const Center(child: Text('Nutrition calculation failed'));
            }
            final data = snap.data!['data'] ?? snap.data!;
            final total = (data['nutrition'] ?? {}) as Map<String, dynamic>;
            final perServing =
                (data['nutrition_per_serving'] ?? {}) as Map<String, dynamic>;
            final ingredients = (data['ingredients'] ?? []) as List;
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(s.isArabic ? 'الحصص' : 'Servings'),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => change(servings - 1),
                            icon: const Icon(Icons.remove),
                          ),
                          Text('$servings'),
                          IconButton(
                            onPressed: () => change(servings + 1),
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  s.isArabic
                      ? 'الإجمالي لـ $servings حصص'
                      : 'Total for $servings serving(s)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _metric('Calories', '${total['calories'] ?? 0} kcal'),
                    _metric('Protein', '${total['protein_g'] ?? 0} g'),
                    _metric('Carbs', '${total['carbs_g'] ?? 0} g'),
                    _metric('Fat', '${total['fat_g'] ?? 0} g'),
                    _metric('Fiber', '${total['fiber_g'] ?? 0} g'),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  s.isArabic ? 'لكل حصة' : 'Per Serving',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '${perServing['calories'] ?? 0} kcal • '
                  '${perServing['protein_g'] ?? 0}g P • '
                  '${perServing['carbs_g'] ?? 0}g C • '
                  '${perServing['fat_g'] ?? 0}g F',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                LarcPrimaryButton(
                  label: _addedToday
                      ? (s.isArabic ? 'أُضيف ✓' : 'Added ✓')
                      : (s.isArabic
                          ? 'أضف إلى سعرات اليوم'
                          : "Add to Today's Calories"),
                  icon: Icons.add_circle_outline,
                  onPressed: _addedToday ? null : () => addToToday(total),
                ),
                const SizedBox(height: 20),
                Text(
                  s.isArabic ? 'الكميات' : 'Scaled Quantities',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ...ingredients.map(
                  (i) => ListTile(
                    title: Text(i['name_en'] ?? ''),
                    trailing: Text('${i['quantity_g']} g'),
                  ),
                ),
              ],
            );
          },
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
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
