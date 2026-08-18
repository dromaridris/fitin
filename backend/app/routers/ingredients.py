from fastapi import APIRouter, Depends, Query
from sqlalchemy import select, or_
from sqlalchemy.orm import Session
from app.db import get_db
from app.models.ingredient import Ingredient, IngredientAlias

router = APIRouter(prefix="/ingredients", tags=["Ingredients"])

@router.get("")
def search_ingredients_endpoint(q: str | None = Query(None), db: Session = Depends(get_db)):
    stmt = select(Ingredient).where(Ingredient.is_active.is_(True))
    if q:
        pattern = f"%{q}%"
        stmt = stmt.outerjoin(IngredientAlias).where(
            or_(
                Ingredient.name_en.ilike(pattern),
                Ingredient.name_ar.ilike(pattern),
                Ingredient.name_ro.ilike(pattern),
                IngredientAlias.alias.ilike(pattern),
            )
        ).distinct()
    items = db.scalars(stmt.order_by(Ingredient.name_en)).all()
    return {"items": items, "count": len(items)}
