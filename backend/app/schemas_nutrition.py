from pydantic import BaseModel, Field

class NutritionRequest(BaseModel):
    servings: int = Field(default=1, ge=1, le=100)
