# Smart Recipe & Nutrition App — BUILD 02

BUILD 02 adds the real database foundation:
- PostgreSQL
- SQLAlchemy ORM
- Ingredients
- Ingredient aliases (English / Arabic / Roman Urdu)
- Recipes
- Recipe ingredients
- Nutrition fields
- Automatic database initialization
- Seed data
- Recipe search endpoint
- Ingredient search endpoint

## Start
1. Start PostgreSQL:
   `docker compose up -d db`
2. Backend:
   `cd backend`
   `python -m venv .venv`
   activate the environment
   `pip install -r requirements.txt`
   `uvicorn app.main:app --reload`
3. API docs:
   `http://127.0.0.1:8000/docs`

The mobile app from BUILD 01 can be connected to this backend using the same API base URL.
