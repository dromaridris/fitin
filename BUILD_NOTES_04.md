# Smart Recipe & Nutrition App — BUILD 04

Search Engine foundation.

Adds:
- Multilingual ingredient search
- English / Arabic / Roman Urdu aliases
- Recipe search
- Cuisine filtering
- Search normalization
- Simple typo-tolerant normalization for common Roman Urdu variants
- Unified search endpoint
- PostgreSQL-based search foundation

Examples:
- chicken
- دجاج
- murghi
- murgi
- potato
- بطاطا
- بطاطس
- aloo
- مجدرة
- mujaddara

## API
GET /api/search?q=...
GET /api/recipes?q=...
GET /api/ingredients?q=...
