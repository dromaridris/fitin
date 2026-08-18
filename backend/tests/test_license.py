from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_api_no_longer_requires_online_license_token():
    response = client.get('/api/health')
    assert response.status_code == 200


def test_old_online_license_endpoint_is_not_exposed():
    response = client.post('/api/license/validate', json={'device_id': 'test-device'})
    assert response.status_code == 404
