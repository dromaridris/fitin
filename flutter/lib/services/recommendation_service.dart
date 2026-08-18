import '../models/recommendation.dart';
import 'api_client.dart';

class RecommendationService {
  final ApiClient client;
  RecommendationService([ApiClient? api]) : client = api ?? ApiClient();

  Future<List<Recommendation>> find(List<String> ingredients) async {
    final data = await client.post(
      '/recommendations/what-do-i-have',
      {'ingredients': ingredients, 'limit': 20},
    );
    final list = (data['results'] ?? data['data']?['results'] ?? []) as List;
    return list.map((e) => Recommendation.fromJson(e)).toList();
  }
}
