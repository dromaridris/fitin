from fastapi.testclient import TestClient
from app.main import app


def licensed_client():
    """Backward-compatible test helper.

    FITIN licensing is now verified permanently and offline in the mobile app,
    so backend API tests no longer need activation tokens.
    """
    return TestClient(app)
