import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../state/app_state.dart';

class DailyNutritionSummary {
  final double consumedCalories, targetCalories, remainingCalories;
  final double proteinG, carbsG, fatG, progressPercent;

  DailyNutritionSummary({
    required this.consumedCalories,
    required this.targetCalories,
    required this.remainingCalories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.progressPercent,
  });

  factory DailyNutritionSummary.fromJson(Map<String, dynamic> j) =>
      DailyNutritionSummary(
        consumedCalories: (j['consumed_calories'] as num).toDouble(),
        targetCalories: (j['target_calories'] as num).toDouble(),
        remainingCalories: (j['remaining_calories'] as num).toDouble(),
        proteinG: (j['protein_g'] as num).toDouble(),
        carbsG: (j['carbs_g'] as num).toDouble(),
        fatG: (j['fat_g'] as num).toDouble(),
        progressPercent: (j['progress_percent'] as num).toDouble(),
      );
}

/// Wraps POST /nutrition-log/summary — the backend computes
/// consumed / target / remaining calories from today's logged items.
/// This intentionally uses the existing Nutrition Engine math on the
/// server, not a client-side estimate or AI call.
class NutritionLogService {
  Future<DailyNutritionSummary> summarize({
    required double calorieTarget,
    required List<FoodLogItem> items,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/nutrition-log/summary'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'calorie_target': calorieTarget,
        'items': items
            .map((e) => {
                  'name': e.name,
                  'calories': e.calories,
                  'protein_g': e.proteinG,
                  'carbs_g': e.carbsG,
                  'fat_g': e.fatG,
                })
            .toList(),
      }),
    );
    if (response.statusCode >= 400) {
      throw Exception('Daily nutrition summary failed');
    }
    final json = jsonDecode(response.body);
    return DailyNutritionSummary.fromJson(json['data']);
  }
}
