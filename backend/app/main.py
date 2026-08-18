from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.db import Base, engine
from app import models
from app.routers.admin import router as admin_router
from app.routers.admin_crud import router as crud_router
from app.routers.calorie_log import router as calorie_router
from app.routers.health import router as health_router
from app.routers.ingredients import router as ingredient_router
from app.routers.nutrition import router as nutrition_router
from app.routers.nutrition_profile import router as profile_router
from app.routers.recipes import router as recipe_router
from app.routers.recommendations import router as recommendation_router
from app.routers.search import router as search_router

app = FastAPI(title=settings.app_name, version='1.7.0')

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


@app.get('/')
def root():
    return {'success': True, 'data': {'name': settings.app_name, 'version': '1.7.0'}}


@app.get('/api/health')
def health():
    return {'success': True, 'data': {'status': 'healthy', 'version': '1.7.0'}}


# Licensing is now permanent and verified locally inside the mobile app.
# The API no longer requires or issues FITIN license tokens.
for router in [
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
