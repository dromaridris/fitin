# Smart Recipe & Nutrition App — BUILD 14
Real nutrition calculation engine.
- Calculates nutrition from ingredient quantity and per-100g source data.
- Calculates total and per-serving nutrition.
- Scales ingredient quantities and nutrition when servings change.
- Supports calories, protein, carbs, fat, fiber.
- Nutrition calculation is deterministic and independent of AI.
Endpoints:
POST /api/nutrition/recipe/{recipe_id}
POST /api/nutrition/recipe/{recipe_id}/scale
POST /api/nutrition/meal
