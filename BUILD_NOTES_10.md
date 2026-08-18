# Smart Recipe & Nutrition App — BUILD 10

Backend API consolidation.

Included:
- FastAPI application
- PostgreSQL-ready SQLAlchemy setup
- Environment configuration
- API versioning under /api
- Health endpoint
- Recipe Search API
- What Do I Have recommendation API
- Nutrition API
- CORS configuration
- Central error handling
- Automated API smoke tests

Run backend:
python -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload

Open:
http://127.0.0.1:8000/docs

Database:
Set DATABASE_URL in .env.
Example:
DATABASE_URL=postgresql+psycopg://postgres:postgres@localhost:5432/smart_recipe
