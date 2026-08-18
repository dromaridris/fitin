from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session, joinedload
from app.db import get_db
from app.models import Recipe
router=APIRouter(prefix='/recipes',tags=['Recipes'])
@router.get('')
def search_recipes(q:str='',cuisine:str='',db:Session=Depends(get_db)):
    stmt=select(Recipe).order_by(Recipe.name_en)
    if q.strip():
        t=f'%{q.strip()}%'; stmt=stmt.where(Recipe.name_en.ilike(t)|Recipe.name_ar.ilike(t)|Recipe.name_ro.ilike(t))
    if cuisine.strip(): stmt=stmt.where(Recipe.cuisine.ilike(cuisine.strip()))
    return {'success':True,'data':{'items':[{'id':r.id,'name_en':r.name_en,'name_ar':r.name_ar,'name_ro':r.name_ro,'cuisine':r.cuisine,'servings':r.servings,'prep_minutes':r.prep_minutes,'cook_minutes':r.cook_minutes} for r in db.scalars(stmt).all()]}}
@router.get('/{recipe_id}')
def detail(recipe_id:int,db:Session=Depends(get_db)):
    r=db.scalar(select(Recipe).options(joinedload(Recipe.ingredients).joinedload('ingredient')).where(Recipe.id==recipe_id))
    if not r: raise HTTPException(404,'Recipe not found')
    return {'success':True,'data':{'id':r.id,'name_en':r.name_en,'name_ar':r.name_ar,'name_ro':r.name_ro,'cuisine':r.cuisine,'description_en':r.description_en,'description_ar':r.description_ar,'servings':r.servings,'prep_minutes':r.prep_minutes,'cook_minutes':r.cook_minutes,'ingredients':[{'ingredient_id':x.ingredient_id,'name_en':x.ingredient.name_en,'name_ar':x.ingredient.name_ar,'name_ro':x.ingredient.name_ro,'quantity_g':x.quantity_g} for x in r.ingredients]}}
