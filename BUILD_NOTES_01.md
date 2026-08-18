# Smart Recipe & Nutrition App — MVP

Architecture:
- Flutter + Dart mobile app
- FastAPI + Python backend
- PostgreSQL database
- Modular Monolith
- Arabic / English / Roman Urdu

## Current build
This is BUILD 01: executable project foundation.
It contains:
- Flutter mobile shell
- FastAPI health/recipe endpoints
- PostgreSQL via Docker Compose
- CORS configuration
- First Home screen
- API service
- Project structure ready for the next implementation steps

## Run backend
```bash
cd backend
python -m venv .venv
# Windows: .venv\Scripts\activate
# macOS/Linux: source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

## Run database
```bash
docker compose up -d db
```

## Run Flutter
```bash
cd mobile
flutter pub get
flutter run
```

For an Android emulator, the backend URL is configured as `http://10.0.2.2:8000`.
For a physical phone, replace it with the computer's LAN IP.
