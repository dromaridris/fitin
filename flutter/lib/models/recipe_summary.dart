class RecipeSummary {
  final int id;
  final String nameEn, nameAr, nameRo, cuisine;
  final int servings, prepMinutes, cookMinutes;

  const RecipeSummary({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.nameRo,
    required this.cuisine,
    required this.servings,
    required this.prepMinutes,
    required this.cookMinutes,
  });

  factory RecipeSummary.fromJson(Map<String, dynamic> j) => RecipeSummary(
    id: j['id'],
    nameEn: j['name_en'],
    nameAr: j['name_ar'],
    nameRo: j['name_ro'],
    cuisine: j['cuisine'],
    servings: j['servings'],
    prepMinutes: j['prep_minutes'],
    cookMinutes: j['cook_minutes'],
  );

  String title(String code) {
    if (code == 'ar') return nameAr;
    if (code == 'ro') return nameRo;
    return nameEn;
  }
}
