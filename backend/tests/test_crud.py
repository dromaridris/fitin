from tests.license_test_helper import licensed_client

client = licensed_client()


def test_create_ingredient():
    r = client.post('/api/admin/ingredients', json={
        'canonical_key': 'test_tomato',
        'name_en': 'Test Tomato',
        'name_ar': 'طماطم اختبار',
        'name_ro': 'Tamatar Test',
        'category': 'vegetable',
        'calories_per_100g': 18,
        'protein_per_100g': 0.9,
        'carbs_per_100g': 3.9,
        'fat_per_100g': 0.2,
        'fiber_per_100g': 1.2,
    })
    assert r.status_code in (200, 409)


def test_list_ingredients():
    r = client.get('/api/admin/ingredients')
    assert r.status_code == 200
    assert isinstance(r.json(), list)
