from tests.license_test_helper import licensed_client

client = licensed_client()


def test_profile_calculation():
    r = client.post('/api/profile/nutrition/calculate', json={
        'age': 30,
        'sex': 'female',
        'height_cm': 160,
        'weight_kg': 70,
        'activity_level': 'low',
        'breastfeeding': False,
    })
    assert r.status_code == 200
    data = r.json()['data']
    assert data['bmi'] > 0
    assert data['bmr_kcal'] > 0
    assert data['tdee_kcal'] > data['bmr_kcal']


def test_calorie_summary():
    r = client.post('/api/nutrition-log/summary', json={
        'calorie_target': 1800,
        'items': [
            {'name': 'Breakfast', 'calories': 400, 'protein_g': 20},
            {'name': 'Lunch', 'calories': 600, 'protein_g': 30},
        ],
    })
    assert r.status_code == 200
    assert r.json()['data']['consumed_calories'] == 1000
    assert r.json()['data']['remaining_calories'] == 800
