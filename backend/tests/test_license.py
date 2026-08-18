from fastapi.testclient import TestClient
from app.db import Base, SessionLocal, engine
from app.license_service import create_license
from app.main import app

client = TestClient(app)


def test_protected_api_rejects_unlicensed_request():
    response = client.get('/api/ingredients')
    assert response.status_code in (401, 403)


def test_license_activation_and_validation():
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        _license, key = create_license(db, 'activation-test', 1)
    finally:
        db.close()

    device_id = 'test-device-1234567890123456'
    activation = client.post('/api/license/activate', json={
        'license_key': key,
        'device_id': device_id,
    })
    assert activation.status_code == 200
    token = activation.json()['data']['activation_token']

    validation = client.post(
        '/api/license/validate',
        headers={'X-FITIN-License-Token': token},
        json={'device_id': device_id},
    )
    assert validation.status_code == 200
    assert validation.json()['data']['valid'] is True
