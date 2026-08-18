# Smart Recipe & Nutrition App — BUILD 15 MVP

This is the integrated MVP build from Builds 1–14.

## Included
- FastAPI backend + PostgreSQL Docker setup
- Seed dataset: 14 ingredients + aliases and 8 recipes across Pakistani, Syrian, Arabic and International cuisines
- Multilingual ingredient/recipe search foundation
- What Do I Have recommendation endpoint with match score and missing ingredients
- Recipe details and serving scaling
- Deterministic nutrition engine: calories, protein, carbs, fat, fiber
- Nutrition profile: BMI, BMR, TDEE and estimated daily calorie target
- Daily calorie summary endpoint
- Admin CRUD foundation for ingredients and recipes
- Flutter mobile MVP shell with Home, Search, What Do I Have, Recommendations, Favorites, Recipe Details, Nutrition and Nutrition Dashboard
- Docker Compose for PostgreSQL + API + seed

## Run backend
```bash
docker compose up --build
```
API: http://localhost:8000
Swagger: http://localhost:8000/docs

## Local backend
```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload
python -m app.seed
```

## Flutter
```bash
cd flutter
flutter pub get
flutter run
```
Set `flutter/lib/config/app_config.dart` to the reachable API address for the device/emulator.

## Verification status
- Backend integration tests can run with pytest.
- Flutter/Android APK build could not be executed in this environment because Flutter/Android SDK tooling is not installed here. The source is prepared for the next machine/CI build step; no false claim of an APK is made.

## Important nutrition rule
Nutrition values are calculated from stored ingredient nutrition data and quantities. AI is not used as the calculation source.
