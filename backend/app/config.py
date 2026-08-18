from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = 'Smart Recipe & Nutrition API'
    app_env: str = 'development'
    database_url: str = 'sqlite:///./smart_recipe_dev.db'
    cors_origins: str = '*'
    license_admin_secret: str = ''

    model_config = SettingsConfigDict(env_file='.env', extra='ignore')


settings = Settings()
