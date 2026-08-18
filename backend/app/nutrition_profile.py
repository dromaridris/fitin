from dataclasses import dataclass

@dataclass
class NutritionProfile:
    age: int
    sex: str
    height_cm: float
    weight_kg: float
    activity_level: str = "low"
    breastfeeding: bool = False

ACTIVITY_FACTORS = {
    "sedentary": 1.20,
    "low": 1.375,
    "moderate": 1.55,
    "high": 1.725,
}

def calculate_bmi(weight_kg: float, height_cm: float) -> float:
    if weight_kg <= 0 or height_cm <= 0:
        raise ValueError("Weight and height must be positive")
    meters = height_cm / 100
    return round(weight_kg / (meters * meters), 1)

def bmi_category(bmi: float) -> str:
    if bmi < 18.5:
        return "underweight"
    if bmi < 25:
        return "healthy_range"
    if bmi < 30:
        return "overweight"
    return "obesity_range"

def calculate_bmr(profile: NutritionProfile) -> float:
    # Mifflin-St Jeor equation.
    base = 10 * profile.weight_kg + 6.25 * profile.height_cm - 5 * profile.age
    return round(base + (5 if profile.sex.lower() == "male" else -161), 0)

def calculate_tdee(profile: NutritionProfile) -> float:
    return round(calculate_bmr(profile) * ACTIVITY_FACTORS.get(profile.activity_level, 1.20), 0)

def estimate_calorie_target(profile: NutritionProfile) -> float:
    target = calculate_tdee(profile)
    # Breastfeeding is intentionally not assigned a hard automatic calorie
    # deduction. A qualified professional/user-selected target should be used.
    return target
