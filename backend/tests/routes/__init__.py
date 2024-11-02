import json


def test_check_endpoints(client):
    endpoints = [
        ("/companies/check-name/", {"name": "Test Company"}),
        ("/companies/check-tag/", {"name": "tech"}),
        ("/jobs/check-title/", {"title": "Software Engineer"}),
        ("/salaries/check-location/", {"name": "Test City"}),
        ("/technical-stacks/check-name/", {"name": "Python"}),
    ]

    for endpoint, params in endpoints:
        response = client.get(
            endpoint,
            params=params,
        )
        assert response.status_code == 200
        assert "exists" in response.json()


def test_get_salaries_pagination_and_sorting(client):
    # Test pagination
    response = client.get(
        "/salaries/?skip=0&limit=10",
    )
    assert response.status_code == 200
    assert len(response.json()["results"]) <= 10

    # Test sorting
    response = client.get(
        "/salaries/?sort_by=gross_salary&sort_order=desc",
    )
    assert response.status_code == 200
    salaries = response.json()["results"]
    assert all(
        salaries[i]["gross_salary"] >= salaries[i + 1]["gross_salary"]
        for i in range(len(salaries) - 1)
    )


def test_get_salaries_filtering(client):
    # Test filtering by company name
    response = client.get(
        "/salaries/?company_names=Tech%20Corp",
    )
    assert response.status_code == 200
    assert all(
        salary["company"]["name"] == "Tech Corp"
        for salary in response.json()["results"]
    )

    # Test filtering by job title
    response = client.get(
        "/salaries/?job_titles=Software%20Engineer",
    )
    assert response.status_code == 200
    assert all(
        any(job["title"] == "software engineer" for job in salary["jobs"])
        for salary in response.json()["results"]
    )

    # Test filtering by salary range
    response = client.get(
        "/salaries/?gross_salary_min=50000&gross_salary_max=100000",
    )
    assert response.status_code == 200
    assert all(
        50000 <= salary["gross_salary"] <= 100000
        for salary in response.json()["results"]
    )


def test_error_handling(client):
    # Test invalid salary data
    invalid_salary_data = {
        "gender": "invalid",
        "level": "invalid",
        "gross_salary": "not a number",
        "work_type": "invalid",
    }
    response = client.post(
        "/salaries/",
        data={"salary": json.dumps(invalid_salary_data)},
    )
    assert response.status_code == 422

    # Test invalid company data
    invalid_company_data = {
        "name": "",
        "type": "invalid",
    }
    response = client.post("/companies/", json=invalid_company_data)
    assert response.status_code == 422

    # Test deleting non-existent salary
    response = client.delete("/salaries/?salary_ids=99999")
    assert response.status_code == 404

    # Test deleting non-existent company
    response = client.delete("/companies/?company_ids=99999")
    assert response.status_code == 404
