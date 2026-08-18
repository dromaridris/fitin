from types import SimpleNamespace
from app.services.nutrition_engine import ingredient_nutrition, recipe_nutrition, per_serving

def test_ingredient():
    i = SimpleNamespace(calories_per_100g=100, protein_per_100g=10, carbs_per_100g=20, fat_per_100g=5, fiber_per_100g=2)
    assert ingredient_nutrition(i, 250).calories == 250

def test_recipe():
    i = SimpleNamespace(calories_per_100g=100, protein_per_100g=10, carbs_per_100g=20, fat_per_100g=5, fiber_per_100g=2)
    r = SimpleNamespace(servings=2, ingredients=[
        SimpleNamespace(ingredient=i, quantity_g=200),
        SimpleNamespace(ingredient=i, quantity_g=100),
    ])
    assert recipe_nutrition(r).calories == 300
    assert per_serving(recipe_nutrition(r), 2).calories == 150
