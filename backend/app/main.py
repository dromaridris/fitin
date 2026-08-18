from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from app.config import settings
from app.db import Base, SessionLocal, engine
from app import models
from app.license_service import validate_activation
from app.routers.admin import router as admin_router
from app.routers.admin_crud import router as crud_router
from app.routers.calorie_log import router as calorie_router
from app.routers.health import router as health_router
from app.routers.ingredients import router as ingredient_router
from app.routers.license import router as license_router
from app.routers.nutrition import router as nutrition_router
from app.routers.nutrition_profile import router as profile_router
from app.routers.recipes import router as recipe_router
from app.routers.recommendations import router as recommendation_router
from app.routers.search import router as search_router

app = FastAPI(title=settings.app_name, version='1.6.0')

origins = [o.strip() for o in settings.cors_origins.split(',') if o.strip()]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins or ['*'],
    allow_credentials=origins != ['*'],
    allow_methods=['*'],
    allow_headers=['*'],
)


@app.on_event('startup')
def startup():
    Base.metadata.create_all(bind=engine)


@app.middleware('http')
async def enforce_fitin_license(request, call_next):
    path = request.url.path
    public_paths = {'/api/health', '/api/license/activate', '/api/license/validate'}
    is_license_admin = path.startswith('/api/license/admin/')
    if not path.startswith('/api/') or path in public_paths or is_license_admin:
        return await call_next(request)

    token = request.headers.get('X-FITIN-License-Token', '')
    device_id = request.headers.get('X-FITIN-Device-ID', '')
    if not token or not device_id:
        return JSONResponse(status_code=401, content={'detail': 'FITIN license activation required.'})

    db = SessionLocal()
    try:
        if not validate_activation(db, token, device_id):
            return JSONResponse(status_code=403, content={'detail': 'Invalid, expired, or revoked FITIN license.'})
    finally:
        db.close()
    return await call_next(request)


@app.get('/')
def root():
    return {'success': True, 'data': {'name': settings.app_name, 'version': '1.6.0'}}


@app.get('/api/health')
def health():
    return {'success': True, 'data': {'status': 'healthy', 'version': '1.6.0'}}


for router in [
    license_router,
    crud_router,
    admin_router,
    calorie_router,
    health_router,
    ingredient_router,
    nutrition_router,
    profile_router,
    recipe_router,
    recommendation_router,
    search_router,
]:
    app.include_router(router, prefix='/api')
