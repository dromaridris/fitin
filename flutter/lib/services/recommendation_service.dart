import '../models/recommendation.dart';
import 'offline_data.dart';

class RecommendationService {
  RecommendationService([Object? _]);

  List<Recommendation> find(List<String> ingredients) {
    final available = ingredients
        .map(normalizeOfflineIngredient)
        .where((x) => x.isNotEmpty)
        .toSet();
    final out = <Recommendation>[];
    for (final r in offlineRecipes) {
      final required = <String>{};
      final names = <String, String>{};
      for (final ri in r.ingredients) {
        final i = ingredientById(ri.ingredientId);
        required.add(i.key);
        names[i.key] = i.nameEn;
      }
      final matched = required.intersection(available);
      final missing = required.difference(available);
      final score = required.isEmpty ? 0.0 : (matched.length / required.length) * 100.0;
      out.add(Recommendation(
        recipeId: r.id,
        nameEn: r.nameEn,
        nameAr: r.nameAr,
        nameRo: r.nameRo,
        cuisine: r.cuisine,
        matchScore: double.parse(score.toStringAsFixed(2)),
        missingCount: missing.length,
        servings: r.servings,
        prepMinutes: r.prepMinutes,
        cookMinutes: r.cookMinutes,
        missingIngredients: missing.map((x) => names[x]!).toList()..sort(),
      ));
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
