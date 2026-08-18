# Smart Recipe & Nutrition App — BUILD 05

What Do I Have? + Recommendation Engine.

This build adds:
- Ingredient matching from user-provided ingredients
- Alias resolution in English / Arabic / Roman Urdu
- Recipe matching score
- Available ingredients
- Missing ingredients
- Missing ingredient count
- Match percentage
- Ranking by match quality
- Optional cuisine filter
- Optional max missing ingredients
- REST endpoint for the core app feature

## Endpoint
POST /api/recommendations/what-do-i-have

Example:
{
  "ingredients": ["دجاج", "بطاطا", "بصل"]
}

The engine is deterministic and database-driven.
AI is not used to calculate nutrition or matching.
