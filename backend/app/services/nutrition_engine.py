from dataclasses import dataclass

@dataclass
class Nutrition:
    calories: float = 0.0
    protein_g: float = 0.0
    carbs_g: float = 0.0
    fat_g: float = 0.0
    fiber_g: float = 0.0

    def add(self, other):
        self.calories += other.calories
        self.protein_g += other.protein_g
        self.carbs_g += other.carbs_g
        self.fat_g += other.fat_g
        self.fiber_g += other.fiber_g
        return self

    def rounded(self):
        return {k: round(v, 1) for k, v in self.__dict__.items()}

def ingredient_nutrition(ingredient, quantity_g):
    f = quantity_g / 100.0
    return Nutrition(
        ingredient.calories_per_100g * f,
        ingredient.protein_per_100g * f,
        ingredient.carbs_per_100g * f,
        ingredient.fat_per_100g * f,
        ingredient.fiber_per_100g * f,
    )

def recipe_nutrition(recipe):
    total = Nutrition()
    for link in recipe.ingredients:
        total.add(ingredient_nutrition(link.ingredient, link.quantity_g))
    return total

def per_serving(total, servings):
    if servings <= 0:
        raise ValueError("Servings must be greater than zero")
    return Nutrition(
        total.calories / servings,
        total.protein_g / servings,
        total.carbs_g / servings,
        total.fat_g / servings,
        total.fiber_g / servings,
    )

def scale_nutrition(total, original_servings, new_servings):
    if original_servings <= 0 or new_servings <= 0:
        raise ValueError("Servings must be greater than zero")
    f = new_servings / original_servings
    return Nutrition(
        total.calories * f,
        total.protein_g * f,
        total.carbs_g * f,
        total.fat_g * f,
        total.fiber_g * f,
    )
