# API Contract — V1

## GET /api/health
Returns service health.

## GET /api/recipes?q=&cuisine=
Searches recipes.

## GET /api/recipes/{id}
Returns recipe details.

## POST /api/recommendations/what-do-i-have
Body:
{
  "ingredients": ["chicken", "potato"],
  "limit": 20
}

Returns ranked recipes with match score and missing ingredients.

## POST /api/nutrition/recipe/{recipe_id}
Body:
{
  "servings": 4
}

Returns:
- total nutrition
- per-serving nutrition
- scaled ingredient quantities

Important:
Nutrition values must come from ingredient nutrition data.
