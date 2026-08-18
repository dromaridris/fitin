import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/nutrition_profile.dart';

class NutritionProfileService {
  Future<NutritionProfileResult> calculate({
    required int age,
    required String sex,
    required double heightCm,
    required double weightKg,
    required String activityLevel,
    bool breastfeeding = false,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/profile/nutrition/calculate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'age': age,
        'sex': sex,
        'height_cm': heightCm,
        'weight_kg': weightKg,
        'activity_level': activityLevel,
        'breastfeeding': breastfeeding,
      }),
    );
    if (response.statusCode >= 400) {
      throw Exception('Profile calculation failed');
    }
    final json = jsonDecode(response.body);
    return NutritionProfileResult.fromJson(json['data']);
  }
}
