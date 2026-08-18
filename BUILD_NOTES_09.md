# Smart Recipe & Nutrition App — BUILD 09

Core user journey is now connected:

What Do I Have?
→ Recommendation Engine
→ Match Score + Missing Ingredients
→ Recipe Details
→ Serving Calculator
→ Nutrition Engine

Backend adds a unified endpoint:
POST /api/recommendations/what-do-i-have

The Flutter flow uses the recommendation result and opens recipe details with the missing ingredients, then opens the nutrition calculator.

Nutrition remains backend-calculated from ingredient nutrition data; AI is not used for calorie calculation.
