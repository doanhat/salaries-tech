def test_get_choices(client):
    response = client.get("/choices/")
    assert response.status_code == 200
    assert "company_names" in response.json()
    assert "company_types" in response.json()
    assert "job_titles" in response.json()
    assert "locations" in response.json()
    assert "levels" in response.json()
    assert "work_types" in response.json()
    assert "technical_stacks" in response.json()
