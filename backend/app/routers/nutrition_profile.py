from fastapi import APIRouter
from pydantic import BaseModel, Field

from app.nutrition_profile import (
    NutritionProfile,
    calculate_bmi,
    bmi_category,
    calculate_bmr,
    calculate_tdee,
    estimate_calorie_target,
)

router = APIRouter(prefix="/profile/nutrition", tags=["Nutrition Profile"])

class NutritionProfileRequest(BaseModel):
    age: int = Field(ge=13, le=120)
    sex: str
    height_cm: float = Field(gt=80, lt=250)
    weight_kg: float = Field(gt=20, lt=400)
    activity_level: str = "low"
    breastfeeding: bool = False

@router.post("/calculate")
def calculate_profile(payload: NutritionProfileRequest):
    profile = NutritionProfile(**payload.model_dump())
    bmi = calculate_bmi(profile.weight_kg, profile.height_cm)
    return {
        "success": True,
        "data": {
            "bmi": bmi,
            "bmi_category": bmi_category(bmi),
            "bmr_kcal": calculate_bmr(profile),
            "tdee_kcal": calculate_tdee(profile),
            "estimated_daily_calorie_target": estimate_calorie_target(profile),
            "breastfeeding": profile.breastfeeding,
            "disclaimer": (
                "BMI is a screening measure, not a diagnosis. "
                "Calorie needs are estimates and may require professional adjustment."
            ),
        },
    }
