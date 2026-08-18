# Smart Recipe & Nutrition App — BUILD 13

Admin CRUD + PostgreSQL data foundation.

Added:
- SQLAlchemy Ingredient model
- SQLAlchemy Recipe model
- RecipeIngredient model
- Admin CRUD endpoints
- Recipe search endpoint backed by DB
- Ingredient search endpoint
- PostgreSQL-ready schema
- SQLite fallback for local development
- Basic validation and tests

The nutrition engine remains separate: ingredient nutrition values are stored as source data,
while recipe nutrition is calculated from recipe ingredient quantities.

Security note:
Admin authentication/authorization is intentionally not implemented as a fake security layer.
It is the next required hardening step before production deployment.
