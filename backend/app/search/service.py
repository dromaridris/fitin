from sqlalchemy import select, or_
from sqlalchemy.orm import Session, joinedload
from app.models.ingredient import Ingredient, IngredientAlias
from app.models.recipe import Recipe
from app.search.normalize import normalized_search_terms

def search_ingredients(db: Session, query: str, limit: int = 20):
    terms = normalized_search_terms(query)
    conditions = []
    for term in terms:
        pattern = f"%{term}%"
        conditions.extend([
            Ingredient.name_en.ilike(pattern),
            Ingredient.name_ar.ilike(pattern),
            Ingredient.name_ro.ilike(pattern),
            Ingredient.canonical_key.ilike(pattern),
            IngredientAlias.alias.ilike(pattern),
        ])

    stmt = (
        select(Ingredient)
        .outerjoin(IngredientAlias)
        .where(or_(*conditions), Ingredient.is_active.is_(True))
        .distinct()
        .limit(limit)
    )
    return db.scalars(stmt).all()

def search_recipes(db: Session, query: str, cuisine: str | None = None, limit: int = 20):
    terms = normalized_search_terms(query)
    conditions = []

    for term in terms:
        pattern = f"%{term}%"
        conditions.extend([
            Recipe.name_en.ilike(pattern),
            Recipe.name_ar.ilike(pattern),
            Recipe.name_ro.ilike(pattern),
            Recipe.cuisine.ilike(pattern),
            IngredientAlias.alias.ilike(pattern),
        ])

    stmt = (
        select(Recipe)
        .options(joinedload(Recipe.ingredients).joinedload("ingredient"))
        .outerjoin(Recipe.ingredients)
        .outerjoin(IngredientAlias)
        .where(or_(*conditions))
    )

    if cuisine:
        stmt = stmt.where(Recipe.cuisine.ilike(cuisine))

    return db.scalars(stmt.distinct().limit(limit)).unique().all()
