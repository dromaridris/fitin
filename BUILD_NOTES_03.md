# Smart Recipe & Nutrition App — BUILD 03

Nutrition Engine + Serving Calculator.

This build adds:
- Nutrition calculation from ingredient quantities
- Per-recipe total nutrition
- Per-serving nutrition
- Scaled ingredient quantities
- Scaled nutrition for any number of servings
- Dedicated nutrition API
- Validation for invalid serving counts

## Endpoints
GET /api/recipes/{recipe_id}/nutrition?servings=4
GET /api/recipes/{recipe_id}/scale?servings=8

The nutrition engine is calculation-based. AI is not used as a nutrition source.
