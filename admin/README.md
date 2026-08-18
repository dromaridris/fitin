# Admin Dashboard — BUILD 13

The backend now exposes real CRUD endpoints.

Ingredients:
- POST /api/admin/ingredients
- GET /api/admin/ingredients
- GET /api/admin/ingredients/{id}
- PUT /api/admin/ingredients/{id}
- DELETE /api/admin/ingredients/{id}

Recipes:
- POST /api/admin/recipes
- GET /api/admin/recipes
- GET /api/admin/recipes/{id}
- PUT /api/admin/recipes/{id}
- DELETE /api/admin/recipes/{id}

Before production:
- Add admin authentication.
- Add role-based authorization.
- Add audit log.
- Add database migrations (Alembic).
