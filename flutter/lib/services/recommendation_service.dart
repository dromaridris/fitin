import '../models/recommendation.dart';
import 'offline_data.dart';

class RecommendationService {
  RecommendationService([Object? _]);

  static const Set<String> _pantry = {
    'onion',
    'garlic',
    'ginger',
    'tomato',
    'tomato_paste',
    'olive_oil',
    'ghee',
    'butter',
    'green_chili',
    'coriander',
    'parsley',
    'mint',
    'lemon',
    'stock',
  };

  List<Recommendation> find(
    List<String> ingredients, {
    required String cuisine,
  }) {
    final available = ingredients
        .map(normalizeOfflineIngredient)
        .where((x) => x.isNotEmpty)
        .toSet();
    final out = <Recommendation>[];

    for (final r in offlineRecipes.where((x) => x.cuisine == cuisine)) {
      final required = <String>{};
      final core = <String>{};
      final names = <String, String>{};

      for (final ri in r.ingredients) {
        final i = ingredientById(ri.ingredientId);
        required.add(i.key);
        if (!_pantry.contains(i.key)) core.add(i.key);
        names[i.key] = i.nameEn;
      }

      final matchedAll = required.intersection(available);
      final matchedCore = core.intersection(available);

      // Do not recommend a dish just because onion/garlic/oil matched.
      // At least one meaningful/core ingredient must be present.
      if (core.isNotEmpty && matchedCore.isEmpty) continue;
      if (core.isEmpty && matchedAll.isEmpty) continue;

      final coreCoverage = core.isEmpty ? 1.0 : matchedCore.length / core.length;
      final allCoverage = required.isEmpty ? 0.0 : matchedAll.length / required.length;
      final score = (coreCoverage * 0.8 + allCoverage * 0.2) * 100.0;

      final missingCore = core.difference(available);
      out.add(
        Recommendation(
          recipeId: r.id,
          nameEn: r.nameEn,
          nameAr: r.nameAr,
          nameRo: r.nameRo,
          cuisine: r.cuisine,
          matchScore: double.parse(score.toStringAsFixed(2)),
          missingCount: missingCore.length,
          servings: r.servings,
          prepMinutes: r.prepMinutes,
          cookMinutes: r.cookMinutes,
          missingIngredients: missingCore.map((x) => names[x]!).toList()..sort(),
        ),
      );
    }

    out.sort((a, b) {
      final c = b.matchScore.compareTo(a.matchScore);
      if (c != 0) return c;
      final m = a.missingCount.compareTo(b.missingCount);
      if (m != 0) return m;
      return a.cookMinutes.compareTo(b.cookMinutes);
    });
    return out.take(20).toList();
  }
}
