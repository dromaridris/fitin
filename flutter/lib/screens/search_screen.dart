import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe_summary.dart';
import '../services/recipe_service.dart';
import '../state/app_state.dart';
import '../widgets/larc_chip.dart';
import '../widgets/larc_input.dart';
import 'recipe_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final service = RecipeService();
  final controller = TextEditingController();
  String? cuisine;
  late List<RecipeSummary> items;

  @override
  void initState() {
    super.initState();
    items = service.search();
  }

  void runSearch() {
    setState(() {
      items = service.search(query: controller.text, cuisine: cuisine);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();

    return Directionality(
      textDirection: s.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(title: Text(s.isArabic ? 'البحث' : 'Recipe Search')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: LarcTextField(
                controller: controller,
                onSubmitted: (_) => runSearch(),
                textDirection:
                    s.isArabic ? TextDirection.rtl : TextDirection.ltr,
                hintText: s.isArabic
                    ? 'دجاج، مجدرة، aloo...'
                    : 'chicken, mujaddara, aloo...',
                prefixIcon: Icons.search,
                suffixIcon: IconButton(
                  onPressed: runSearch,
                  icon: const Icon(Icons.arrow_forward),
                ),
              ),
            ),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _filter('All', null),
                  _filter('Pakistani', 'Pakistani'),
                  _filter('Syrian', 'Syrian'),
                  _filter('Arabic', 'Arabic'),
                  _filter('International', 'International'),
                ],
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        s.isArabic ? 'لا توجد وصفات' : 'No recipes found',
                      ),
                    )
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final r = items[i];
                        return ListTile(
                          title: Text(r.title(s.languageCode)),
                          subtitle: Text(
                            '${r.cuisine} • ${r.prepMinutes + r.cookMinutes} min',
                          ),
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
                            icon: Icon(
                              s.isFavorite(r.id)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                            ),
                            onPressed: () => s.toggleFavorite(r.id),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filter(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: LarcFilterChip(
        label: label,
        selected: cuisine == value,
        onSelected: (_) {
          cuisine = value;
          runSearch();
        },
      ),
    );
  }
}
