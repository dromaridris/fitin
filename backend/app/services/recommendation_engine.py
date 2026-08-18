from sqlalchemy.orm import Session
from sqlalchemy import select
from app.models.recipe import Recipe, RecipeIngredient
from app.models.ingredient import Ingredient

ALIASES = {
    "chicken": {"chicken", "دجاج", "murghi", "murgi"},
    "potato": {"potato", "potatoes", "بطاطا", "بطاطس", "aloo"},
    "tomato": {"tomato", "tomatoes", "بندورة", "طماطم", "tamatar"},
    "onion": {"onion", "بصل", "pyaz"},
    "rice": {"rice", "أرز", "رز", "chawal"},
    "lentil": {"lentil", "عدس", "daal", "dal"},
}

def normalize(value: str) -> str:
    value = value.strip().lower()
    for canonical, names in ALIASES.items():
        if value in names:
            return canonical
    return value

def recommend(db: Session, raw_ingredients: list[str], limit: int = 20):
    available = {normalize(x) for x in raw_ingredients if x.strip()}
    recipes = db.scalars(select(Recipe).order_by(Recipe.id)).all()
    results = []

    for recipe in recipes:
        items = db.query(RecipeIngredient).filter(
            RecipeIngredient.recipe_id == recipe.id
        ).all()

        required = set()
        ingredient_names = {}
        for item in items:
            canonical = normalize(item.ingredient.name_en)
            required.add(canonical)
            ingredient_names[canonical] = item.ingredient.name_en

        if not required:
            continue

        matched = required & available
        missing = required - available
        score = round((len(matched) / len(required)) * 100, 2)

        results.append({
            "recipe_id": recipe.id,
            "name_en": recipe.name_en,
            "name_ar": recipe.name_ar,
            "name_ro": recipe.name_ro,
            "cuisine": recipe.cuisine,
            "match_score": score,
            "matched_count": len(matched),
            "required_count": len(required),
            "missing_count": len(missing),
            "available_ingredients": sorted(matched),
            "missing_ingredients": sorted(
                ingredient_names[x] for x in missing
            ),
            "servings": recipe.servings,
            "prep_minutes": recipe.prep_minutes,
            "cook_minutes": recipe.cook_minutes,
        })

    results.sort(key=lambda x: (-x["match_score"], x["missing_count"], x["cook_minutes"]))
    return results[:limit]
