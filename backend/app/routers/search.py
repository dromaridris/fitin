from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.db import get_db
from app.search.service import search_ingredients, search_recipes
from app.schemas import SearchResponse, SearchIngredient, SearchRecipe

router = APIRouter(prefix="/search", tags=["Search"])

@router.get("", response_model=SearchResponse)
def unified_search(
    q: str = Query(min_length=1, max_length=100),
    cuisine: str | None = Query(default=None),
    limit: int = Query(default=20, ge=1, le=50),
    db: Session = Depends(get_db),
):
    ingredients = search_ingredients(db, q, limit)
    recipes = search_recipes(db, q, cuisine, limit)

    return SearchResponse(
        query=q,
        ingredients=[
            SearchIngredient(
                id=x.id,
                name_en=x.name_en,
                name_ar=x.name_ar,
                name_ro=x.name_ro,
            )
            for x in ingredients
        ],
        recipes=[
            SearchRecipe(
                id=x.id,
                name_en=x.name_en,
                name_ar=x.name_ar,
                name_ro=x.name_ro,
                cuisine=x.cuisine,
                servings=x.servings,
                prep_minutes=x.prep_minutes,
                cook_minutes=x.cook_minutes,
            )
            for x in recipes
        ],
    )
