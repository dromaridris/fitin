from pydantic import BaseModel, Field, ConfigDict
class AliasCreate(BaseModel):
    language: str = Field(min_length=2, max_length=10)
    alias: str = Field(min_length=1, max_length=160)
class IngredientCreate(BaseModel):
    canonical_key: str = Field(min_length=1, max_length=120)
    name_en: str; name_ar: str=''; name_ro: str=''; category: str=''
    calories_per_100g: float=Field(ge=0); protein_per_100g: float=Field(default=0,ge=0); carbs_per_100g: float=Field(default=0,ge=0); fat_per_100g: float=Field(default=0,ge=0); fiber_per_100g: float=Field(default=0,ge=0); is_active: bool=True
    aliases: list[AliasCreate]=[]
class IngredientOut(IngredientCreate):
    id:int
    model_config=ConfigDict(from_attributes=True)
class RecipeIngredientCreate(BaseModel):
    ingredient_id:int; quantity_g:float=Field(gt=0)
class RecipeCreate(BaseModel):
    slug:str; name_en:str; name_ar:str=''; name_ro:str=''; cuisine:str
    description_en:str=''; description_ar:str=''; servings:int=Field(default=1,ge=1,le=100); prep_minutes:int=Field(default=0,ge=0); cook_minutes:int=Field(default=0,ge=0)
    ingredients:list[RecipeIngredientCreate]=[]
class RecipeOut(RecipeCreate):
    id:int
    model_config=ConfigDict(from_attributes=True)
class SearchIngredient(BaseModel): id:int; name_en:str; name_ar:str; name_ro:str
class SearchRecipe(BaseModel): id:int; name_en:str; name_ar:str; name_ro:str; cuisine:str; servings:int; prep_minutes:int; cook_minutes:int
class SearchResponse(BaseModel): query:str; ingredients:list[SearchIngredient]; recipes:list[SearchRecipe]
