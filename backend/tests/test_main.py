import json
import urllib.parse
import uuid
from contextlib import contextmanager
from datetime import date

import pytest
import requests
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

# Import the fixtures from test_database.py
from tests.test_database import (
    override_get_db,
    reset_db,
    test_db,
    test_db_session,
    test_engine,
)

from backend.api.database import get_db_session
from backend.api.main import app
from backend.api.models import CompanyDB, JobDB, SalaryDB, TagDB


@pytest.fixture(scope="function")
def client(override_get_db, reset_db):
    app.dependency_overrides[get_db_session] = override_get_db
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()


@pytest.fixture(scope="function")
def sample_salary(test_db):
    # Create a tag
    tag = TagDB(name="tech")
    test_db.add(tag)
    test_db.flush()

    # Create a company
    company = CompanyDB(name="Test Company", type="startup")
    company.tags.append(tag)
    test_db.add(company)
    test_db.flush()

    # Create a job
    job = JobDB(title="Software Engineer")
    test_db.add(job)
    test_db.flush()

    # Create a salary
    salary = SalaryDB(
        gender="male",
        level="junior",
        gross_salary=50000,
        work_type="remote",
        net_salary=40000,
        added_date=date(2024, 10, 19),
        location="New York",
        variables=5000,
        total_experience_years=2,
        leave_days=20,
        experience_years_company=1,
        company_id=company.id,
    )
    salary.jobs.append(job)
    test_db.add(salary)
    test_db.commit()

    return salary


def test_read_main(client):
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Salary Information API"}


def test_create_salary(client: TestClient, monkeypatch):
    # Mock the CAPTCHA verification (if you're using it)
    def mock_post(*args, **kwargs):
        class MockResponse:
            def json(self):
                return {"success": True}

        return MockResponse()

    monkeypatch.setattr("requests.post", mock_post)

    # Prepare the salary data
    salary_data = {
        "gender": "male",
        "level": "junior",
        "gross_salary": 50000,
        "work_type": "remote",
        "net_salary": 40000,
        "technical_stacks": [{"name": "python"}, {"name": "fastapi"}],
        "added_date": "2024-10-19",
        "location": "New York",
        "jobs": [{"title": "Software Engineer"}],
        "variables": 5000,
        "total_experience_years": 2,
        "company": {"name": "Tech Corp", "type": "startup", "tags": [{"name": "tech"}]},
        "leave_days": 20,
        "experience_years_company": 1,
    }

    # Convert the salary data to a JSON string
    salary_json = json.dumps(salary_data)

    # Prepare the form data
    form_data = {"salary": salary_json, "captcha_token": "test_token"}

    # Make the request
    response = client.post(
        "/salaries/",
        data=form_data,
    )

    # Print response content for debugging
    print(f"Response status code: {response.status_code}")
    print(f"Response content: {response.content}")

    # Assert that the response is successful
    assert response.status_code == 200

    # If the response is successful, you can add more assertions to check the response data
    if response.status_code == 200:
        response_data = response.json()
        assert "id" in response_data
        assert response_data["gender"] == salary_data["gender"]
        assert response_data["level"] == salary_data["level"]
        # Add more assertions as needed


def test_get_salaries(client, sample_salary):
    response = client.get("/salaries/")
    assert response.status_code == 200
    assert "results" in response.json()
    assert "total" in response.json()
    assert len(response.json()["results"]) > 0

    # Additional assertions to verify the added salary
    results = response.json()["results"]
    assert any(salary["id"] == sample_salary.id for salary in results)
    added_salary = next(
        salary for salary in results if salary["id"] == sample_salary.id
    )
    assert added_salary["gross_salary"] == 50000
    assert added_salary["location"] == "New York"
    assert added_salary["company"]["name"] == "Test Company"
    assert any(job["title"] == "Software Engineer" for job in added_salary["jobs"])


def test_delete_salaries(client, test_db):
    # Create test data
    test_company = CompanyDB(name="Test Company", type="startup")
    test_db.add(test_company)
    test_db.flush()

    test_job = JobDB(title="Test Job")
    test_db.add(test_job)
    test_db.flush()

    test_salary = SalaryDB(
        company_id=test_company.id,
        location="Test City",
        gross_salary=100000,
        level="mid",
        work_type="remote",
    )
    test_salary.jobs.append(test_job)
    test_db.add(test_salary)
    test_db.commit()

    salary_id = test_salary.id

    # Verify that the salary was added
    test_db.refresh(test_salary)
    added_salary = test_db.query(SalaryDB).filter(SalaryDB.id == salary_id).first()
    assert (
        added_salary is not None
    ), f"Salary with id {salary_id} was not added to the database"

    print(f"Added salary with ID: {salary_id}")

    # Now test the delete operation
    delete_response = client.delete(f"/salaries/?salary_ids={salary_id}")

    # Check if the deletion was successful
    assert (
        delete_response.status_code == 200
    ), f"Failed to delete salary: {delete_response.content}"

    # Verify that the salary has been deleted from the database
    test_db.expire_all()
    deleted_salary = test_db.query(SalaryDB).filter(SalaryDB.id == salary_id).first()
    assert deleted_salary is None, f"Salary still exists in the database after deletion"

    print("Delete salary test passed successfully")


def test_get_salary_stats(client):
    response = client.get("/salaries/stats/")
    assert response.status_code == 200
    assert "avg_salary_by_city" in response.json()
    assert "top_10_cities" in response.json()


def test_get_choices(client):
    response = client.get("/salaries/choices/")
    assert response.status_code == 200
    assert "company_names" in response.json()
    assert "company_types" in response.json()
    assert "job_titles" in response.json()
    assert "locations" in response.json()
    assert "levels" in response.json()
    assert "work_types" in response.json()
    assert "technical_stacks" in response.json()


def test_create_and_get_technical_stack(client):
    create_response = client.post("/technical-stacks/", json={"name": "Python"})
    assert create_response.status_code == 200
    assert create_response.json()["name"] == "Python"

    get_response = client.get("/technical-stacks/")
    assert get_response.status_code == 200
    assert any(stack["name"] == "Python" for stack in get_response.json())


def test_create_and_get_job(client):
    create_response = client.post("/jobs/", json={"title": "Data Scientist"})
    assert create_response.status_code == 200
    assert create_response.json()["title"] == "data scientist"

    get_response = client.get("/jobs/")
    assert get_response.status_code == 200
    assert any(
        job["title"] == "data scientist" for job in get_response.json()["results"]
    )


def test_create_and_get_company(client, test_db):
    unique_name = f"New Company {uuid.uuid4()}"
    create_data = {
        "name": unique_name,
        "type": "startup",
        "tags": [{"name": "tech"}, {"name": "AI"}],
    }
    create_response = client.post("/companies/", json=create_data)
    assert (
        create_response.status_code == 200
    ), f"Failed to create company: {create_response.content}"

    created_company = create_response.json()
    assert created_company["name"] == unique_name
    assert created_company["type"] == "startup"
    assert len(created_company["tags"]) == 2

    # Test getting the created company
    get_response = client.get(f"/companies/")
    assert get_response.status_code == 200

    retrieved_company = get_response.json()["results"][0]
    assert retrieved_company["id"] == created_company["id"]
    assert retrieved_company["name"] == created_company["name"]
    assert retrieved_company["type"] == created_company["type"]
    assert len(retrieved_company["tags"]) == len(created_company["tags"])


def test_delete_companies(client, test_db):
    # Create a test company
    company = CompanyDB(name="Test Company to Delete", type="startup")
    test_db.add(company)
    test_db.commit()

    # Delete the company
    response = client.delete(f"/companies/?company_ids={company.id}")
    assert response.status_code == 200
    assert "deleted successfully" in response.json()["message"]

    # Verify the company is deleted
    deleted_company = (
        test_db.query(CompanyDB).filter(CompanyDB.id == company.id).first()
    )
    assert deleted_company is None


def test_check_endpoints(client):
    endpoints = [
        ("/check-company-name/", {"name": "Test Company"}),
        ("/check-company-tag/", {"name": "tech"}),
        ("/check-job-title/", {"title": "Software Engineer"}),
        ("/check-location/", {"name": "Test City"}),
        ("/check-technical-stack/", {"name": "Python"}),
    ]

    for endpoint, params in endpoints:
        response = client.get(endpoint, params=params)
        assert response.status_code == 200
        assert "exists" in response.json()


def test_get_salaries_pagination_and_sorting(client):
    # Test pagination
    response = client.get("/salaries/?skip=0&limit=10")
    assert response.status_code == 200
    assert len(response.json()["results"]) <= 10

    # Test sorting
    response = client.get("/salaries/?sort_by=gross_salary&sort_order=desc")
    assert response.status_code == 200
    salaries = response.json()["results"]
    assert all(
        salaries[i]["gross_salary"] >= salaries[i + 1]["gross_salary"]
        for i in range(len(salaries) - 1)
    )


def test_get_salaries_filtering(client):
    # Test filtering by company name
    response = client.get("/salaries/?company_names=Tech%20Corp")
    assert response.status_code == 200
    assert all(
        salary["company"]["name"] == "Tech Corp"
        for salary in response.json()["results"]
    )

    # Test filtering by job title
    response = client.get("/salaries/?job_titles=Software%20Engineer")
    assert response.status_code == 200
    assert all(
        any(job["title"] == "software engineer" for job in salary["jobs"])
        for salary in response.json()["results"]
    )

    # Test filtering by salary range
    response = client.get("/salaries/?gross_salary_min=50000&gross_salary_max=100000")
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
        "/salaries/", data={"salary": json.dumps(invalid_salary_data)}
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
