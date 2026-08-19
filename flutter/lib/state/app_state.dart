import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { english, arabic, romanUrdu }

/// A single food item logged against today's date.
class FoodLogItem {
  final String name;
  final double calories, proteinG, carbsG, fatG, fiberG;

  FoodLogItem({
    required this.name,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.fiberG = 0,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'calories': calories,
        'protein_g': proteinG,
        'carbs_g': carbsG,
        'fat_g': fatG,
        'fiber_g': fiberG,
      };

  factory FoodLogItem.fromJson(Map<String, dynamic> j) => FoodLogItem(
        name: j['name'] as String,
        calories: (j['calories'] as num).toDouble(),
        proteinG: (j['protein_g'] as num? ?? 0).toDouble(),
        carbsG: (j['carbs_g'] as num? ?? 0).toDouble(),
        fatG: (j['fat_g'] as num? ?? 0).toDouble(),
        fiberG: (j['fiber_g'] as num? ?? 0).toDouble(),
      );
}

class AppState extends ChangeNotifier {
  AppLanguage language = AppLanguage.english;
  final List<String> selectedIngredients = [];
  final Set<int> favoriteRecipeIds = {};
  String? selectedCuisine;

  /// Today's logged food items (persisted locally, keyed by date so it
  /// resets each day) and the user's daily calorie target (from the
  /// Nutrition Dashboard profile calculation, or a default of 2000).
  final List<FoodLogItem> todayLog = [];
  double calorieTarget = 2000;

  bool get isArabic => language == AppLanguage.arabic;
  String get languageCode {
    switch (language) {
      case AppLanguage.arabic:
        return 'ar';
      case AppLanguage.romanUrdu:
        return 'ro';
      case AppLanguage.english:
        return 'en';
    }
  }

  String get _todayKey =>
      'food_log_${DateTime.now().toIso8601String().substring(0, 10)}';

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    favoriteRecipeIds.addAll(
      (prefs.getStringList('favorite_recipe_ids') ?? []).map(int.parse),
    );
    calorieTarget = prefs.getDouble('calorie_target') ?? 2000;
    selectedCuisine = prefs.getString('selected_cuisine');
    final raw = prefs.getStringList(_todayKey) ?? [];
    todayLog
      ..clear()
      ..addAll(raw.map((s) => FoodLogItem.fromJson(jsonDecode(s))));
    notifyListeners();
  }

  Future<void> _persistFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'favorite_recipe_ids',
      favoriteRecipeIds.map((e) => '$e').toList(),
    );
  }

  Future<void> _persistTodayLog() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _todayKey,
      todayLog.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<void> addToTodayLog(FoodLogItem item) async {
    todayLog.add(item);
    await _persistTodayLog();
    notifyListeners();
  }

  Future<void> removeFromTodayLog(int index) async {
    todayLog.removeAt(index);
    await _persistTodayLog();
    notifyListeners();
  }

  Future<void> setCalorieTarget(double value) async {
    calorieTarget = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('calorie_target', value);
    notifyListeners();
  }


  Future<void> setCuisine(String? value) async {
    selectedCuisine = value;
    final prefs = await SharedPreferences.getInstance();
    if (value == null || value.isEmpty) {
      await prefs.remove('selected_cuisine');
    } else {
      await prefs.setString('selected_cuisine', value);
    }
    notifyListeners();
  }

  double get consumedCalories =>
      todayLog.fold(0.0, (sum, item) => sum + item.calories);

  double get remainingCalories =>
      (calorieTarget - consumedCalories).clamp(0.0, double.infinity).toDouble();

  void setLanguage(AppLanguage value) {
    language = value;
    notifyListeners();
  }

  void addIngredient(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty || selectedIngredients.contains(normalized)) return;
    selectedIngredients.add(normalized);
    notifyListeners();
  }

  void removeIngredient(String value) {
    selectedIngredients.remove(value);
    notifyListeners();
  }

  void clearIngredients() {
    selectedIngredients.clear();
    notifyListeners();
  }

  void toggleFavorite(int id) {
    if (favoriteRecipeIds.contains(id)) {
      favoriteRecipeIds.remove(id);
    } else {
      favoriteRecipeIds.add(id);
    }
    _persistFavorites();
    notifyListeners();
  }

  bool isFavorite(int id) => favoriteRecipeIds.contains(id);
}

