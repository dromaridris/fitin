from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from app.db import get_db
from app.services.recommendation_engine import recommend

router = APIRouter(prefix="/recommendations", tags=["Recommendations"])

class WhatDoIHaveRequest(BaseModel):
    ingredients: list[str] = Field(default_factory=list, min_length=1)
    limit: int = Field(default=20, ge=1, le=50)

@router.post("/what-do-i-have")
def what_do_i_have(payload: WhatDoIHaveRequest, db: Session = Depends(get_db)):
    return {
        "query_ingredients": payload.ingredients,
        "results": recommend(db, payload.ingredients, payload.limit),
    }
