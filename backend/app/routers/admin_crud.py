from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session
from app.db import get_db
from app.models import Ingredient, Recipe, RecipeIngredient
from app.schemas import IngredientCreate, IngredientOut, RecipeCreate, RecipeOut

router = APIRouter(prefix='/admin', tags=['Admin CRUD'])

@router.post('/ingredients', response_model=IngredientOut)
def create_ingredient(payload: IngredientCreate, db: Session = Depends(get_db)):
    if db.scalar(select(Ingredient).where(Ingredient.canonical_key == payload.canonical_key)):
        raise HTTPException(409, 'Ingredient already exists')
    item = Ingredient(**payload.model_dump(exclude={'aliases'})); db.add(item); db.flush()
    for a in payload.aliases: db.add(__import__('app.models', fromlist=['IngredientAlias']).IngredientAlias(ingredient_id=item.id, **a.model_dump()))
    db.commit(); db.refresh(item); return item

@router.get('/ingredients', response_model=list[IngredientOut])
def list_ingredients(q: str = '', db: Session = Depends(get_db)):
    stmt = select(Ingredient).where(Ingredient.is_active.is_(True)).order_by(Ingredient.name_en)
    if q.strip(): stmt = stmt.where(Ingredient.name_en.ilike(f'%{q.strip()}%'))
    return list(db.scalars(stmt).all())

@router.get('/ingredients/{ingredient_id}', response_model=IngredientOut)
def get_ingredient(ingredient_id: int, db: Session = Depends(get_db)):
    item = db.get(Ingredient, ingredient_id)
    if not item: raise HTTPException(404, 'Ingredient not found')
    return item

@router.put('/ingredients/{ingredient_id}', response_model=IngredientOut)
def update_ingredient(ingredient_id: int, payload: IngredientCreate, db: Session = Depends(get_db)):
    item = db.get(Ingredient, ingredient_id)
    if not item: raise HTTPException(404, 'Ingredient not found')
    for k,v in payload.model_dump(exclude={'aliases'}).items(): setattr(item,k,v)
    db.commit(); db.refresh(item); return item

@router.delete('/ingredients/{ingredient_id}')
def delete_ingredient(ingredient_id: int, db: Session = Depends(get_db)):
    item=db.get(Ingredient, ingredient_id)
    if not item: raise HTTPException(404,'Ingredient not found')
    if db.scalar(select(RecipeIngredient).where(RecipeIngredient.ingredient_id==ingredient_id)):
        raise HTTPException(409,'Ingredient is used by a recipe')
    db.delete(item); db.commit(); return {'success':True,'data':{'deleted':ingredient_id}}

@router.post('/recipes', response_model=RecipeOut)
def create_recipe(payload: RecipeCreate, db: Session = Depends(get_db)):
    recipe=Recipe(**payload.model_dump(exclude={'ingredients'})); db.add(recipe); db.flush()
    for link in payload.ingredients:
        if not db.get(Ingredient, link.ingredient_id): raise HTTPException(400,f'Ingredient {link.ingredient_id} not found')
        db.add(RecipeIngredient(recipe_id=recipe.id, **link.model_dump()))
    db.commit(); db.refresh(recipe); return recipe

@router.get('/recipes', response_model=list[RecipeOut])
def list_recipes(q: str='', cuisine: str='', db: Session=Depends(get_db)):
    stmt=select(Recipe).order_by(Recipe.name_en)
    if q.strip():
        t=f'%{q.strip()}%'; stmt=stmt.where(Recipe.name_en.ilike(t)|Recipe.name_ar.ilike(t)|Recipe.name_ro.ilike(t))
    if cuisine.strip(): stmt=stmt.where(Recipe.cuisine.ilike(cuisine.strip()))
    return list(db.scalars(stmt).all())

@router.get('/recipes/{recipe_id}', response_model=RecipeOut)
def get_recipe(recipe_id:int, db:Session=Depends(get_db)):
    item=db.get(Recipe,recipe_id)
    if not item: raise HTTPException(404,'Recipe not found')
    return item

@router.put('/recipes/{recipe_id}', response_model=RecipeOut)
def update_recipe(recipe_id:int,payload:RecipeCreate,db:Session=Depends(get_db)):
    recipe=db.get(Recipe,recipe_id)
    if not recipe: raise HTTPException(404,'Recipe not found')
    for k,v in payload.model_dump(exclude={'ingredients'}).items(): setattr(recipe,k,v)
    db.query(RecipeIngredient).filter(RecipeIngredient.recipe_id==recipe_id).delete()
    for link in payload.ingredients:
        if not db.get(Ingredient,link.ingredient_id): raise HTTPException(400,'Ingredient not found')
        db.add(RecipeIngredient(recipe_id=recipe_id,**link.model_dump()))
    db.commit(); db.refresh(recipe); return recipe

@router.delete('/recipes/{recipe_id}')
def delete_recipe(recipe_id:int,db:Session=Depends(get_db)):
    recipe=db.get(Recipe,recipe_id)
    if not recipe: raise HTTPException(404,'Recipe not found')
    db.delete(recipe); db.commit(); return {'success':True,'data':{'deleted':recipe_id}}
