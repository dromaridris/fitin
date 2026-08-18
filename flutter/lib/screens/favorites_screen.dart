import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe_summary.dart';
import '../services/recipe_service.dart';
import '../state/app_state.dart';
import 'recipe_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Directionality(
      textDirection: s.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.isArabic ? 'المفضلة' : 'Favorites'),
        ),
        body: s.favoriteRecipeIds.isEmpty
            ? Center(
                child: Text(
                  s.isArabic
                      ? 'لا توجد وصفات مفضلة'
                      : 'No favorite recipes yet',
                ),
              )
            : FutureBuilder<List<RecipeSummary>>(
                future: RecipeService().search(),
                builder: (_, snap) {
                  if (!snap.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final list = snap.data!
                      .where((r) => s.favoriteRecipeIds.contains(r.id))
                      .toList();
                  return ListView(
                    children: list.map(
                      (r) => ListTile(
                        title: Text(r.title(s.languageCode)),
                        subtitle: Text(r.cuisine),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecipeDetailsScreen(
                              recipeId: r.id,
                              initialServings: r.servings,
                            ),
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.favorite),
                          onPressed: () => s.toggleFavorite(r.id),
                        ),
                      ),
                    ).toList(),
                  );
                },
              ),
      ),
    );
  }
}
