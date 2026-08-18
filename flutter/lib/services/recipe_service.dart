import '../models/recipe_summary.dart';
import '../models/recipe_detail.dart';
import 'api_client.dart';

class RecipeService {
  final ApiClient client;
  RecipeService([ApiClient? api]) : client = api ?? ApiClient();

  Future<List<RecipeSummary>> search({
    String query = '',
    String? cuisine,
  }) async {
    final data = await client.get(
      '/recipes',
      query: {
        if (query.trim().isNotEmpty) 'q': query.trim(),
        if (cuisine != null && cuisine.isNotEmpty) 'cuisine': cuisine,
      },
    );
    final list = (data['items'] ?? data['data']?['items'] ?? []) as List;
    return list.map((e) => RecipeSummary.fromJson(e)).toList();
  }

  Future<RecipeDetail> getDetail(int recipeId) async {
    final data = await client.get('/recipes/$recipeId');
    final payload = (data['data'] ?? data) as Map<String, dynamic>;
    return RecipeDetail.fromJson(payload);
  }
}
