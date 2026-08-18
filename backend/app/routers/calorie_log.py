from fastapi import APIRouter
from pydantic import BaseModel, Field
from typing import List

router = APIRouter(prefix="/nutrition-log", tags=["Nutrition Log"])

class FoodLogItem(BaseModel):
    name: str
    calories: float = Field(ge=0)
    protein_g: float = Field(default=0, ge=0)
    carbs_g: float = Field(default=0, ge=0)
    fat_g: float = Field(default=0, ge=0)

class DailyLogRequest(BaseModel):
    calorie_target: float = Field(gt=0)
    items: List[FoodLogItem] = []

@router.post("/summary")
def daily_summary(payload: DailyLogRequest):
    calories = sum(x.calories for x in payload.items)
    protein = sum(x.protein_g for x in payload.items)
    carbs = sum(x.carbs_g for x in payload.items)
    fat = sum(x.fat_g for x in payload.items)

    return {
        "success": True,
        "data": {
            "consumed_calories": round(calories, 1),
            "target_calories": round(payload.calorie_target, 1),
            "remaining_calories": round(max(payload.calorie_target - calories, 0), 1),
            "protein_g": round(protein, 1),
            "carbs_g": round(carbs, 1),
            "fat_g": round(fat, 1),
            "progress_percent": round(min((calories / payload.calorie_target) * 100, 100), 1),
        },
    }
