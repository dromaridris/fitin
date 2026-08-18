from fastapi.testclient import TestClient
from app.db import Base, SessionLocal, engine
from app.license_service import create_license, activate_license
from app.main import app


def licensed_client():
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        _lic, key = create_license(db, 'pytest', 10)
        device_id = 'pytest-device-0000000000000001'
        token, error = activate_license(db, key, device_id)
        assert error is None and token
    finally:
        db.close()
    return TestClient(app, headers={
        'X-FITIN-License-Token': token,
        'X-FITIN-Device-ID': device_id,
    })
