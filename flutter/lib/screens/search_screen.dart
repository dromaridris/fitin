import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe_summary.dart';
import '../services/offline_data.dart';
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
  final RecipeService service = RecipeService();
  final TextEditingController controller = TextEditingController();
  List<RecipeSummary> items = const [];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void runSearch() {
    final selected = context.read<AppState>().selectedCuisine;
    if (selected == null) {
      setState(() => items = const []);
      return;
    }
    setState(() {
      items = service.search(query: controller.text, cuisine: selected);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final selected = s.selectedCuisine;

    return Directionality(
      textDirection: s.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(title: Text(s.isArabic ? 'البحث' : 'Recipe Search')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  s.isArabic ? '1. اختر المطبخ أولاً' : '1. Choose a cuisine first',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _filter(context, 'Pakistani'),
                  _filter(context, 'Syrian'),
                  _filter(context, 'European'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: LarcTextField(
                controller: controller,
                onSubmitted: (_) => runSearch(),
                textDirection: s.isArabic ? TextDirection.rtl : TextDirection.ltr,
                hintText: selected == null
                    ? (s.isArabic ? 'اختر المطبخ أولاً' : 'Choose cuisine first')
                    : (s.isArabic ? 'دجاج، مجدرة، بطاطا...' : 'chicken, mujaddara, aloo...'),
                prefixIcon: Icons.search,
                suffixIcon: IconButton(
                  onPressed: selected == null ? null : runSearch,
                  icon: const Icon(Icons.arrow_forward),
                ),
              ),
            ),
            if (selected != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    '${s.isArabic ? "المطبخ" : "Cuisine"}: ${cuisineLabel(selected, s.languageCode)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            const SizedBox(height: 6),
            Expanded(
              child: selected == null
                  ? Center(
                      child: Text(
                        s.isArabic
                            ? 'اختر باكستاني أو شامي/سوري أو أوروبي قبل البحث.'
                            : 'Select Pakistani, Syrian or European before searching.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : items.isEmpty
                      ? Center(
                          child: Text(
                            controller.text.trim().isEmpty
                                ? (s.isArabic ? 'اكتب اسم وصفة أو مكوّن' : 'Type a recipe or ingredient')
                                : (s.isArabic ? 'لا توجد وصفات مطابقة في هذا المطبخ' : 'No matching recipes in this cuisine'),
                          ),
                        )
                      : ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (_, i) {
                            final r = items[i];
                            return ListTile(
                              title: Text(r.title(s.languageCode)),
                              subtitle: Text(
                                '${cuisineLabel(r.cuisine, s.languageCode)} • ${r.prepMinutes + r.cookMinutes} min',
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
                                  s.isFavorite(r.id) ? Icons.favorite : Icons.favorite_border,
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

  Widget _filter(BuildContext context, String value) {
    final s = context.watch<AppState>();
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: LarcFilterChip(
        label: cuisineLabel(value, s.languageCode),
        selected: s.selectedCuisine == value,
        onSelected: (_) async {
          await s.setCuisine(value);
          runSearch();
        },
      ),
    );
  }
}
