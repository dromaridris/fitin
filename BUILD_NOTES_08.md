# Smart Recipe & Nutrition App — BUILD 08

Nutrition Engine + Serving Calculator API and Flutter UI.

Nutrition is calculated from ingredient quantities and stored nutrition data.
AI is NOT used for nutrition calculations.

Backend:
POST /api/nutrition/recipe/{recipe_id}
Body: {"servings": 4}

Returns:
- total calories
- protein
- carbs
- fat
- fiber
- per-serving nutrition
- scaled ingredient quantities

Flutter:
- Recipe nutrition card
- Serving +/- controls
- Dynamic scaled quantities
