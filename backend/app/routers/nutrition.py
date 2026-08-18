from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy import select
from sqlalchemy.orm import Session, joinedload
from app.db import get_db
from app.models import Recipe
from app.services.nutrition_engine import recipe_nutrition, per_serving, scale_nutrition
router=APIRouter(prefix='/nutrition',tags=['Nutrition'])
class ScaleRequest(BaseModel): servings:int=Field(gt=0,le=100)
class MealItem(BaseModel): calories:float=Field(ge=0); protein_g:float=Field(default=0,ge=0); carbs_g:float=Field(default=0,ge=0); fat_g:float=Field(default=0,ge=0); fiber_g:float=Field(default=0,ge=0)
class MealRequest(BaseModel): items:list[MealItem]
def load_recipe(id,db):
    r=db.scalar(select(Recipe).options(joinedload(Recipe.ingredients).joinedload('ingredient')).where(Recipe.id==id))
    if not r: raise HTTPException(404,'Recipe not found')
    return r
@router.post('/recipe/{recipe_id}')
def calculate(recipe_id:int,db:Session=Depends(get_db)):
    r=load_recipe(recipe_id,db); total=recipe_nutrition(r)
    return {'success':True,'data':{'recipe_id':r.id,'servings':r.servings,'total':total.rounded(),'per_serving':per_serving(total,r.servings).rounded()}}
@router.post('/recipe/{recipe_id}/scale')
def scale(recipe_id:int,payload:ScaleRequest,db:Session=Depends(get_db)):
    r=load_recipe(recipe_id,db); total=recipe_nutrition(r); scaled=scale_nutrition(total,r.servings,payload.servings); f=payload.servings/r.servings
    return {'success':True,'data':{'recipe_id':r.id,'original_servings':r.servings,'new_servings':payload.servings,'ingredients':[{'ingredient_id':x.ingredient_id,'name_en':x.ingredient.name_en,'quantity_g':round(x.quantity_g*f,2)} for x in r.ingredients],'nutrition':scaled.rounded(),'nutrition_per_serving':per_serving(scaled,payload.servings).rounded()}}
@router.post('/meal')
def meal(payload:MealRequest):
    ks=['calories','protein_g','carbs_g','fat_g','fiber_g']; return {'success':True,'data':{k:round(sum(getattr(x,k) for x in payload.items),1) for k in ks}}
