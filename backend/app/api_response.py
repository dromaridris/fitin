from typing import Any

def ok(data: Any):
    return {"success": True, "data": data}

def error(message: str, code: str):
    return {"success": False, "error": {"code": code, "message": message}}
