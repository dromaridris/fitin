from fastapi import APIRouter

router = APIRouter(prefix="/admin", tags=["Admin"])

@router.get("/dashboard")
def dashboard():
    # BUILD 12 foundation. Real DB counts are wired when admin auth/database
    # modules are enabled.
    return {
        "success": True,
        "data": {
            "status": "ready",
            "modules": [
                "ingredients",
                "recipes",
                "nutrition",
                "users",
            ],
        },
    }

@router.get("/ingredients")
def ingredients():
    return {"success": True, "data": {"items": []}}

@router.get("/recipes")
def recipes():
    return {"success": True, "data": {"items": []}}
